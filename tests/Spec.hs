-----------------------------------------------------------------------------
-- | Native correctness tests: geometry, the solver, and the guarantee
-- that generated puzzles are valid with exactly one solution.
-----------------------------------------------------------------------------
module Main where
-----------------------------------------------------------------------------
import           Control.Monad (forM_, unless)
import           Data.IORef
import           Data.Maybe (catMaybes)
import           System.Exit (exitFailure)
-----------------------------------------------------------------------------
import           Logic
import           Model
-----------------------------------------------------------------------------
main :: IO ()
main = do
  failures <- newIORef (0 :: Int)
  let check name ok = do
        putStrLn ((if ok then "  ok  " else " FAIL ") <> name)
        unless ok (modifyIORef failures (+ 1))

  -- geometry ----------------------------------------------------------
  check "every cell has exactly 20 peers"
    (all (\i -> length (peersOf i) == 20) [0 .. 80])
  check "peer relation is symmetric"
    (and [ i `elem` peersOf j | i <- [0, 13, 40, 80], j <- peersOf i ])
  check "boxes partition the grid"
    (all (\b -> length [ () | i <- [0 .. 80], boxOf i == b ] == 9) [0 .. 8])

  -- solver --------------------------------------------------------------
  let knownPuzzle = parse
        "530070000600195000098000060800060003400803001\
        \700020006060000280000419005000080079"
  check "a classic puzzle has exactly one solution"
    (solveCount 2 knownPuzzle == 1)
  check "an empty grid has many solutions (cap reached)"
    (solveCount 2 (replicate 81 Nothing) == 2)
  check "a contradictory grid has none"
    (solveCount 2 (contradiction knownPuzzle) == 0)

  -- generation ----------------------------------------------------------
  forM_ [minBound .. maxBound :: Difficulty] $ \diff ->
    forM_ [1 .. 5 :: Int] $ \seed -> do
      let name s = difficultyNameS diff <> " seed " <> show seed <> ": " <> s
      case generate (lcg (seed * 17 + fromEnum diff)) diff of
        Nothing -> check (name "generates") False
        Just (sol, puz) -> do
          check (name "solution is a valid grid") (validSolution sol)
          check (name "givens agree with the solution")
            (and [ v == sol !! i | (i, Just v) <- zip [0 ..] puz ])
          check (name "puzzle has exactly one solution")
            (solveCount 2 puz == 1)
          check (name "given count is near target")
            (let g = length (catMaybes puz)
             in g >= targetGivens diff && g <= targetGivens diff + 8)

  -- helpers -------------------------------------------------------------
  check "conflicted spots duplicates"
    (conflicted (dup knownPuzzle) /= [])
  check "no conflicts in a legal puzzle" (null (conflicted knownPuzzle))
  check "formatTime pads" (formatTime 65 == "01:05" && formatTime 600 == "10:00")

  n <- readIORef failures
  if n == 0
    then putStrLn "\nAll tests passed."
    else do
      putStrLn ("\n" <> show n <> " test(s) failed.")
      exitFailure
  where
    parse = map (\ch -> if ch == '0' then Nothing else Just (fromEnum ch - 48))
    difficultyNameS = show
    -- overwrite the first empty cell with a digit already in its row
    contradiction p =
      case [ (i, v)
           | (i, Nothing) <- zip [0 ..] p
           , Just v <- [firstRowValue p i]
           ] of
        ((i, v) : _) -> [ if j == i then Just v else x | (j, x) <- zip [0 ..] p ]
        [] -> p
    firstRowValue p i =
      case [ v | j <- peersOf i, rowOf j == rowOf i, Just v <- [p !! j] ] of
        (v : _) -> Just v
        [] -> Nothing
    dup = contradiction
-----------------------------------------------------------------------------
-- | Deterministic supply in [0, 1).
lcg :: Int -> [Double]
lcg seed =
  map (\x -> fromIntegral x / 2147483648)
      (drop 1 (iterate step (seed * 7919 + 13)))
  where
    step x = (1103515245 * x + 12345) `mod` 2147483648
