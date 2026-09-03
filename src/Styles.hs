-----------------------------------------------------------------------------
-- | The look of the board: deep felt, one big ivory tile for the grid,
-- gold accents, glass panels, springy transitions.
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
import           Miso.CSS.Color hiding (gold)
import           Miso.String (MisoString)
-----------------------------------------------------------------------------
-- palette
gold, ink, inkSoft, leaf, errRed, ivoryText, sage, edge :: Color
gold      = RGB 232 201 106
ink       = RGB 36 58 102   -- given digits
inkSoft   = RGB 43 51 80
leaf      = RGB 47 125 79   -- user digits
errRed    = RGB 178 58 72
ivoryText = RGB 233 228 214
sage      = RGB 159 184 169
edge      = RGB 168 152 122 -- grid lines
-----------------------------------------------------------------------------
skin :: StyleSheet
skin = sheet_
  [ selector_ ":root"
      [ "--gold" =: renderColor gold
      , "--bs" =: "min(560px, calc(100dvh - 250px), 92vw)"
      ]
  , selector_ "*" [ CSS.boxSizing "border-box" ]
  , selector_ "html, body"
      [ CSS.margin "0", CSS.height "100%", CSS.overflow "hidden" ]
  , selector_ "body"
      [ CSS.background feltBackground
      , CSS.color ivoryText
      , CSS.fontFamily "'Avenir Next', 'Segoe UI', system-ui, sans-serif"
      , CSS.userSelect "none"
      , "-webkit-tap-highlight-color" =: "transparent"
      , "-webkit-text-size-adjust" =: "100%"
      , "overscroll-behavior" =: "none"
      ]
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
      [ CSS.fontWeight "800"
      , CSS.letterSpacing ".14em"
      , CSS.fontSize "15px"
      , CSS.color gold
      , CSS.textShadow "0 1px 10px rgba(0,0,0,.6)"
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".brand small"
      [ CSS.color sage, CSS.fontWeight "500", CSS.letterSpacing ".08em" ]
  , selector_ ".hudStats"
      [ CSS.display "flex"
      , CSS.gap "clamp(8px, 2vw, 26px)"
      , CSS.alignItems "center"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".1em"
      , CSS.color sage
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".hudStats b"
      [ CSS.color ivoryText
      , "font-variant-numeric" =: "tabular-nums"
      , CSS.fontWeight "700"
      ]
  , selector_ ".tbBtns"
      [ CSS.display "flex", CSS.gap "8px"
      , CSS.flexWrap "wrap", CSS.justifyContent "flex-end" ]
  , selector_ ".iconBtn"
      [ CSS.background "rgba(6,26,20,.55)"
      , CSS.border "1px solid rgba(255,255,255,.12)"
      , CSS.color ivoryText
      , CSS.borderRadius (px 999)
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
  -- board -------------------------------------------------------------------
  , selector_ ".sboard"
      [ CSS.width "var(--bs)"
      , CSS.height "var(--bs)"
      , CSS.padding "10px"
      , CSS.background tileFaceBg
      , CSS.borderRadius (px 18)
      , CSS.boxShadow "0 3px 0 #c9bc9c, 0 14px 34px rgba(0,0,0,.5), inset 0 1px 1px rgba(255,255,255,.9)"
      , CSS.animation "riseIn .5s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".sgrid"
      [ CSS.width "100%"
      , CSS.height "100%"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(9, 1fr)"
      , CSS.gridTemplateRows "repeat(9, 1fr)"
      , CSS.border ("2px solid " <> renderColor edge)
      , CSS.borderRadius (px 10)
      , CSS.overflow "hidden"
      , CSS.background "#fffdf3"
      ]
  , selector_ ".scell"
      [ CSS.position "relative"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.borderRight "1px solid rgba(168,152,122,.45)"
      , CSS.borderBottom "1px solid rgba(168,152,122,.45)"
      , CSS.cursor "pointer"
      , CSS.fontSize "calc(var(--bs) / 16)"
      , CSS.fontWeight "600"
      , CSS.color inkSoft
      , CSS.transition "background .12s ease"
      , "touch-action" =: "manipulation"
      , "font-variant-numeric" =: "tabular-nums"
      ]
  , selector_ ".scell.b3r" [ CSS.borderRight ("2px solid " <> renderColor edge) ]
  , selector_ ".scell.b3b" [ CSS.borderBottom ("2px solid " <> renderColor edge) ]
  , selector_ ".scell.gv" [ CSS.color ink, CSS.fontWeight "800" ]
  , selector_ ".scell.us" [ CSS.color leaf ]
  , selector_ ".scell.er"
      [ CSS.color errRed
      , CSS.backgroundColor (RGBA 178 58 72 0.12)
      ]
  , selector_ ".scell.peer" [ CSS.backgroundColor (RGBA 36 58 102 0.07) ]
  , selector_ ".scell.same"
      [ CSS.backgroundColor (RGBA 47 125 79 0.16)
      , CSS.fontWeight "800"
      ]
  , selector_ ".scell.sel"
      [ CSS.backgroundColor (RGBA 232 201 106 0.4)
      , CSS.boxShadow "inset 0 0 0 2px rgba(201,162,39,.8)"
      ]
  , selector_ ".scell .val" [ CSS.animation "popIn .18s cubic-bezier(.2,.9,.3,1.3) backwards" ]
  , selector_ ".scell.shakeC" [ "animation" =: "shakeA .4s ease" ]
  , selector_ ".scell.shakeC.alt" [ "animation-name" =: "shakeA2" ]
  , selector_ ".scell.winWave" [ "animation" =: "goldFlash .8s ease backwards" ]
  , selector_ ".noteGrid"
      [ CSS.position "absolute"
      , "inset" =: "6%"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(3, 1fr)"
      , CSS.gridTemplateRows "repeat(3, 1fr)"
      , CSS.fontSize "calc(var(--bs) / 42)"
      , CSS.fontWeight "600"
      , CSS.color (RGB 138 148 168)
      , CSS.pointerEvents "none"
      ]
  , selector_ ".noteGrid span"
      [ CSS.display "flex", CSS.alignItems "center", CSS.justifyContent "center" ]
  -- pad ---------------------------------------------------------------------
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
      , CSS.background tileFaceBg
      , CSS.border "none"
      , CSS.borderRadius (px 12)
      , CSS.padding "10px 0 16px"
      , CSS.fontSize "26px"
      , CSS.fontWeight "800"
      , CSS.color ink
      , CSS.fontFamily "inherit"
      , CSS.cursor "pointer"
      , CSS.boxShadow "0 2px 0 #c9bc9c, 0 5px 12px rgba(0,0,0,.45), inset 0 1px 1px rgba(255,255,255,.9)"
      , CSS.transition "transform .15s cubic-bezier(.2,.9,.3,1.4), box-shadow .15s ease, opacity .2s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".digBtn:active" [ CSS.transform "translateY(1px) scale(.97)" ]
  , selector_ ".digBtn small"
      [ CSS.position "absolute"
      , "inset" =: "auto 0 4px 0"
      , CSS.fontSize "10px"
      , CSS.fontWeight "600"
      , CSS.color (RGB 138 148 168)
      ]
  , selector_ ".digBtn.done" [ CSS.opacity 0.35, CSS.cursor "default" ]
  , selector_ ".ctrls"
      [ CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(2, 1fr)"
      , CSS.gap "9px"
      ]
  , selector_ ".ctrlBtn"
      [ CSS.background "rgba(6,26,20,.55)"
      , CSS.border "1px solid rgba(255,255,255,.14)"
      , CSS.color ivoryText
      , CSS.borderRadius (px 12)
      , CSS.padding "10px 6px"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".05em"
      , CSS.fontFamily "inherit"
      , CSS.cursor "pointer"
      , CSS.backdropFilter "blur(10px)"
      , CSS.transition "transform .15s ease, background .2s ease, border-color .2s ease, box-shadow .2s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".ctrlBtn.on"
      [ CSS.background "rgba(232,201,106,.18)"
      , CSS.borderColor gold
      , CSS.boxShadow "0 0 14px rgba(232,201,106,.35)"
      , CSS.color gold
      ]
  -- buttons -------------------------------------------------------------------
  , selector_ ".btn"
      [ CSS.padding "11px 26px"
      , CSS.borderRadius (px 999)
      , CSS.border "1px solid #f5e3a0"
      , CSS.background "linear-gradient(180deg, #f0d98c, #c9a227)"
      , CSS.color (RGB 36 26 2)
      , CSS.fontWeight "800"
      , CSS.fontSize "15px"
      , CSS.letterSpacing ".14em"
      , CSS.fontFamily "inherit"
      , CSS.cursor "pointer"
      , CSS.boxShadow "0 6px 18px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.6)"
      , CSS.transition "transform .15s ease, box-shadow .15s ease, filter .15s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".btn:active" [ CSS.transform "translateY(0) scale(.98)" ]
  , selector_ ".btn.ghost"
      [ CSS.background "rgba(10,32,25,.6)"
      , CSS.color (RGB 207 224 213)
      , CSS.border "1px solid rgba(255,255,255,.2)"
      , CSS.backdropFilter "blur(8px)"
      ]
  , media_ (MediaQuery "(hover: hover)")
      [ rule_ ".iconBtn:hover"
          [ CSS.background "rgba(20,60,45,.75)"
          , CSS.borderColor (RGBA 232 201 106 0.55)
          , CSS.transform "translateY(-1px)"
          ]
      , rule_ ".ctrlBtn:hover"
          [ CSS.background "rgba(20,60,45,.75)"
          , CSS.borderColor (RGBA 232 201 106 0.55)
          , CSS.transform "translateY(-1px)"
          ]
      , rule_ ".btn:hover"
          [ CSS.transform "translateY(-2px)"
          , CSS.boxShadow "0 10px 26px rgba(0,0,0,.5), inset 0 1px 0 rgba(255,255,255,.6)"
          , CSS.filter "brightness(1.07)"
          ]
      , rule_ ".digBtn:hover:not(.done)"
          [ CSS.transform "translateY(-3px)"
          , CSS.boxShadow "0 2px 0 #c9bc9c, 0 10px 20px rgba(0,0,0,.5), inset 0 1px 1px rgba(255,255,255,.9)"
          ]
      ]
  -- overlays ------------------------------------------------------------------
  , selector_ ".overlay"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.background "rgba(2,10,8,.6)"
      , CSS.backdropFilter "blur(7px)"
      , CSS.zIndex 100
      , CSS.animation "overlayIn .25s ease"
      ]
  , selector_ ".panel"
      [ CSS.background "linear-gradient(165deg, rgba(14,40,31,.92), rgba(6,20,15,.95))"
      , CSS.border "1px solid rgba(232,201,106,.4)"
      , CSS.borderRadius (px 22)
      , CSS.padding "30px 44px"
      , CSS.boxShadow "0 40px 100px rgba(0,0,0,.65), inset 0 1px 0 rgba(255,255,255,.1)"
      , CSS.textAlign "center"
      , CSS.animation "panelIn .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      , CSS.maxWidth "min(92vw, 560px)"
      ]
  , selector_ ".winTitle"
      [ CSS.fontSize "clamp(26px, 5vmin, 40px)"
      , CSS.fontWeight "900"
      , CSS.letterSpacing ".22em"
      , CSS.color gold
      , CSS.textShadow "0 2px 22px rgba(0,0,0,.8)"
      , CSS.marginBottom "6px"
      ]
  , selector_ ".winSub"
      [ CSS.color sage
      , CSS.letterSpacing ".1em"
      , CSS.fontSize "14px"
      , CSS.marginBottom "18px"
      ]
  , selector_ ".statRow"
      [ CSS.display "flex"
      , CSS.justifyContent "space-between"
      , CSS.gap "60px"
      , CSS.padding "8px 4px"
      , CSS.fontSize "16px"
      , CSS.borderBottom "1px solid rgba(255,255,255,.08)"
      , CSS.animation "riseIn .4s ease backwards"
      ]
  , selector_ ".statRow b"
      [ CSS.color gold, "font-variant-numeric" =: "tabular-nums" ]
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
      , "scrollbar-color" =: "rgba(232,201,106,.4) transparent"
      ]
  , selector_ ".helpPanel::-webkit-scrollbar" [ CSS.width "8px" ]
  , selector_ ".helpPanel::-webkit-scrollbar-thumb"
      [ CSS.background "rgba(232,201,106,.35)", CSS.borderRadius (px 8) ]
  , selector_ ".helpPanel::-webkit-scrollbar-track" [ CSS.background "transparent" ]
  , selector_ ".helpClose"
      [ CSS.position "absolute"
      , CSS.top "10px"
      , CSS.right "14px"
      , CSS.background "none"
      , CSS.border "none"
      , CSS.color sage
      , CSS.fontSize "22px"
      , CSS.cursor "pointer"
      , CSS.padding "6px 8px"
      , CSS.transition "color .15s ease, transform .15s ease"
      ]
  , selector_ ".helpClose:hover" [ CSS.color gold, CSS.transform "scale(1.15)" ]
  , selector_ ".helpH"
      [ CSS.fontSize "22px", CSS.fontWeight "900"
      , CSS.letterSpacing ".2em", CSS.color gold, CSS.margin "0 0 2px" ]
  , selector_ ".helpSub"
      [ CSS.color sage, CSS.fontSize "13px"
      , CSS.letterSpacing ".1em", CSS.marginBottom "10px" ]
  , selector_ ".helpSec"
      [ CSS.color gold, CSS.fontSize "12px", CSS.fontWeight "800"
      , CSS.letterSpacing ".24em", CSS.margin "18px 0 4px" ]
  , selector_ ".helpP"
      [ CSS.color (RGB 223 232 224), CSS.fontSize "14px"
      , CSS.lineHeight "1.6", CSS.margin "4px 0" ]
  , selector_ ".legendRow"
      [ CSS.display "flex", CSS.alignItems "center"
      , CSS.gap "10px", CSS.margin "8px 0" ]
  , selector_ ".legendCell"
      [ CSS.width "34px", CSS.height "34px"
      , CSS.display "flex", CSS.alignItems "center", CSS.justifyContent "center"
      , CSS.background tileFaceBg
      , CSS.borderRadius (px 7)
      , CSS.fontSize "19px", CSS.fontWeight "800"
      , CSS.boxShadow "0 2px 0 #c9bc9c, 0 4px 8px rgba(0,0,0,.4)"
      , "flex" =: "0 0 auto"
      ]
  , selector_ ".helpCap" [ CSS.color (RGB 207 224 213), CSS.fontSize "13.5px" ]
  , selector_ ".legendCell.gvL" [ CSS.color ink ]
  , selector_ ".legendCell.usL" [ CSS.color leaf ]
  , selector_ ".legendCell.erL"
      [ CSS.color errRed
      , CSS.background "linear-gradient(165deg, #fdf0f0 0%, #f4dddd 100%)"
      ]
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
      , CSS.background feltBackground
      , CSS.overflow "hidden"
      ]
  , selector_ ".floatCell"
      [ CSS.position "absolute"
      , CSS.width "clamp(40px, 5.4vmin, 56px)"
      , CSS.height "clamp(40px, 5.4vmin, 56px)"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.background tileFaceBg
      , CSS.borderRadius (px 10)
      , CSS.fontSize "clamp(20px, 2.8vmin, 30px)"
      , CSS.fontWeight "800"
      , CSS.color ink
      , CSS.boxShadow "0 2px 0 #c9bc9c, 0 5px 12px rgba(0,0,0,.5)"
      , CSS.opacity 0.55
      , CSS.animation "floaty 7s ease-in-out infinite"
      , CSS.pointerEvents "none"
      ]
  , selector_ ".titleH"
      [ CSS.fontSize "clamp(52px, 12vmin, 110px)"
      , CSS.fontWeight "900"
      , CSS.fontFamily "'Hiragino Mincho ProN', 'Yu Mincho', 'Noto Serif CJK JP', serif"
      , CSS.background "linear-gradient(180deg, #f7e7b0 10%, #e8c96a 45%, #a97d15 90%)"
      , "-webkit-background-clip" =: "text"
      , CSS.backgroundClip "text"
      , CSS.color transparent
      , CSS.textShadow "0 20px 60px rgba(0,0,0,.55)"
      , CSS.margin "0"
      , CSS.animation "riseIn .7s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".titleSub"
      [ CSS.letterSpacing ".5em"
      , CSS.color sage
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
  , selector_ ".howBtn"
      [ CSS.fontSize "13px"
      , CSS.padding "10px 30px"
      , CSS.marginTop "14px"
      , CSS.animation "riseIn .7s .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".titleHint"
      [ CSS.marginTop "18px"
      , CSS.color (RGB 127 154 140)
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
          [ CSS.fontSize "20px", CSS.padding "6px 0 14px", CSS.borderRadius (px 9) ]
      , rule_ ".ctrls"
          [ CSS.gridTemplateColumns "repeat(4, 1fr)", CSS.gap "5px" ]
      , rule_ ".ctrlBtn" [ CSS.padding "8px 4px", CSS.fontSize "12px" ]
      , rule_ ".panel" [ CSS.padding "22px 26px" ]
      , rule_ ".helpPanel" [ CSS.padding "18px 18px 20px" ]
      , rule_ ".overlay.help" [ CSS.padding "10px 8px 8px" ]
      , rule_ ".statRow" [ CSS.gap "30px" ]
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
  -- keyframes ------------------------------------------------------------------
  , keyframes_ "popIn"
      [ from_ [ CSS.transform "scale(.3)", CSS.opacity 0 ]
      , at (pct 65) [ CSS.transform "scale(1.15)", CSS.opacity 1 ]
      , to_ [ CSS.transform "scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "shakeA" shakeStops
  , keyframes_ "shakeA2" shakeStops
  , keyframes_ "goldFlash"
      [ from_ [ CSS.backgroundColor (RGBA 232 201 106 0.0) ]
      , at (pct 40) [ CSS.backgroundColor (RGBA 232 201 106 0.75) ]
      , to_ [ CSS.backgroundColor (RGBA 232 201 106 0.0) ]
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
feltBackground :: MisoString
feltBackground = mconcat
  [ "radial-gradient(120% 90% at 50% 12%, rgba(255,255,255,.07), rgba(0,0,0,0) 55%), "
  , "radial-gradient(140% 120% at 50% 50%, #17604a 0%, #0f4736 48%, #082b20 100%)"
  ]
-----------------------------------------------------------------------------
tileFaceBg :: MisoString
tileFaceBg = "linear-gradient(165deg, #fdfbf4 0%, #f4eddb 55%, #e9dfc4 100%)"
