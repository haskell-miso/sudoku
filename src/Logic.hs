-----------------------------------------------------------------------------
-- | Pure sudoku rules: solving (solution counting), puzzle generation
-- with a deterministic randomness supply, and board helpers.
-----------------------------------------------------------------------------
module Logic where
-----------------------------------------------------------------------------
import           Data.Bits ((.|.), (.&.), complement, popCount, setBit, shiftL, testBit)
import qualified Data.IntMap.Strict as IM
import           Data.List (delete, minimumBy, sortOn)
import           Data.Ord (comparing)
-----------------------------------------------------------------------------
import           Miso.Random (replicateRM)
import           Miso.String (MisoString, ms)
-----------------------------------------------------------------------------
import           Model
-----------------------------------------------------------------------------
-- * Geometry
-----------------------------------------------------------------------------
rowOf, colOf, boxOf :: Int -> Int
rowOf i = i `div` 9
colOf i = i `mod` 9
boxOf i = (rowOf i `div` 3) * 3 + colOf i `div` 3
-----------------------------------------------------------------------------
-- | The 20 cells sharing a row, column, or box with @i@.
peersOf :: Int -> [Int]
peersOf i =
  [ j
  | j <- [0 .. 80]
  , j /= i
  , rowOf j == rowOf i || colOf j == colOf i || boxOf j == boxOf i
  ]
-----------------------------------------------------------------------------
-- * Solver
-----------------------------------------------------------------------------
-- | Digit-usage bitmasks per row, column, and box.
data Masks = Masks
  { mRows :: !(IM.IntMap Int)
  , mCols :: !(IM.IntMap Int)
  , mBoxes :: !(IM.IntMap Int)
  }
-----------------------------------------------------------------------------
fullMask :: Int
fullMask = foldl setBit 0 [1 .. 9]
-----------------------------------------------------------------------------
maskAt :: IM.IntMap Int -> Int -> Int
maskAt im k = IM.findWithDefault 0 k im
-----------------------------------------------------------------------------
-- | Digits still allowed at cell @i@.
candsAt :: Masks -> Int -> Int
candsAt Masks{..} i =
  complement
    (maskAt mRows (rowOf i) .|. maskAt mCols (colOf i) .|. maskAt mBoxes (boxOf i))
    .&. fullMask
-----------------------------------------------------------------------------
placeDigit :: Int -> Int -> Masks -> Masks
placeDigit i d Masks{..} = Masks
  { mRows = IM.insertWith (.|.) (rowOf i) bit_ mRows
  , mCols = IM.insertWith (.|.) (colOf i) bit_ mCols
  , mBoxes = IM.insertWith (.|.) (boxOf i) bit_ mBoxes
  }
  where
    bit_ = 1 `shiftL` d
-----------------------------------------------------------------------------
-- | Masks for the filled cells of a puzzle; 'Nothing' when a unit already
-- contains a duplicate.
masksOf :: [Maybe Int] -> Maybe Masks
masksOf p = go (Masks IM.empty IM.empty IM.empty) (zip [0 ..] p)
  where
    go m [] = Just m
    go m ((_, Nothing) : rest) = go m rest
    go m ((i, Just d) : rest)
      | testBit (candsAt m i) d = go (placeDigit i d m) rest
      | otherwise = Nothing
