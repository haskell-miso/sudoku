-----------------------------------------------------------------------------
-- | miso-sudoku: sudoku on a felt table, in the miso game family.
-----------------------------------------------------------------------------
module Main where
-----------------------------------------------------------------------------
import           Control.Concurrent (threadDelay)
import           Control.Monad (forever, when)
import           Data.List (delete, find)
import           Data.Maybe (isJust)
import qualified Data.IntSet as IS
-----------------------------------------------------------------------------
import           Miso hiding ((!!), view)
import           Miso.Lens hiding (view)
import qualified Miso.CSS as CSS
import qualified Miso.Html.Element as H
import qualified Miso.Html.Event as HE
import qualified Miso.Html.Property as HP
-----------------------------------------------------------------------------
import           Drag
import           Logic
import           Model
import           Sound
import           Styles (skin)
-----------------------------------------------------------------------------
main :: IO ()
main = startApp defaultEvents app
-----------------------------------------------------------------------------
app :: App Model Action
app = (component initialModel updateModel viewModel)
  { styles = [ Sheet skin ]
  , subs = [ timerSub, keyboardSub Keys ]
  }
-----------------------------------------------------------------------------
#ifdef WASM
foreign export javascript "hs_start" main :: IO ()
#endif
-----------------------------------------------------------------------------
timerSub :: Sub Model Action
timerSub sink _ = forever (threadDelay 1000000 >> sink Tick)
-----------------------------------------------------------------------------
type Fx = Effect () () Model Action
-----------------------------------------------------------------------------
-- * Update
-----------------------------------------------------------------------------
updateModel :: Action -> Fx
updateModel = \case
  NoOp -> pure ()

  ToggleSound -> soundOn %= not

  ShowHelp -> showHelp .= True

  CloseHelp -> showHelp .= False

  Tick -> do
    m <- get
    when (m ^. phase == Playing && not (m ^. showHelp)) (timeSec += 1)

  PickDifficulty d -> do
    io_ soundInit
    io_ dragInit
    io $ do
      (sol, puz) <- generateIO d
      pure (PuzzleReady sol puz d)

  PuzzleReady sol puz d -> do
    m <- get
    put initialModel
      { _cells = [ Cell v (isJust v) [] | v <- puz ]
      , _solution = sol
      , _difficulty = d
      , _phase = Playing
      , _soundOn = m ^. soundOn
      , _heldKeys = m ^. heldKeys
      }
    playFx "deal"

  NewGame -> do
    phase .= Title
    showHelp .= False

  SelectCell i -> do
    m <- get
    when (m ^. phase == Playing) $ do
      selected .= Just i
      shakeIx .= Nothing

  MoveSel dx dy -> do
    m <- get
    when (m ^. phase == Playing) $
      selected .= Just (case m ^. selected of
        Nothing -> 40
        Just i ->
          let r = max 0 (min 8 (rowOf i + dy))
              c = max 0 (min 8 (colOf i + dx))
          in r * 9 + c)

  ToggleNotes -> do
    m <- get
    when (m ^. phase == Playing) $ do
      notesMode %= not
      playFx "note"

  Enter d -> enterDigit d

  Erase -> do
    m <- get
    case (m ^. phase, m ^. selected) of
      (Playing, Just i)
        | c <- (m ^. cells) !! i
        , not (c ^. given)
        , isJust (c ^. value) || not (null (c ^. notes)) -> do
            history %= ([(i, c)] :)
            cells %= setCells [(i, c & value .~ Nothing & notes .~ [])]
            playFx "erase"
      _ -> pure ()

  Hint -> do
    m <- get
    when (m ^. phase == Playing) $
      if m ^. hintsUsed >= hintLimit
        then playFx "deny"
        else do
          let fixable i =
                let c = (m ^. cells) !! i
                in not (c ^. given) && c ^. value /= Just ((m ^. solution) !! i)
              target = case m ^. selected of
                Just i | fixable i -> Just i
                _ -> find fixable [0 .. 80]
          case target of
            Nothing -> playFx "deny"
            Just i -> do
              selected .= Just i
              hintsUsed += 1
              placeCorrect i ((m ^. solution) !! i)
              playFx "draw"

  Undo -> do
    m <- get
    case (m ^. phase, m ^. history) of
      (Playing, entries : rest) -> do
        history .= rest
        cells %= setCells entries
        shakeIx .= Nothing
        playFx "draw"
      _ -> pure ()

  Keys ks -> do
    m <- get
    let fresh = IS.toList (ks IS.\\ (m ^. heldKeys))
    heldKeys .= ks
    mapM_ (issueKey (m ^. showHelp)) fresh

