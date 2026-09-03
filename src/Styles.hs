-----------------------------------------------------------------------------
-- | The look of the board: a paper puzzle sheet on an indigo desk.
-- Printed givens in slab-serif ink, your digits in pencil, and the red
-- pen reserved for grading — clashes and the winning 正解 stamp.
-----------------------------------------------------------------------------
module Styles (skin) where
-----------------------------------------------------------------------------
import           Miso ((=:))
import qualified Miso.CSS as CSS
import           Miso.CSS
  ( StyleSheet, sheet_, selector_, keyframes_, from_, to_, at, pct
  , media_, rule_, screen_, and_, maxWidth_, maxHeight_, px
  )
import           Miso.CSS.Types (MediaQuery(..))
import           Miso.CSS.Color hiding (ivory)
import           Miso.String (MisoString)
-----------------------------------------------------------------------------
-- palette: ink, pencil, paper, desk, and one red pen
inkC, pencil, shu, paper, mat, mist, deskText :: Color
inkC     = RGB 36 48 78    -- printed digits, headings on paper
pencil   = RGB 90 106 138  -- your digits
shu      = RGB 199 62 58   -- the red pen: clashes + the 正解 seal
paper    = RGB 247 245 238
mat      = RGB 240 237 227
mist     = RGB 139 153 184 -- muted text on the desk
deskText = RGB 232 236 244
-----------------------------------------------------------------------------
serifStack :: MisoString
serifStack = "'Zilla Slab', 'Noto Serif JP', 'Hiragino Mincho ProN', 'Yu Mincho', Georgia, serif"
-----------------------------------------------------------------------------
skin :: StyleSheet
skin = sheet_
  [ selector_ ":root"
      [ "--bs" =: "min(560px, calc(100dvh - 250px), 92vw)"
      , "--serif" =: serifStack
      ]
  , selector_ "*" [ CSS.boxSizing "border-box" ]
  , selector_ "html, body"
      [ CSS.margin "0", CSS.height "100%", CSS.overflow "hidden" ]
  , selector_ "body"
      [ CSS.background deskBackground
      , CSS.color deskText
      , CSS.fontFamily "'Avenir Next', 'Segoe UI', system-ui, sans-serif"
      , CSS.userSelect "none"
      , "-webkit-tap-highlight-color" =: "transparent"
      , "-webkit-text-size-adjust" =: "100%"
      , "overscroll-behavior" =: "none"
      ]
  , selector_ "button:focus-visible"
      [ CSS.outline "2px solid #C73E3A", CSS.outlineOffset "2px" ]
  -- top chrome ------------------------------------------------------------
  , selector_ ".topbar"
      [ CSS.position "fixed"
      , "inset" =: "0 0 auto 0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "space-between"
      , CSS.padding "10px 18px"
      , CSS.zIndex 90
      , CSS.pointerEvents "none"
      , CSS.gap "12px"
      ]
  , selector_ ".topbar > *" [ CSS.pointerEvents "auto" ]
  , selector_ ".brand"
      [ CSS.fontFamily "var(--serif)"
      , CSS.fontWeight "700"
      , CSS.letterSpacing ".12em"
      , CSS.fontSize "16px"
      , CSS.color paper
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".brand small"
      [ CSS.color mist, CSS.fontWeight "500", CSS.letterSpacing ".08em"
      , CSS.fontFamily "'Avenir Next', 'Segoe UI', system-ui, sans-serif"
      , CSS.fontSize "12px"
      ]
  , selector_ ".hudStats"
      [ CSS.display "flex"
      , CSS.gap "clamp(8px, 2vw, 26px)"
      , CSS.alignItems "center"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".1em"
      , CSS.color mist
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".hudStats b"
      [ CSS.color deskText
      , "font-variant-numeric" =: "tabular-nums"
      , CSS.fontWeight "700"
      ]
  , selector_ ".tbBtns"
      [ CSS.display "flex", CSS.gap "8px"
      , CSS.flexWrap "wrap", CSS.justifyContent "flex-end" ]
  , selector_ ".iconBtn"
      [ CSS.background "rgba(255,255,255,.06)"
      , CSS.border "1px solid rgba(255,255,255,.14)"
      , CSS.color deskText
      , CSS.borderRadius (px 8)
      , CSS.padding "7px 14px"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".06em"
      , CSS.cursor "pointer"
      , CSS.backdropFilter "blur(10px)"
      , CSS.transition "transform .15s ease, background .2s ease, border-color .2s ease"
      , CSS.whiteSpace "nowrap"
      , "touch-action" =: "manipulation"
      ]
  -- layout ------------------------------------------------------------------
  , selector_ ".gameWrap"
      [ CSS.position "fixed"
      , "inset" =: "52px 0 10px 0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.gap "clamp(14px, 3vw, 40px)"
      ]
  -- board: a paper sheet ------------------------------------------------------
  , selector_ ".sboard"
      [ CSS.width "var(--bs)"
      , CSS.height "var(--bs)"
      , CSS.padding "12px"
      , CSS.backgroundColor mat
      , CSS.borderRadius (px 4)
      , CSS.boxShadow sheetShadow
      , CSS.animation "riseIn .5s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".sgrid"
      [ CSS.width "100%"
      , CSS.height "100%"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(9, 1fr)"
      , CSS.gridTemplateRows "repeat(9, 1fr)"
      , CSS.border "2px solid #24304E"
      , CSS.borderRadius (px 2)
      , CSS.overflow "hidden"
      , CSS.background "#FBFAF3"
      ]
  , selector_ ".scell"
      [ CSS.position "relative"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.borderRight "1px solid rgba(36,48,78,.22)"
      , CSS.borderBottom "1px solid rgba(36,48,78,.22)"
      , CSS.cursor "pointer"
      , CSS.fontFamily "var(--serif)"
      , CSS.fontSize "calc(var(--bs) / 15.5)"
      , CSS.fontWeight "500"
      , CSS.color pencil
      , CSS.transition "background .12s ease, box-shadow .12s ease"
      , "touch-action" =: "manipulation"
      , "font-variant-numeric" =: "tabular-nums"
      ]
  , selector_ ".scell.b3r" [ CSS.borderRight "2px solid #24304E" ]
  , selector_ ".scell.b3b" [ CSS.borderBottom "2px solid #24304E" ]
  , selector_ ".scell.gv" [ CSS.color inkC, CSS.fontWeight "700" ]
  , selector_ ".scell.us" [ CSS.color pencil, CSS.fontWeight "500" ]
  , selector_ ".scell.er"
      [ CSS.color shu
      , CSS.backgroundColor (RGBA 199 62 58 0.07)
      , CSS.boxShadow "inset 0 -6px 0 -3px rgba(199,62,58,.55)"
      ]
  , selector_ ".scell.clash" [ CSS.backgroundColor (RGBA 199 62 58 0.08) ]
  , selector_ ".scell.peer" [ CSS.backgroundColor (RGBA 36 48 78 0.05) ]
  , selector_ ".scell.same"
      [ CSS.backgroundColor (RGBA 36 48 78 0.14), CSS.fontWeight "800" ]
  , selector_ ".scell.sel"
      [ CSS.backgroundColor (RGBA 36 48 78 0.10)
      , CSS.boxShadow "inset 0 0 0 2px #24304E"
      ]
  , selector_ ".scell.sel.er"
      [ CSS.boxShadow "inset 0 0 0 2px #24304E, inset 0 -6px 0 -3px rgba(199,62,58,.55)" ]
  , selector_ ".scell.dropTarget"
      [ CSS.backgroundColor (RGBA 36 48 78 0.08)
      , CSS.outline "2px dashed #24304E"
      , CSS.outlineOffset "-4px"
      ]
  , selector_ ".scell .val" [ CSS.animation "popIn .18s cubic-bezier(.2,.9,.3,1.3) backwards" ]
  , selector_ ".scell.shakeC" [ "animation" =: "shakeA .4s ease" ]
  , selector_ ".scell.shakeC.alt" [ "animation-name" =: "shakeA2" ]
  , selector_ ".scell.winWave" [ "animation" =: "gradeFlash .8s ease backwards" ]
  , selector_ ".noteGrid"
      [ CSS.position "absolute"
      , "inset" =: "6%"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(3, 1fr)"
      , CSS.gridTemplateRows "repeat(3, 1fr)"
      , CSS.fontSize "calc(var(--bs) / 42)"
      , CSS.fontWeight "500"
      , CSS.fontFamily "var(--serif)"
      , CSS.color (RGBA 90 106 138 0.85)
      , CSS.pointerEvents "none"
      ]
  , selector_ ".noteGrid span"
      [ CSS.display "flex", CSS.alignItems "center", CSS.justifyContent "center" ]
  -- pad: paper chips -----------------------------------------------------------
  , selector_ ".pad"
      [ CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.gap "14px"
      , CSS.width "clamp(180px, 22vw, 236px)"
      , CSS.animation "riseIn .5s .1s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".digits"
      [ CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(3, 1fr)"
      , CSS.gap "9px"
      ]
  , selector_ ".digBtn"
      [ CSS.position "relative"
      , CSS.background "#FBFAF3"
      , CSS.border "1px solid #D8D4C4"
      , CSS.borderRadius (px 8)
      , CSS.padding "9px 0 16px"
      , CSS.fontFamily "var(--serif)"
      , CSS.fontSize "26px"
      , CSS.fontWeight "700"
      , CSS.color inkC
      , CSS.cursor "grab"
      , CSS.boxShadow "0 2px 0 #d9d5c6, 0 6px 14px rgba(8,12,26,.45)"
      , CSS.transition "transform .15s cubic-bezier(.2,.9,.3,1.4), box-shadow .15s ease, opacity .2s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".digBtn:active" [ CSS.cursor "grabbing", CSS.transform "translateY(1px) scale(.97)" ]
  , selector_ ".digBtn small"
      [ CSS.position "absolute"
      , "inset" =: "auto 0 4px 0"
      , CSS.fontSize "10px"
      , CSS.fontWeight "600"
      , CSS.fontFamily "'Avenir Next', 'Segoe UI', system-ui, sans-serif"
      , CSS.color (RGB 138 148 168)
      ]
  , selector_ ".digBtn.done" [ CSS.opacity 0.3, CSS.cursor "default" ]
  , selector_ ".digBtn.dragging"
      [ CSS.opacity 0.45
      , CSS.border "1px dashed #8A94A8"
      , CSS.transform "scale(.95)"
      ]
  , selector_ ".ctrls"
      [ CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(2, 1fr)"
      , CSS.gap "9px"
      ]
  , selector_ ".ctrlBtn"
      [ CSS.background "rgba(255,255,255,.07)"
      , CSS.border "1px solid rgba(255,255,255,.16)"
      , CSS.color deskText
      , CSS.borderRadius (px 8)
      , CSS.padding "10px 6px"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".05em"
      , CSS.fontFamily "inherit"
      , CSS.cursor "pointer"
      , CSS.backdropFilter "blur(10px)"
      , CSS.transition "transform .15s ease, background .2s ease, border-color .2s ease, color .2s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".ctrlBtn.on"
      [ CSS.background "rgba(247,245,238,.92)"
      , CSS.color inkC
      , CSS.borderColor paper
      , CSS.fontWeight "700"
      ]
  , selector_ ".ctrlBtn.off" [ CSS.opacity 0.4, CSS.cursor "default" ]
  -- buttons -------------------------------------------------------------------
  , selector_ ".btn"
      [ CSS.padding "12px 28px"
      , CSS.borderRadius (px 8)
      , CSS.border "none"
      , CSS.backgroundColor inkC
      , CSS.color paper
      , CSS.fontWeight "700"
      , CSS.fontFamily "var(--serif)"
      , CSS.fontSize "16px"
      , CSS.letterSpacing ".12em"
      , CSS.cursor "pointer"
      , CSS.boxShadow "0 6px 18px rgba(8,12,26,.4)"
      , CSS.transition "transform .15s ease, box-shadow .15s ease, filter .15s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".btn:active" [ CSS.transform "translateY(0) scale(.98)" ]
  , selector_ ".btn.ghost"
      [ CSS.background "rgba(255,255,255,.07)"
      , CSS.color deskText
      , CSS.border "1px solid rgba(255,255,255,.2)"
      , CSS.backdropFilter "blur(8px)"
      ]
  , media_ (MediaQuery "(hover: hover)")
      [ rule_ ".iconBtn:hover"
          [ CSS.background "rgba(255,255,255,.13)"
          , CSS.borderColor (RGBA 247 245 238 0.4)
          , CSS.transform "translateY(-1px)"
          ]
      , rule_ ".ctrlBtn:hover"
          [ CSS.background "rgba(255,255,255,.13)"
          , CSS.borderColor (RGBA 247 245 238 0.4)
          , CSS.transform "translateY(-1px)"
          ]
      , rule_ ".btn:hover"
          [ CSS.transform "translateY(-2px)"
          , CSS.boxShadow "0 10px 26px rgba(8,12,26,.5)"
          , CSS.filter "brightness(1.12)"
          ]
      , rule_ ".digBtn:hover:not(.done)"
          [ CSS.transform "translateY(-3px)"
          , CSS.boxShadow "0 2px 0 #d9d5c6, 0 12px 22px rgba(8,12,26,.5)"
          ]
      , rule_ ".diffBtn:hover"
          [ CSS.transform "translateY(-3px)"
          , CSS.boxShadow "0 3px 0 #d9d5c6, 0 14px 26px rgba(8,12,26,.55)"
          ]
      ]
  -- overlays: paper panels ------------------------------------------------------
  , selector_ ".overlay"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.background "rgba(10,14,28,.62)"
      , CSS.backdropFilter "blur(7px)"
      , CSS.zIndex 100
      , CSS.animation "overlayIn .25s ease"
      ]
  , selector_ ".panel"
      [ CSS.background "linear-gradient(180deg, #FBFAF3, #F1EEE3)"
      , CSS.color inkC
      , CSS.borderRadius (px 6)
      , CSS.padding "30px 44px"
      , CSS.boxShadow "9px 10px 0 -4px #d9d5c6, 0 40px 100px rgba(0,0,0,.6)"
      , CSS.textAlign "center"
      , CSS.animation "panelIn .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      , CSS.maxWidth "min(92vw, 560px)"
      ]
  , selector_ ".seal"
      [ CSS.display "inline-block"
      , CSS.margin "0 auto 12px"
      , CSS.padding "8px 14px 8px 20px"
      , CSS.border "3px solid #C73E3A"
      , CSS.borderRadius (px 10)
      , CSS.color shu
      , CSS.fontFamily "var(--serif)"
      , CSS.fontWeight "900"
      , CSS.fontSize "30px"
      , CSS.letterSpacing ".3em"
      , CSS.background (renderColor (RGBA 199 62 58 0.05))
      , CSS.transform "rotate(-8deg)"
      , CSS.animation "stampIn .5s .2s cubic-bezier(.34,1.56,.64,1) backwards"
      ]
  , selector_ ".winTitle"
      [ CSS.fontFamily "var(--serif)"
      , CSS.fontSize "clamp(26px, 5vmin, 38px)"
      , CSS.fontWeight "700"
      , CSS.letterSpacing ".2em"
      , CSS.color inkC
      , CSS.marginBottom "6px"
      ]
  , selector_ ".winSub"
      [ CSS.color (RGB 122 132 151)
      , CSS.letterSpacing ".08em"
      , CSS.fontSize "14px"
      , CSS.marginBottom "18px"
      ]
  , selector_ ".statRow"
      [ CSS.display "flex"
      , CSS.justifyContent "space-between"
      , CSS.gap "60px"
      , CSS.padding "8px 4px"
      , CSS.fontSize "16px"
      , CSS.color (RGB 122 132 151)
      , CSS.borderBottom "1px solid rgba(36,48,78,.14)"
      , CSS.animation "riseIn .4s ease backwards"
      ]
  , selector_ ".statRow b"
      [ CSS.color inkC, "font-variant-numeric" =: "tabular-nums"
      , CSS.fontFamily "var(--serif)" ]
  , selector_ ".panel .btn" [ CSS.marginTop "22px" ]
  -- how-to-play modal ---------------------------------------------------------
  , selector_ ".overlay.help"
      [ CSS.zIndex 120
      , CSS.alignItems "flex-start"
      , CSS.padding "min(7vh, 60px) 14px 14px"
      ]
  , selector_ ".helpPanel"
      [ CSS.textAlign "left"
      , CSS.maxWidth "min(94vw, 640px)"
      , CSS.maxHeight "min(86dvh, 780px)"
      , CSS.overflowY "auto"
      , CSS.position "relative"
      , CSS.padding "26px 34px 28px"
      , CSS.animation "dropIn .45s cubic-bezier(.2,.9,.25,1.15) backwards"
      , "overscroll-behavior" =: "contain"
      , "scrollbar-width" =: "thin"
      , "scrollbar-color" =: "rgba(36,48,78,.35) transparent"
      ]
  , selector_ ".helpPanel::-webkit-scrollbar" [ CSS.width "8px" ]
  , selector_ ".helpPanel::-webkit-scrollbar-thumb"
      [ CSS.background "rgba(36,48,78,.3)", CSS.borderRadius (px 8) ]
  , selector_ ".helpPanel::-webkit-scrollbar-track" [ CSS.background "transparent" ]
  , selector_ ".helpClose"
      [ CSS.position "absolute"
      , CSS.top "10px"
      , CSS.right "14px"
      , CSS.background "none"
      , CSS.border "none"
      , CSS.color (RGB 122 132 151)
      , CSS.fontSize "22px"
      , CSS.cursor "pointer"
      , CSS.padding "6px 8px"
      , CSS.transition "color .15s ease, transform .15s ease"
      ]
  , selector_ ".helpClose:hover" [ CSS.color shu, CSS.transform "scale(1.15)" ]
  , selector_ ".helpH"
      [ CSS.fontFamily "var(--serif)"
      , CSS.fontSize "24px", CSS.fontWeight "700"
      , CSS.letterSpacing ".14em", CSS.color inkC, CSS.margin "0 0 2px" ]
  , selector_ ".helpSub"
      [ CSS.color (RGB 122 132 151), CSS.fontSize "13px"
      , CSS.letterSpacing ".1em", CSS.marginBottom "10px" ]
  , selector_ ".helpSec"
      [ CSS.color shu, CSS.fontSize "12px", CSS.fontWeight "800"
      , CSS.letterSpacing ".24em", CSS.margin "18px 0 4px" ]
  , selector_ ".helpP"
      [ CSS.color (RGB 58 67 86), CSS.fontSize "14px"
      , CSS.lineHeight "1.6", CSS.margin "4px 0" ]
  , selector_ ".legendRow"
      [ CSS.display "flex", CSS.alignItems "center"
      , CSS.gap "10px", CSS.margin "8px 0" ]
  , selector_ ".legendCell"
      [ CSS.width "34px", CSS.height "34px"
      , CSS.display "flex", CSS.alignItems "center", CSS.justifyContent "center"
      , CSS.background "#FBFAF3"
      , CSS.border "1px solid rgba(36,48,78,.25)"
      , CSS.borderRadius (px 4)
      , CSS.fontFamily "var(--serif)"
      , CSS.fontSize "19px", CSS.fontWeight "700"
      , "flex" =: "0 0 auto"
      ]
  , selector_ ".legendCell.gvL" [ CSS.color inkC ]
  , selector_ ".legendCell.usL" [ CSS.color pencil, CSS.fontWeight "500" ]
  , selector_ ".legendCell.erL"
      [ CSS.color shu
      , CSS.boxShadow "inset 0 -5px 0 -2px rgba(199,62,58,.55)"
      ]
  , selector_ ".helpCap" [ CSS.color (RGB 58 67 86), CSS.fontSize "13.5px" ]
  -- title screen ---------------------------------------------------------------
  , selector_ ".titleWrap"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.gap "10px"
      , CSS.zIndex 110
      , CSS.background deskBackground
      , CSS.overflow "hidden"
      ]
  , selector_ ".floatCell"
      [ CSS.position "absolute"
      , CSS.width "clamp(40px, 5.4vmin, 56px)"
      , CSS.height "clamp(40px, 5.4vmin, 56px)"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.background "#FBFAF3"
      , CSS.borderRadius (px 6)
      , CSS.fontFamily "var(--serif)"
      , CSS.fontSize "clamp(20px, 2.8vmin, 30px)"
      , CSS.fontWeight "700"
      , CSS.color inkC
      , CSS.boxShadow "4px 5px 0 -1px rgba(217,213,198,.55), 0 10px 24px rgba(0,0,0,.5)"
      , CSS.opacity 0.5
      , CSS.animation "floaty 7s ease-in-out infinite"
      , CSS.pointerEvents "none"
      ]
  , selector_ ".titleH"
      [ CSS.fontSize "clamp(52px, 12vmin, 110px)"
      , CSS.fontWeight "700"
      , CSS.fontFamily "var(--serif)"
      , CSS.color paper
      , CSS.textShadow "0 12px 40px rgba(0,0,0,.5)"
      , CSS.margin "0"
      , CSS.paddingBottom "10px"
      , CSS.borderBottom "4px solid rgba(199,62,58,.9)"
      , CSS.animation "riseIn .7s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".titleSub"
      [ CSS.letterSpacing ".5em"
      , CSS.color mist
      , CSS.fontSize "clamp(12px, 2vmin, 16px)"
      , CSS.marginBottom "22px"
      , CSS.animation "riseIn .7s .15s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".diffRow"
      [ CSS.display "flex"
      , CSS.gap "12px"
      , CSS.flexWrap "wrap"
      , CSS.justifyContent "center"
      , CSS.animation "riseIn .7s .3s cubic-bezier(.2,.9,.25,1.2) backwards"
      , CSS.padding "0 12px"
      ]
  , selector_ ".diffBtn"
      [ CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.alignItems "center"
      , CSS.gap "2px"
      , CSS.background "#FBFAF3"
      , CSS.border "1px solid #D8D4C4"
      , CSS.borderRadius (px 8)
      , CSS.padding "12px 22px 10px"
      , CSS.fontFamily "var(--serif)"
      , CSS.fontWeight "700"
      , CSS.fontSize "15px"
      , CSS.letterSpacing ".14em"
      , CSS.color inkC
      , CSS.cursor "pointer"
      , CSS.boxShadow "0 3px 0 #d9d5c6, 0 8px 18px rgba(8,12,26,.5)"
      , CSS.transition "transform .15s cubic-bezier(.2,.9,.3,1.4), box-shadow .15s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".diffK"
      [ CSS.color shu
      , CSS.fontSize "18px"
      , CSS.fontWeight "700"
      , CSS.letterSpacing "0"
      ]
  , selector_ ".howBtn"
      [ CSS.fontSize "13px"
      , CSS.padding "10px 30px"
      , CSS.marginTop "14px"
      , CSS.animation "riseIn .7s .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".titleHint"
      [ CSS.marginTop "18px"
      , CSS.color (RGB 100 113 143)
      , CSS.fontSize "12px"
      , CSS.letterSpacing ".14em"
      , CSS.animation "riseIn .7s .5s ease backwards"
      ]
  -- responsive ----------------------------------------------------------------
  , media_ (screen_ `and_` maxWidth_ (px 740))
      [ rule_ ":root"
          [ "--bs" =: "min(94vw, calc(100dvh - 320px))" ]
      , rule_ ".gameWrap"
          [ CSS.flexDirection "column"
          , "inset" =: "78px 0 8px 0"
          , CSS.gap "12px"
          , CSS.justifyContent "flex-start"
          ]
      , rule_ ".topbar"
          [ CSS.flexWrap "wrap"
          , CSS.padding "6px 8px"
          , CSS.justifyContent "center"
          , "row-gap" =: "4px"
          , CSS.gap "8px"
          ]
      , rule_ ".btnLabel" [ CSS.display "none" ]
      , rule_ ".iconBtn" [ CSS.padding "7px 11px", CSS.fontSize "15px" ]
      , rule_ ".hudStats" [ CSS.fontSize "12px" ]
      , rule_ ".pad"
          [ CSS.width "min(94vw, 460px)", CSS.gap "8px" ]
      , rule_ ".digits"
          [ CSS.gridTemplateColumns "repeat(9, 1fr)", CSS.gap "5px" ]
      , rule_ ".digBtn"
          [ CSS.fontSize "20px", CSS.padding "6px 0 14px", CSS.borderRadius (px 6) ]
      , rule_ ".ctrls"
          [ CSS.gridTemplateColumns "repeat(4, 1fr)", CSS.gap "5px" ]
      , rule_ ".ctrlBtn" [ CSS.padding "8px 4px", CSS.fontSize "12px" ]
      , rule_ ".panel" [ CSS.padding "22px 26px" ]
      , rule_ ".helpPanel" [ CSS.padding "18px 18px 20px" ]
      , rule_ ".overlay.help" [ CSS.padding "10px 8px 8px" ]
      , rule_ ".statRow" [ CSS.gap "30px" ]
      , rule_ ".diffBtn" [ CSS.padding "10px 16px 8px" ]
      ]
  , media_ (screen_ `and_` maxWidth_ (px 480))
      [ rule_ ".brand" [ CSS.display "none" ] ]
  , media_ (screen_ `and_` maxHeight_ (px 520))
      [ rule_ ":root" [ "--bs" =: "min(92vw, calc(100dvh - 90px))" ]
      , rule_ ".gameWrap" [ CSS.flexDirection "row", "inset" =: "46px 0 4px 0" ]
      , rule_ ".topbar" [ CSS.padding "4px 8px" ]
      , rule_ ".btnLabel" [ CSS.display "none" ]
      , rule_ ".brand" [ CSS.display "none" ]
      , rule_ ".pad" [ CSS.width "clamp(150px, 30vw, 210px)" ]
      ]
  , media_ (MediaQuery "(prefers-reduced-motion: reduce)")
      [ rule_ "*"
          [ "animation-duration" =: ".01ms"
          , "animation-iteration-count" =: "1"
          , "transition-duration" =: ".01ms"
          ]
      ]
  -- keyframes ------------------------------------------------------------------
  , keyframes_ "popIn"
      [ from_ [ CSS.transform "scale(.3)", CSS.opacity 0 ]
      , at (pct 65) [ CSS.transform "scale(1.15)", CSS.opacity 1 ]
      , to_ [ CSS.transform "scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "shakeA" shakeStops
  , keyframes_ "shakeA2" shakeStops
  , keyframes_ "gradeFlash"
      [ from_ [ CSS.backgroundColor (RGBA 199 62 58 0.0) ]
      , at (pct 40) [ CSS.backgroundColor (RGBA 199 62 58 0.28) ]
      , to_ [ CSS.backgroundColor (RGBA 199 62 58 0.0) ]
      ]
  , keyframes_ "stampIn"
      [ from_ [ CSS.transform "scale(2.1) rotate(-20deg)", CSS.opacity 0 ]
      , to_ [ CSS.transform "scale(1) rotate(-8deg)", CSS.opacity 1 ]
      ]
  , keyframes_ "overlayIn" [ from_ [ CSS.opacity 0 ], to_ [ CSS.opacity 1 ] ]
  , keyframes_ "panelIn"
      [ from_ [ CSS.transform "translateY(26px) scale(.92)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0) scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "dropIn"
      [ from_ [ CSS.transform "translateY(-52px) scale(.97)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0) scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "riseIn"
      [ from_ [ CSS.transform "translateY(18px)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0)", CSS.opacity 1 ]
      ]
  , keyframes_ "floaty"
      [ from_ [ CSS.transform "translateY(0) rotate(var(--fr, 0deg))" ]
      , at (pct 50) [ CSS.transform "translateY(-18px) rotate(var(--fr, 0deg))" ]
      , to_ [ CSS.transform "translateY(0) rotate(var(--fr, 0deg))" ]
      ]
  ]
  where
    shakeStops =
      [ from_ [ CSS.transform "translateX(0)" ]
      , at (pct 20) [ CSS.transform "translateX(-6px)" ]
      , at (pct 40) [ CSS.transform "translateX(5px)" ]
      , at (pct 60) [ CSS.transform "translateX(-4px)" ]
      , at (pct 80) [ CSS.transform "translateX(3px)" ]
      , to_ [ CSS.transform "translateX(0)" ]
      ]
-----------------------------------------------------------------------------
-- | Deep aizome-indigo desk under the paper.
deskBackground :: MisoString
deskBackground = mconcat
  [ "radial-gradient(120% 90% at 50% 10%, rgba(255,255,255,.05), rgba(0,0,0,0) 55%), "
  , "linear-gradient(180deg, #26324E 0%, #1B2440 55%, #131A2E 100%)"
  ]
-----------------------------------------------------------------------------
-- | The paper sheet: soft depth plus a hard stacked-page edge.
sheetShadow :: MisoString
sheetShadow = mconcat
  [ "inset 0 1px 0 rgba(255,255,255,.85), "
  , "9px 10px 0 -4px #0e1526, "
  , "9px 14px 34px rgba(0,0,0,.55)"
  ]
