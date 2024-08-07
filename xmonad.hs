{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}
import System.IO
import System.Exit

import XMonad
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog, doRectFloat, doSink)
import XMonad.Config.Desktop
import XMonad.Config.Azerty
import XMonad.Util.Run(spawnPipe, runProcessWithInput)
import XMonad.Actions.SpawnOn
import XMonad.Util.EZConfig (additionalKeys, additionalMouseBindings)
import qualified XMonad.Util.ExtensibleState as ST
import XMonad.Actions.CycleWS
import XMonad.Hooks.UrgencyHook
import qualified Codec.Binary.UTF8.String as UTF8

import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.ResizableTile
---import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen (fullscreenFull)
import XMonad.Layout.Cross(simpleCross)
import XMonad.Layout.Spiral(spiral)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.IndependentScreens


import XMonad.Layout.CenteredMaster(centerMaster)

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import qualified Data.ByteString as B
import Control.Monad ( liftM2, unless, when, unless, when, (>=>), void )
import qualified DBus as D
import qualified DBus.Client as D
import qualified XMonad.StackSet as S
import XMonad.Prelude (isNothing, intercalate)
import XMonad.Actions.DynamicWorkspaces (appendWorkspace, removeEmptyWorkspaceAfter, removeEmptyWorkspace, addHiddenWorkspace, addHiddenWorkspaceAt)
import GHC.Settings (maybeRead)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import XMonad.Util.WorkspaceCompare (getSortByIndex)
import qualified XMonad.Util.Hacks as Hacks
import qualified XMonad.Util.NamedWindows as NW
import XMonad.Actions.MouseResize (mouseResize)
import XMonad.Layout.WindowArranger (windowArrange)
import qualified XMonad.Util.NamedWindows as NWIN
import Control.Arrow ((>>>), (&&&), Arrow (first))
import XMonad.StackSet (RationalRect(RationalRect))
import XMonad.Util.NamedScratchpad (NamedScratchpad(NS), namedScratchpadManageHook, defaultFloating, namedScratchpadAction, customFloating)
import XMonad.Config.Dmwit (altMask)

-- preferences
-- myMenu = "dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn 'NotoMonoRegular:bold:pixelsize=14'"
myMenu = "xfce4-popup-whiskermenu"
myBrowser = "brave"
myTerminal = "kitty"
myTerminalClass = "kitty"
myFiles = "thunar"
myCodeEditor = "emacs"
myTextEditor = "gedit"
myCalendar = "io.elementary.calendar"

myStartupHook = do
    spawn "$HOME/.xmonad/scripts/autostart.sh"

    -- addHiddenWorkspaceAt (\workspace-> (++ [workspace])) "NSP"

    -- term_pid <- runProcessWithInput "pidof" [myTerminal] ""

    -- if not $ null term_pid then return ()
    -- else do
    --     spawnOn "NSP" myTerminal

    -- term_pid <- runProcessWithInput "pidof" ["emacs"] ""

    -- if not $ null term_pid then return ()
    -- else do
    --     spawnOn "NSP" "emacs"

    -- namedScratchpadAction scratchpads "myTerminal"
    setWMName "LG3D"

-- colours
normBord = "#1F456E"
focdBord = "#FF5F1F"
fore     = "#DEE3E0"
back     = "#282c34"
winType  = "#c678dd"

--mod4Mask= super key
--mod1Mask= alt key
--controlMask= ctrl key
--shiftMask= shift key

myModMask = mod4Mask
altKeyMask = mod1Mask
encodeCChar = map fromIntegral . B.unpack
myFocusFollowsMouse = True
myBorderWidth = 3
-- myWorkspaces    = ["\61612","\61899","\61947","\61635","\61502","\61501","\61705","\61564","\62150","\61872"]
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9","10"]
myWorkspaces    = ["0000"]

myBaseConfig = desktopConfig