-----------------------------------------------------------------------------
issueKey :: Bool -> Int -> Fx
issueKey helpOpen k
  | helpOpen, k == 27 = issue CloseHelp
  | helpOpen = pure ()
  | k >= 49 && k <= 57 = issue (Enter (k - 48))
  | k >= 97 && k <= 105 = issue (Enter (k - 96))
  | k == 8 || k == 46 = issue Erase
  | k == 78 = issue ToggleNotes
  | k == 72 = issue Hint
  | k == 85 = issue Undo
  | k == 37 = issue (MoveSel (-1) 0)
  | k == 39 = issue (MoveSel 1 0)
  | k == 38 = issue (MoveSel 0 (-1))
  | k == 40 = issue (MoveSel 0 1)
  | otherwise = pure ()
-----------------------------------------------------------------------------
enterDigit :: Int -> Fx
enterDigit d = do
  m <- get
  case (m ^. phase, m ^. selected) of
    (Playing, Just i)
      | not (m ^. showHelp)
      , c <- (m ^. cells) !! i
      , not (c ^. given) ->
          if
            | m ^. notesMode && not (isJust (c ^. value)) -> do
                let ns = if d `elem` c ^. notes
                      then delete d (c ^. notes)
                      else insertSorted d (c ^. notes)
                history %= ([(i, c)] :)
                cells %= setCells [(i, c & notes .~ ns)]
                playFx "note"
            | c ^. value == Just d -> do
                history %= ([(i, c)] :)
                cells %= setCells [(i, c & value .~ Nothing)]
                playFx "erase"
            | otherwise -> do
                -- place the digit; only a visible duplicate counts as a
                -- mistake — disagreeing with the hidden solution does not
                placeDigitAt i d
                m' <- get
                let clash = i `elem` conflicted (map (^. value) (m' ^. cells))
                if clash
                  then do
                    mistakes += 1
                    shakeIx .= Just i
                    playFx "deny"
                  else playFx "clack"
                checkWin
    _ -> pure ()
  where
    insertSorted x xs = takeWhile (< x) xs ++ [x] ++ dropWhile (< x) xs
-----------------------------------------------------------------------------
-- | Write digit @d@ into cell @i@, sweep it out of peer pencil marks,
-- and record one undo entry.
placeDigitAt :: Int -> Int -> Fx
placeDigitAt i d = do
  m <- get
  let c = (m ^. cells) !! i
      peerFixes =
        [ (j, pc)
        | j <- peersOf i
        , let pc = (m ^. cells) !! j
        , d `elem` pc ^. notes
        ]
  history %= (((i, c) : peerFixes) :)
  cells %= setCells
    ( (i, c & value .~ Just d & notes .~ [])
    : [ (j, pc & notes %~ delete d) | (j, pc) <- peerFixes ]
    )
  lastPlaced .= Just i
  shakeIx .= Nothing
  animSeq += 1
-----------------------------------------------------------------------------
-- | Hints place the digit from the hidden solution.
placeCorrect :: Int -> Int -> Fx
placeCorrect i d = do
  placeDigitAt i d
  checkWin
-----------------------------------------------------------------------------
checkWin :: Fx
checkWin = do
  m <- get
  when (isWon m) $ do
    phase .= Won
    playFx "win"
-----------------------------------------------------------------------------
-- | Full and clash-free: with a unique solution this is the solution.
isWon :: Model -> Bool
isWon m =
  all (isJust . (^. value)) (m ^. cells)
    && null (conflicted (map (^. value) (m ^. cells)))
-----------------------------------------------------------------------------
playFx :: MisoString -> Fx
playFx name = do
  m <- get
  io_ (playSound (m ^. soundOn) name)
-----------------------------------------------------------------------------
-- * View
-----------------------------------------------------------------------------
viewModel :: Model -> View () () Model Action
viewModel m = case m ^. phase of
  Title -> H.div_ []
    ( titleView : [ helpOverlay | m ^. showHelp ] )
  _ -> H.div_ []
    ( [ topbar m
      , H.div_ [ HP.class_ "gameWrap" ] [ boardView m, padView m ]
      ]
      ++ [ winOverlay m | m ^. phase == Won ]
      ++ [ helpOverlay | m ^. showHelp ]
    )
-----------------------------------------------------------------------------
titleView :: View () () Model Action
titleView = H.div_ [ HP.class_ "titleWrap" ] $
  [ deco v x y r dl
  | (v, x, y, r, dl) <-
      [ ("5", "8%",  "16%", "-9deg",  "0s")
      , ("3", "86%", "14%", "7deg",   ".9s")
      , ("9", "13%", "72%", "6deg",   "1.7s")
      , ("1", "84%", "70%", "-6deg",  ".4s")
      , ("7", "24%", "36%", "12deg",  "2.3s")
      , ("2", "74%", "42%", "-12deg", "1.2s")
      ]
  ] ++
  [ H.h1_ [ HP.class_ "titleH" ] [ text "数独" ]
  , H.div_ [ HP.class_ "titleSub" ] [ text "MISO SUDOKU" ]
  , H.div_ [ HP.class_ "diffRow" ]
      [ H.button_
          [ HP.class_ "diffBtn", HE.onClick (PickDifficulty d) ]
          [ H.span_ [ HP.class_ "diffK" ] [ text (diffKanji d) ]
          , text (diffLabel d)
          ]
      | d <- [minBound .. maxBound]
      ]
  , H.button_
      [ HP.class_ "btn ghost howBtn", HE.onClick ShowHelp ]
      [ text "HOW TO PLAY" ]
  , H.div_ [ HP.class_ "titleHint" ]
      [ text "every puzzle has one solution · built with miso 🍜" ]
  ]
  where
    deco v x y r dl = H.div_
      [ HP.class_ "floatCell"
      , CSS.style_
          [ CSS.left x, CSS.top y, "--fr" =: r, CSS.animationDelay dl ]
      ] [ text v ]
    diffLabel = \case
      Easy -> "EASY"
      Medium -> "MEDIUM"
      Hard -> "HARD"
      Expert -> "EXPERT"
    diffKanji = \case
      Easy -> "易"
      Medium -> "中"
      Hard -> "難"
      Expert -> "極"
-----------------------------------------------------------------------------
topbar :: Model -> View () () Model Action
topbar m = H.div_ [ HP.class_ "topbar" ]
  [ H.div_ [ HP.class_ "brand" ]
      [ text "MISO SUDOKU "
      , H.small_ [] [ text ("· " <> difficultyName (m ^. difficulty)) ]
      ]
  , H.div_ [ HP.class_ "hudStats" ]
      [ stat "⏱" (formatTime (m ^. timeSec))
      , stat "✕" (ms (m ^. mistakes) <> " mistakes")
      , stat "💡" (ms (m ^. hintsUsed) <> " hints")
      ]
  , H.div_ [ HP.class_ "tbBtns" ]
      [ iconBtn ShowHelp "❓" "how to play"
      , iconBtn ToggleSound
          (if m ^. soundOn then "🔊" else "🔇")
          (if m ^. soundOn then "sound" else "muted")
      , iconBtn NewGame "↺" "new game"
      ]
  ]
  where
    stat icon v = H.span_ [] [ text (icon <> " "), H.b_ [] [ text v ] ]
    iconBtn act icon label = H.button_
      [ HP.class_ "iconBtn", HE.onClick act ]
      [ text icon
      , H.span_ [ HP.class_ "btnLabel" ] [ text (" " <> label) ]
      ]
-----------------------------------------------------------------------------
boardView :: Model -> View () () Model Action
boardView m = H.div_ [ HP.class_ "sboard" ]
  [ H.div_ [ HP.class_ "sgrid" ] (map cellView [0 .. 80]) ]
  where
    sel = m ^. selected
    selVal = do
      i <- sel
      ((m ^. cells) !! i) ^. value
    conf = conflicted (map (^. value) (m ^. cells))
    doneBoxes = completedBoxes (map (^. value) (m ^. cells))
    alt = odd (m ^. animSeq)
    won = m ^. phase == Won
    cellView i = H.div_
      ( HP.class_ cls
      : HE.onClick (SelectCell i)
      : waveDelay
      )
      content
      where
        c = (m ^. cells) !! i
        v = c ^. value
        inConf = i `elem` conf
        isPeer = case sel of
          Just s -> s /= i &&
            (rowOf s == rowOf i || colOf s == colOf i || boxOf s == boxOf i)
          Nothing -> False
        cls = joinCls
          [ "scell"
          , clsWhen (colOf i `elem` [2, 5]) "b3r"
          , clsWhen (rowOf i `elem` [2, 5]) "b3b"
          , clsWhen (c ^. given) "gv"
          , clsWhen (not (c ^. given) && isJust v) "us"
          , clsWhen (inConf && not (c ^. given)) "er"
          , clsWhen (inConf && c ^. given) "clash"
          , clsWhen (sel == Just i) "sel"
          , clsWhen (isPeer && not won) "peer"
          , clsWhen (isJust v && v == selVal && sel /= Just i && not won) "same"
          , clsWhen (boxOf i `elem` doneBoxes && not won) "boxDone"
          , clsWhen (m ^. shakeIx == Just i) "shakeC"
          , clsWhen (m ^. shakeIx == Just i && alt) "alt"
          , clsWhen won "winWave"
          ]
        waveDelay =
          [ CSS.style_
              [ CSS.animationDelay
                  (ms ((rowOf i + colOf i) * 45) <> "ms") ]
          | won
          ]
        content = case v of
          Just d -> [ H.span_ [ HP.class_ "val" ] [ text (ms d) ] ]
          Nothing ->
            [ H.div_ [ HP.class_ "noteGrid" ]
                [ H.span_ []
                    [ text (if d `elem` c ^. notes then ms d else "") ]
                | d <- [1 .. 9]
                ]
            | not (null (c ^. notes))
            ]
-----------------------------------------------------------------------------
padView :: Model -> View () () Model Action
padView m = H.div_ [ HP.class_ "pad" ]
  [ H.div_ [ HP.class_ "digits" ]
      [ H.button_
          [ HP.class_ (joinCls [ "digBtn", clsWhen (left d <= 0) "done" ])
          , HE.onClick (Enter d)
          ]
          [ text (ms d)
          , H.small_ [] [ text (ms (max 0 (left d))) ]
          ]
      | d <- [1 .. 9]
      ]
  , H.div_ [ HP.class_ "ctrls" ]
      [ ctrl ToggleNotes
          (if m ^. notesMode then "ctrlBtn on" else "ctrlBtn")
          ("✏️ notes" <> (if m ^. notesMode then " ON" else ""))
      , ctrl Erase "ctrlBtn" "⌫ erase"
      , ctrl Hint
          (if hintsLeft <= 0 then "ctrlBtn off" else "ctrlBtn")
          ("💡 hint ·" <> ms hintsLeft)
      , ctrl Undo "ctrlBtn" "↩ undo"
      ]
  ]
  where
    hintsLeft = max 0 (hintLimit - m ^. hintsUsed)
    left d = 9 - length [ () | c <- m ^. cells, c ^. value == Just d ]
    ctrl act cls label =
      H.button_ [ HP.class_ cls, HE.onClick act ] [ text label ]
-----------------------------------------------------------------------------
winOverlay :: Model -> View () () Model Action
winOverlay m = H.div_ [ HP.class_ "overlay" ]
  [ H.div_ [ HP.class_ "panel" ]
      [ H.div_ [ HP.class_ "seal" ] [ text "正解" ]
      , H.div_ [ HP.class_ "winTitle" ] [ text "SOLVED" ]
      , H.div_ [ HP.class_ "winSub" ] [ text "graded by the red pen — correct" ]
      , statRow 0 "Difficulty" (difficultyName (m ^. difficulty))
      , statRow 1 "Time" (formatTime (m ^. timeSec))
      , statRow 2 "Mistakes" (ms (m ^. mistakes))
      , statRow 3 "Hints" (ms (m ^. hintsUsed))
      , H.button_ [ HP.class_ "btn", HE.onClick NewGame ] [ text "NEW GAME" ]
      ]
  ]
  where
    statRow :: Int -> MisoString -> MisoString -> View () () Model Action
    statRow k label v = H.div_
      [ HP.class_ "statRow"
      , CSS.style_ [ CSS.animationDelay (ms (200 + k * 130) <> "ms") ]
      ]
      [ H.span_ [] [ text label ], H.b_ [] [ text v ] ]
-----------------------------------------------------------------------------
helpOverlay :: View () () Model Action
helpOverlay = H.div_ [ HP.class_ "overlay help" ]
  [ H.div_ [ HP.class_ "panel helpPanel" ]
      [ H.button_ [ HP.class_ "helpClose", HE.onClick CloseHelp ] [ text "✕" ]
      , H.div_ [ HP.class_ "helpH" ] [ text "HOW TO PLAY" ]
      , H.div_ [ HP.class_ "helpSub" ] [ text "sudoku · one rule, one solution" ]
      , sec "THE OBJECTIVE"
      , para $
          "Fill the 9×9 grid so that every row, every column, and every "
          <> "3×3 box contains each digit from 1 to 9 exactly once. The "
          <> "puzzle starts with some digits given — they never move."
      , sec "CONTROLS"
      , para $
          "Drag a digit from the pad onto a cell, or tap a cell and then "
          <> "a digit (or type 1–9). Entering the same digit again clears "
          <> "it. Turn on ✏️ notes to jot small candidate digits into empty "
          <> "cells — placing a real digit sweeps that digit out of the "
          <> "notes around it. Arrow keys move, backspace erases, N "
          <> "toggles notes."
      , sec "READING THE BOARD"
      , legend "7" "gvL" "printed digits — the givens, fixed"
      , legend "4" "usL" "your digits, in pencil"
      , legend "9" "erL" "marked in red — it duplicates a digit it can see"
      , para $
          "Only visible clashes get the red pen. A digit that merely "
          <> "disagrees with the hidden solution is left alone — you'll "
          <> "meet it later."
      , sec "HELPERS"
      , para $
          "💡 hint fills the selected (or first unsolved) cell correctly — "
          <> "you get three per game · ↩ undo rewinds as far as you like · "
          <> "every puzzle is generated with exactly one solution, and the "
          <> "clock pauses while you read this."
      , H.button_ [ HP.class_ "btn", HE.onClick CloseHelp ] [ text "GOT IT" ]
      ]
  ]
  where
    sec s = H.div_ [ HP.class_ "helpSec" ] [ text s ]
    para s = H.p_ [ HP.class_ "helpP" ] [ text s ]
    legend d extra caption = H.div_ [ HP.class_ "legendRow" ]
      [ H.div_ [ HP.class_ ("legendCell " <> extra) ] [ text d ]
      , H.span_ [ HP.class_ "helpCap" ] [ text caption ]
      ]
-----------------------------------------------------------------------------
joinCls :: [MisoString] -> MisoString
joinCls = mconcat . map (<> " ")
-----------------------------------------------------------------------------
clsWhen :: Bool -> MisoString -> MisoString
clsWhen True c = c
clsWhen False _ = ""