-----------------------------------------------------------------------------
-- | Count solutions, stopping at @cap@. Chooses the most constrained
-- empty cell first (MRV), so near-minimal puzzles stay fast.
solveCount :: Int -> [Maybe Int] -> Int
solveCount cap p = case masksOf p of
  Nothing -> 0
  Just m0 -> search m0 [ i | (i, Nothing) <- zip [0 ..] p ]
  where
    search _ [] = 1
    search m es
      | cnds == 0 = 0
      | otherwise = go 0 [ d | d <- [1 .. 9], testBit cnds d ]
      where
        i = minimumBy (comparing (popCount . candsAt m)) es
        cnds = candsAt m i
        es' = delete i es
        go acc [] = acc
        go acc (d : ds)
          | acc >= cap = acc
          | otherwise = go (acc + search (placeDigit i d m) es') ds
-----------------------------------------------------------------------------
-- | Complete an empty grid, trying digits in the per-cell orders given.
fillGrid :: [[Int]] -> Maybe [Int]
fillGrid orders = IM.elems <$> go 0 (Masks IM.empty IM.empty IM.empty) IM.empty
  where
    go 81 _ acc = Just acc
    go i m acc = try [ d | d <- orders !! i, testBit (candsAt m i) d ]
      where
        try [] = Nothing
        try (d : ds) =
          case go (i + 1) (placeDigit i d m) (IM.insert i d acc) of
            Just r -> Just r
            Nothing -> try ds
-----------------------------------------------------------------------------
-- * Generation
-----------------------------------------------------------------------------
-- | Given digits remaining per difficulty.
targetGivens :: Difficulty -> Int
targetGivens Easy   = 40
targetGivens Medium = 34
targetGivens Hard   = 30
targetGivens Expert = 27
-----------------------------------------------------------------------------
shuffleWith :: [Double] -> [a] -> [a]
shuffleWith keys xs = map snd (sortOn fst (zip keys xs))
-----------------------------------------------------------------------------
-- | Remove cells in the given order while the puzzle keeps a unique
-- solution, until only the target number of givens remains.
dig :: [Int] -> Int -> [Int] -> [Maybe Int]
dig order target sol = go order (map Just sol) 81
  where
    go [] p _ = p
    go (i : is) p givens
      | givens <= target = p
      | solveCount 2 p' == 1 = go is p' (givens - 1)
      | otherwise = go is p givens
      where
        p' = [ if j == i then Nothing else v | (j, v) <- zip [0 ..] p ]
-----------------------------------------------------------------------------
-- | Pure puzzle generation from a randomness supply:
-- (solution, puzzle with holes).
generate :: [Double] -> Difficulty -> Maybe ([Int], [Maybe Int])
generate supply diff = do
  sol <- fillGrid orders
  pure (sol, dig digOrder (targetGivens diff) sol)
  where
    (orderKeys, rest) = splitAt (81 * 9) supply
    orders =
      [ shuffleWith ks [1 .. 9]
      | ks <- chunksOf 9 orderKeys
      ]
    digOrder = shuffleWith (take 81 rest) [0 .. 80]
    chunksOf _ [] = []
    chunksOf n xs = take n xs : chunksOf n (drop n xs)
-----------------------------------------------------------------------------
generateIO :: Difficulty -> IO ([Int], [Maybe Int])
generateIO diff = go (10 :: Int)
  where
    go n = do
      supply <- replicateRM (81 * 9 + 81)
      case generate supply diff of
        Just r -> pure r
        Nothing
          | n > 0 -> go (n - 1)
          | otherwise -> error "generateIO: exhausted retries"
-----------------------------------------------------------------------------
-- * Board helpers
-----------------------------------------------------------------------------
-- | Indices whose value collides with a peer.
conflicted :: [Maybe Int] -> [Int]
conflicted vs =
  [ i
  | (i, Just v) <- zip [0 ..] vs
  , any (\j -> vs !! j == Just v) (peersOf i)
  ]
-----------------------------------------------------------------------------
-- | A full, valid solution grid?
validSolution :: [Int] -> Bool
validSolution g =
  length g == 81 && all unitOk units
  where
    unitOk ix = sortOn id [ g !! i | i <- ix ] == [1 .. 9]
    units =
      [ [ i | i <- [0 .. 80], rowOf i == u ] | u <- [0 .. 8] ] ++
      [ [ i | i <- [0 .. 80], colOf i == u ] | u <- [0 .. 8] ] ++
      [ [ i | i <- [0 .. 80], boxOf i == u ] | u <- [0 .. 8] ]
-----------------------------------------------------------------------------
-- * Display helpers
-----------------------------------------------------------------------------
formatTime :: Int -> MisoString
formatTime s = pad (s `div` 60) <> ":" <> pad (s `mod` 60)
  where
    pad n
      | n < 10 = "0" <> ms n
      | otherwise = ms n
-----------------------------------------------------------------------------
difficultyName :: Difficulty -> MisoString
difficultyName Easy   = "easy"
difficultyName Medium = "medium"
difficultyName Hard   = "hard"
difficultyName Expert = "expert"
