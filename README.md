# PoShHotCorners
["Hot Corners"](https://en.wikipedia.org/wiki/Screen_hotspot) for Windows 

## install
* none really, simply download the ico and ps1 files to a folder and launch the ps1 
* please note MakeShortcut.cmd batch file provided for convenience ... 
  * throw resulting .lnk file in your "run on startup" folder if you like: ```"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"```
  * as you can see, the batch file simply runs shortcut tool [xxmklink.exe](http://www.xxcopy.com/xxcopy38.htm) with appropriate arguments

## notes
* currently coded to power down monitors triggered by mouse in lower right corner ... but it's just powershell folks, so think grand!
* the lion's share of the code is actually just for the task tray icon...
* look for **"beef"** as the key line where mouse location triggers action
* DOES work with multiple monitors.
  * also includes tray menu options for blanking multiple displays independently
* the timer loop inherently keeps watching the mouse so if your screens stubbornly randomly wake up like mine, this will bonk them right back to nappy time for the win, yes!

## supporting multiple extended displays
* if your scenario isn't working, drop me an issue on github or if you're inclined, check your [System.Windows.Forms.Screen]::AllScreens
* here's mine:
  ```
  BitsPerPixel : 32
  Bounds       : {X=2560,Y=0,Width=1920,Height=1200}
  DeviceName   : \\.\DISPLAY2
  Primary      : False
  WorkingArea  : {X=2560,Y=0,Width=1920,Height=1160}

  BitsPerPixel : 32
  Bounds       : {X=0,Y=0,Width=2560,Height=1600}
  DeviceName   : \\.\DISPLAY3
  Primary      : True
  WorkingArea  : {X=0,Y=0,Width=2560,Height=1560}
  ```
* i have 2 screens side-by-side, so note the Bounds of the first where X has a value...
* so that's where the $mouse.X-$bounds.X in the "beef" check works for me...
* hopefully that approach will carry through other monitor arragements with a little testing

![](https://cloud.githubusercontent.com/assets/6301228/20070283/ab4e62e2-a4d4-11e6-84ab-70abd4ff34b9.png)

## tips
* if you find that your windows get all jumbled after sleeping the monitors, [this post](http://superuser.com/questions/453446/how-can-i-stop-windows-re-positioning-after-waking-from-sleep) actually seemed to help... but all i did was simply delete the whole registry folder `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration` (i probably had at least 50 entries in there) and let Windows recreate.

