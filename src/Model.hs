-----------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}
-----------------------------------------------------------------------------
-- | Core types for miso-sudoku, with lenses via "Miso.Lens.TH".
-----------------------------------------------------------------------------
module Model where
-----------------------------------------------------------------------------
import           Data.IntSet (IntSet)
import qualified Data.IntSet as IS
-----------------------------------------------------------------------------
import           Miso.Lens.TH (makeLenses)
-----------------------------------------------------------------------------
data Difficulty = Easy | Medium | Hard | Expert
  deriving (Eq, Ord, Show, Enum, Bounded)
-----------------------------------------------------------------------------
-- | One cell of the 9x9 grid.
data Cell = Cell
  { _value :: Maybe Int -- ^ 1..9
  , _given :: Bool      -- ^ part of the puzzle, immutable
  , _notes :: [Int]     -- ^ pencil marks, kept sorted
  } deriving (Eq, Show)
-----------------------------------------------------------------------------
makeLenses ''Cell
-----------------------------------------------------------------------------
emptyCell :: Cell
emptyCell = Cell Nothing False []
-----------------------------------------------------------------------------
data Phase = Title | Playing | Won
  deriving (Eq, Show)
-----------------------------------------------------------------------------
data Model = Model
  { _cells      :: [Cell] -- ^ 81 cells, row-major
  , _solution   :: [Int]  -- ^ 81 digits
  , _selected   :: Maybe Int
  , _notesMode  :: Bool
  , _mistakes   :: Int
  , _hintsUsed  :: Int
  , _history    :: [[(Int, Cell)]] -- ^ undo stack: changed cells per action
  , _timeSec    :: Int
  , _difficulty :: Difficulty
  , _phase      :: Phase
  , _soundOn    :: Bool
  , _showHelp   :: Bool
  , _animSeq    :: Int       -- ^ parity remounts pop/shake animations
  , _lastPlaced :: Maybe Int -- ^ cell that just received a value
  , _shakeIx    :: Maybe Int -- ^ cell shaking after a wrong entry
  , _heldKeys   :: IntSet    -- ^ previous keyboard state, for edge detect
  } deriving (Eq, Show)
-----------------------------------------------------------------------------
makeLenses ''Model
-----------------------------------------------------------------------------
data Action
  = NoOp
  | PickDifficulty Difficulty
  | PuzzleReady [Int] [Maybe Int] Difficulty
  | NewGame
  | SelectCell Int
  | Enter Int
  | Erase
  | ToggleNotes
  | Hint
  | Undo
  | MoveSel Int Int
  | Keys IntSet
  | Tick
  | ToggleSound
  | ShowHelp
  | CloseHelp
-----------------------------------------------------------------------------
initialModel :: Model
initialModel = Model
  { _cells      = replicate 81 emptyCell
  , _solution   = []
  , _selected   = Nothing
  , _notesMode  = False
  , _mistakes   = 0
  , _hintsUsed  = 0
  , _history    = []
  , _timeSec    = 0
  , _difficulty = Medium
  , _phase      = Title
  , _soundOn    = True
  , _showHelp   = False
  , _animSeq    = 0
  , _lastPlaced = Nothing
  , _shakeIx    = Nothing
  , _heldKeys   = IS.empty
  }
-----------------------------------------------------------------------------
-- | Hints available per game.
hintLimit :: Int
hintLimit = 3
-----------------------------------------------------------------------------
-- | Replace the cells at the given indices.
setCells :: [(Int, Cell)] -> [Cell] -> [Cell]
setCells updates cs =
  [ maybe c id (lookup i updates) | (i, c) <- zip [0 ..] cs ]