-- window manipulations
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [title =? "Bluetooth" --> doCenterFloat]
    , [title =? "Whisker Menu" --> doRectFloat (RationalRect 0 0 1 0.97)]
    , [title =? "xfdashboard" --> doRectFloat (RationalRect 0 0.03 1 0.97)]
    , [className =? "Archlinux-logout.py" --> doFullFloat]
    , [className =? "deepin-screen-recorder" --> doFullFloat]
    -- , [className =? "Yad" --> doCenterFloat]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61612" | x <- my1Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61899" | x <- my2Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61947" | x <- my3Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61635" | x <- my4Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61502" | x <- my5Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61501" | x <- my6Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61705" | x <- my7Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61564" | x <- my8Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\62150" | x <- my9Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61872" | x <- my10Shifts]
    ]
    where
    -- doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = [
        "Arandr"
        , "Arcolinux-calamares-tool.py"
        , "Archlinux-tweak-tool.py"
        , "Arcolinux-welcome-app.py"
        , "Galculator"
        , "feh"
        , "mpv"
        , "Xfce4-terminal"
        , "Yad"
        , "ROOT"
        ]
    myTFloats = ["Downloads", "Save As..."]
    myRFloats = []
    myIgnores = ["desktop_window"]
    -- my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    -- my2Shifts = []
    -- my3Shifts = ["Inkscape"]
    -- my4Shifts = []
    -- my5Shifts = ["Gimp", "feh"]
    -- my6Shifts = ["vlc", "mpv"]
    -- my7Shifts = ["Virtualbox"]
    -- my8Shifts = ["Thunar"]
    -- my9Shifts = []
    -- my10Shifts = ["discord"]




myLayout = spacingRaw True (Border 5 5 5 5) True (Border 5 5 5 5) True $ avoidStruts $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ tiled ||| Mirror tiled ||| spiral (6/7)  ||| ThreeColMid 1 (3/100) (1/2) ||| Full
    where
        tiled = Tall nmaster delta tiled_ratio
        nmaster = 1
        delta = 3/100
        tiled_ratio = 1/2


myMouseBindings XConfig {XMonad.modMask = modMask} = M.fromList

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, 1), \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, 2), \w -> focus w >> windows W.shiftMaster)

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, 3), \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)

    ]

scratchpads = [
    NS "myTerminal" myTerminal (className =? myTerminalClass)
        (customFloating $ W.RationalRect 0 0.03 1 0.6)
    , NS "MSTeams" "teams" (className =? "Microsoft Teams - Preview")
        doCenterFloat
    , NS "myCalendar" myCalendar (className =? "Io.elementary.calendar")
        doCenterFloat
    , NS "emacs" "emacs" (className =? "Emacs") doSink
    ]

popup :: String -> X()
popup message = do
    spawn $ "yad --info --text " ++ show message

getCurrentWorkspace :: X (S.Workspace WorkspaceId (Layout Window) Window)
getCurrentWorkspace = S.workspace . S.current <$> gets windowset

data MaximizeData
    = MaximizeData Bool (Layout Window)
    deriving (Show)

instance ExtensionClass MaximizeData where
    initialValue = MaximizeData False $ Layout Full

unmaximizeWith :: Layout Window -> X ()
unmaximizeWith layout = do
    setLayout layout
    ST.put $ MaximizeData False layout

maximize :: X ()
maximize = do
    layout <- S.layout <$> getCurrentWorkspace
    setLayout $ Layout Full
    ST.put $ MaximizeData True layout



toggleFullscreen :: Bool -> X()
toggleFullscreen doesMaximize = ST.get >>= \case
    MaximizeData True prevLayout -> unmaximizeWith prevLayout
    MaximizeData False _
        | doesMaximize -> maximize
        | otherwise -> return ()

isCurrentWorkspaceEmpty :: X Bool
isCurrentWorkspaceEmpty = isNothing . W.stack <$> getCurrentWorkspace

-- onNotEmptyWorkspace :: Bool -> X() -> X() -> X()
-- onNotEmptyWorkspace isToEmpty action reverseAction = do
--     isCurrentEmpty <- isCurrentWorkspaceEmpty
--     action
--     isNewEmpty <- isCurrentWorkspaceEmpty
--     if isToEmpty
--     then when (isCurrentEmpty && isNewEmpty) reverseAction
--     else when isNewEmpty reverseAction

-- Workspace Management Stuff

