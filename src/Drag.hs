-----------------------------------------------------------------------------
-- | Pointer-based drag & drop for the digit pad. HTML5 drag-and-drop
-- needs a synchronous @preventDefault@ on @dragover@ that delegated,
-- scheduler-routed handlers cannot provide — so the gesture runs on
-- pointer events instead, which also makes it work on touch screens.
--
-- The shim owns only the gesture and its visuals (ghost chip, drop
-- highlight); on release it replays the normal tap flow (select the
-- cell, press the digit), so game logic stays in the update function.
-----------------------------------------------------------------------------
module Drag
  ( dragInit
  ) where
-----------------------------------------------------------------------------
import           Miso.FFI.QQ (js)
-----------------------------------------------------------------------------
dragInit :: IO ()
dragInit = [js|
  if (!globalThis.__mdrag) {
    globalThis.__mdrag = true;
    var ghost = null, overCell = null, srcBtn = null;
    var sx = 0, sy = 0, active = false, moved = false;
    function cellAt(x, y) {
      var els = document.elementsFromPoint(x, y);
      for (var i = 0; i < els.length; i++) {
        if (els[i].classList && els[i].classList.contains('scell')) {
          return els[i];
        }
      }
      return null;
    }
    function clearHover() {
      if (overCell) {
        overCell.classList.remove('dropTarget');
        overCell = null;
      }
    }
    function cleanup() {
      if (ghost) { ghost.remove(); ghost = null; }
      if (srcBtn) { srcBtn.classList.remove('dragging'); }
      clearHover();
      active = false; moved = false; srcBtn = null;
    }
    document.addEventListener('pointerdown', function (e) {
      var btn = e.target && e.target.closest ? e.target.closest('.digBtn') : null;
      if (!btn || btn.classList.contains('done')) return;
      if (e.pointerType === 'mouse' && e.button !== 0) return;
      srcBtn = btn; sx = e.clientX; sy = e.clientY;
      active = true; moved = false;
    });
    document.addEventListener('pointermove', function (e) {
      if (!active) return;
      if (!moved) {
        if (Math.hypot(e.clientX - sx, e.clientY - sy) < 8) return;
        moved = true;
        ghost = srcBtn.cloneNode(true);
        ghost.classList.add('dragGhost');
        document.body.appendChild(ghost);
        srcBtn.classList.add('dragging');
      }
      if (ghost) {
        ghost.style.left = e.clientX + 'px';
        ghost.style.top = e.clientY + 'px';
      }
      var cell = cellAt(e.clientX, e.clientY);
      if (overCell !== cell) {
        clearHover();
        if (cell) {
          overCell = cell;
          cell.classList.add('dropTarget');
        }
      }
      if (e.cancelable) e.preventDefault();
    }, { passive: false });
    document.addEventListener('pointerup', function (e) {
      if (!active) return;
      if (!moved) { active = false; srcBtn = null; return; }
      var cell = cellAt(e.clientX, e.clientY);
      var btn = srcBtn;
      cleanup();
      if (cell && btn) {
        cell.click();
        btn.click();
      }
    });
    document.addEventListener('pointercancel', cleanup);
  }
|]