gnomeWS :: Direction1D -> (Int -> Int -> Bool) -> (Int -> Int -> X()) -> X()
gnomeWS dir compareWS action = getIndexMaybeM getCurrentWorkspace (return ()) $ \curIndex-> do
    -- makes sure everything is minimized
    toggleFullscreen False
    doTo dir
        (WSIs $ return $ getIndexMaybe False $ \index->
            index `compareWS` curIndex)
        getSortByIndex
        -- the flip is to ensure that curIndex is the second argument
        $ fromReadMaybe (return ()) $ flip action curIndex
    where
        fromReadMaybe onFail action = maybe onFail action . readMaybe
        getIndexMaybe onFail action = fromReadMaybe onFail action . S.tag
        getIndexMaybeM ws onFail action = ws >>= getIndexMaybe onFail action

{-# ANN onWS_DNE_DoNothing "HLint: ignore" #-}
onWS_DNE_DoNothing :: X() -> Int -> Int -> X()
onWS_DNE_DoNothing action index curIndex = unless (index == curIndex) action

{-# ANN onWS_DNE_AddWS "HLint: ignore" #-}
onWS_DNE_AddWS :: X() -> Int -> Int -> X()
onWS_DNE_AddWS action index curIndex = unless (padding < 0) $ when (index == curIndex) (addHiddenWorkspace $ replicate padding '0' ++ tag) >> action
    where
        tag = show $ index + 1
        -- the padding is need or else a bug would appear at WS 10
        padding = 4 - length tag

onPrevWS :: X() -> X()
onPrevWS = gnomeWS Prev (<=) . onWS_DNE_DoNothing

onNextWS :: X() -> X()
onNextWS = gnomeWS Next (>=) . onWS_DNE_AddWS

-- newtype ShowEvent = ShowEvent Bool 

-- instance ExtensionClass ShowEvent where 
--     initialValue = ShowEvent False

-- myEventHook event = do 
--     case event of 
--         DestroyWindowEvent event_type serial send_event event_display ev_event window -> {-ST.get >>= \(ShowEvent showEvent)-> when showEvent $-} do 
--             nwindow <- NW.getName ev_event
--             popup $ "event: " ++ show nwindow
--             ST.put $ ShowEvent False
--         _ -> return()


getWindowNames :: X ()
getWindowNames = withWindowSet (fmap (intercalate "\n>=>=>\n") . mapM (NWIN.getName >=> return . show) . S.index >=> popup)

findWindow :: String -> (Window -> X()) -> X()
findWindow winName f = withWindowSet (
    S.index
    >>> mapM (\win ->
        NWIN.getName win
        >>= (show >>> (, win) >>> return)
        >>= (\(name,win)->when (name == winName) $ f win))
    >>> void)

-- keys config

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@XConfig {XMonad.modMask = modMask} = M.fromList $
    ----------------------------------------------------------------------

    [ ((modMask, xK_space), spawn myMenu)

    -- SUPER + FUNCTION KEYS
    , ((modMask, xK_b), spawn myBrowser)
    , ((modMask, xK_t), namedScratchpadAction scratchpads "myTerminal")
    , ((modMask, xK_Tab), namedScratchpadAction scratchpads "myTerminal")
    , ((modMask, xK_f ), spawn myFiles)
    , ((modMask, xK_x), spawn "archlinux-logout" )
    , ((modMask, xK_i), spawn "$HOME/.xmonad/scripts/display-xprop.fish")
    , ((modMask, xK_c), namedScratchpadAction scratchpads "emacs")
    , ((modMask, xK_p), spawn "keepassxc")
    , ((controlMask .|. modMask, xK_g), spawn "pkill -SIGUSR2 emacs")
    , ((modMask, xK_e), spawn myTextEditor)
    , ((modMask, xK_q), kill )
    , ((modMask, xK_Escape), spawn "xkill" )


    -- , ((controlMask .|. altMask, xK_e), spawn "emacsclient -c -a \"emacs\"")
    -- , ((controlMask .|. altMask, xK_e), namedScratchpadAction scratchpads "emacs")

    -- , ((modMask, xK_equal), ST.put (ShowEvent True))

    -- -- FUNCTION KEYS
    -- , ((0, xK_F12), spawn "xfce4-terminal --drop-down" )

    -- ALT Keys (reloading xmonad)

    , ((altKeyMask .|. modMask , xK_r ), spawn "$HOME/.xmonad/scripts/recompile.fish && xmonad --restart")
    , ((altKeyMask, xK_r), spawn "xmonad --restart" )
    -- , ((modMask .|. shiftMask , xK_x ), io (exitWith ExitSuccess))

    -- CONTROL + ALT KEYS

    -- not in use

    -- ALT + ... KEYS

    -- , ((mod1Mask, xK_f), spawn "variety -f" )
    -- , ((mod1Mask, xK_n), spawn "variety -n" )
    -- , ((mod1Mask, xK_p), spawn "variety -p" )
    -- , ((mod1Mask, xK_t), spawn "variety -t" )
    -- , ((mod1Mask, xK_Up), spawn "variety --pause" )
    -- , ((mod1Mask, xK_Down), spawn "variety --resume" )
    -- , ((mod1Mask, xK_Left), spawn "variety -p" )
    -- , ((mod1Mask, xK_Right), spawn "variety -n" )
    -- , ((mod1Mask, xK_F2), spawn "xfce4-appfinder --collapsed" )
    -- , ((mod1Mask, xK_F3), spawn "xfce4-appfinder" )

    --VARIETY KEYS WITH PYWAL

    -- , ((mod1Mask .|. shiftMask , xK_f ), spawn "variety -f && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
    -- , ((mod1Mask .|. shiftMask , xK_n ), spawn "variety -n && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
    -- , ((mod1Mask .|. shiftMask , xK_p ), spawn "variety -p && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
    -- , ((mod1Mask .|. shiftMask , xK_t ), spawn "variety -t && wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")
    -- , ((mod1Mask .|. shiftMask , xK_u ), spawn "wal -i $(cat $HOME/.config/variety/wallpaper/wallpaper.jpg.txt)&")

    --CONTROL + SHIFT KEYS

    , ((controlMask .|. altKeyMask , xK_Delete ), spawn "xfce4-taskmanager")

    --SCREENSHOTS

    -- , ((0, xK_Print), spawn "gnome-screenshot --interactive")
    , ((0, xK_Print), spawn "deepin-screen-recorder --shot")
    -- , ((0, xK_Print), spawn "scrot 'ArcoLinux-%Y-%m-%d-%s_screenshot_$wx$h.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'")
    -- , ((controlMask, xK_Print), spawn "xfce4-screenshooter" )
    -- , ((controlMask .|. shiftMask , xK_Print ), spawn "gnome-screenshot -i")
    -- , ((controlMask .|. modMask , xK_Print ), spawn "flameshot gui")

    --MULTIMEDIA KEYS

    -- Mute volume
    , ((0, xF86XK_AudioMute), spawn "amixer -q set Master toggle")

    -- Decrease volume
    , ((0, xF86XK_AudioLowerVolume), spawn "amixer -q set Master 5%-")

    -- Increase volume
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+")

    -- Increase brightness
    , ((0, xF86XK_MonBrightnessUp),  spawn "xbacklight -inc 5")

    -- Decrease brightness
    , ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5")

    -- Alternative to increase brightness

    -- Increase brightness
    -- , ((0, xF86XK_MonBrightnessUp),  spawn $ "brightnessctl s 5%+")

    -- Decrease brightness
    -- , ((0, xF86XK_MonBrightnessDown), spawn $ "brightnessctl s 5%-")

--  , ((0, xF86XK_AudioPlay), spawn $ "mpc toggle")--info --text".split() + [out])
--  , ((0, xF86XK_AudioNext), spawn $ "mpc next")
--  , ((0, xF86XK_AudioPrev), spawn $ "mpc prev")
--  , ((0, xF86XK_AudioStop), spawn $ "mpc stop")

    , ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
    , ((0, xF86XK_AudioNext), spawn "playerctl next")
    , ((0, xF86XK_AudioPrev), spawn "playerctl previous")
    , ((0, xF86XK_AudioStop), spawn "playerctl stop")


    --------------------------------------------------------------------
    --  XMONAD LAYOUT KEYS

    -- Cycle through the available layout algorithms.
    , ((modMask, xK_Return), sendMessage NextLayout)

    --Focus selected desktop
    , ((modMask .|. controlMask , xK_j ), onNextWS $ removeEmptyWorkspaceAfter nextWS)

    , ((modMask .|. controlMask , xK_k ), onPrevWS $ removeEmptyWorkspaceAfter prevWS)

    -- move windows between workspaces

    , ((modMask .|. shiftMask, xK_j ), onNextWS $ shiftToNext >> removeEmptyWorkspaceAfter nextWS)

    , ((modMask .|. shiftMask, xK_k), onPrevWS $ shiftToPrev >> removeEmptyWorkspaceAfter prevWS)

    --  Reset the layouts on the current workspace to default.
    , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- Move focus to another window.
    , ((modMask, xK_j), windows W.focusDown)

    , ((modMask, xK_k), windows W.focusUp  )

    -- Shrink the master area.
    , ((modMask , xK_h), sendMessage Shrink)

    -- Expand the master area.
    , ((modMask , xK_l), sendMessage Expand)

    -- Move focus to the master window.
    , ((modMask, xK_g), windows W.focusMaster)

    -- Swap the focused window 
    , ((modMask .|. altKeyMask, xK_j), windows W.swapDown  )

    , ((modMask .|. altKeyMask, xK_k), windows W.swapUp    )

    , ((modMask .|. altKeyMask, xK_g), windows W.swapMaster)

    -- Increment the number of windows in the master area.
    , ((modMask .|. altKeyMask, xK_h), sendMessage (IncMasterN 1))

    -- Decrement the number of windows in the master area.
    , ((modMask .|. altKeyMask, xK_l), sendMessage (IncMasterN (-1)))

    -- maximize
    -- xK_equal should be the same as the plus key
    , ((modMask, xK_m), toggleFullscreen True)

    -- Push window back into tiling.
    , ((modMask .|. altKeyMask , xK_t), withFocused $ windows . W.sink)

    -- APPS
    , ((controlMask .|. altKeyMask, xK_t), namedScratchpadAction scratchpads "MSTeams")
    -- , ((controlMask .|. altKeyMask, xK_d), spawn "flatpak run com.discordapp.Discord")
    , ((controlMask .|. altKeyMask, xK_v), spawn "xournalpp")
    , ((controlMask .|. altKeyMask, xK_c), namedScratchpadAction scratchpads "myCalendar")

    ]
    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modMask, k), windows $ f i)

    --Keyboard layouts
    --qwerty users use this line
    | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7,xK_8,xK_9,xK_0]

    --French Azerty users use this line

    ---- | (i, k) <- zip (XMonad.workspaces conf) [xK_ampersand, xK_eacute, xK_quotedbl, xK_apostrophe, xK_parenleft, xK_minus, xK_egrave, xK_underscore, xK_ccedilla , xK_agrave]

    --Belgian Azerty users use this line
    --   | (i, k) <- zip (XMonad.workspaces conf) [xK_ampersand, xK_eacute, xK_quotedbl, xK_apostrophe, xK_parenleft, xK_section, xK_egrave, xK_exclam, xK_ccedilla, xK_agrave]

        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)
        , (\i -> W.greedyView i . W.shift i, shiftMask)]]

    ++
    -- ctrl-shift-{w,e,r}, Move client to screen 1, 2, or 3
    -- [((m .|. controlMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --    | (key, sc) <- zip [xK_w, xK_e] [0..]
    --    , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_Left, xK_Right] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

main :: IO ()
main = do

    dbus <- D.connectSession
    -- Request access to the DBus name
    D.requestName dbus (D.busName_ "org.xmonad.Log")
        [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]


    xmonad . ewmh $
    --Keyboard layouts
    --qwerty users use this line
            myBaseConfig
    --French Azerty users use this line
            --myBaseConfig { keys = azertyKeys <+> keys azertyConfig }
    --Belgian Azerty users use this line
            --myBaseConfig { keys = belgianKeys <+> keys belgianConfig }

                {startupHook = myStartupHook
, layoutHook = gaps [(U,35), (D,5), (R,5), (L,5)] $ myLayout ||| layoutHook myBaseConfig
, manageHook =namedScratchpadManageHook scratchpads <+> manageSpawn <+> myManageHook <+> manageHook myBaseConfig
, modMask = myModMask
, borderWidth = myBorderWidth
, handleEventHook    =  handleEventHook myBaseConfig <> Hacks.windowedFullscreenFixEventHook
, focusFollowsMouse = myFocusFollowsMouse
, workspaces = myWorkspaces
, focusedBorderColor = focdBord
, normalBorderColor = normBord
, keys = myKeys
, mouseBindings = myMouseBindings
}
