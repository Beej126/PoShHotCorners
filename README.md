# PoShHotCorners
["Hot Corners"](https://en.wikipedia.org/wiki/Screen_hotspot) for Windows 

![](https://cloud.githubusercontent.com/assets/6301228/20070283/ab4e62e2-a4d4-11e6-84ab-70abd4ff34b9.png)

## install
* none really, simply download the ico and ps1 files to a folder and launch the ps1 
* please note MakeShortcut.cmd batch file provided for convenience ... 
  * throw resulting .lnk file in your "run on startup" folder if you like: ```"%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"```
  * as you can see, the batch file simply runs shortcut tool [xxmklink.exe](http://www.xxcopy.com/xxcopy38.htm) with appropriate arguments

## notes
* currently:
  * upper left corner = power off monitor(s)
  * upper right corner = screensaver
- ... but it's just powershell folks, so dream big! =)
* the lion's share of the code is for the task tray icon...
* look for **"beef"** as the key line where mouse location triggers action
* this DOES work with multiple monitors
  * also includes tray menu options for blanking multiple displays independently
* the timer loop inherently keeps watching the mouse so if your screens stubbornly randomly wake up like mine, this will bonk them right back to nappy time!

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

## tips
* if you find that your windows get all jumbled after sleeping the monitors, [this post](http://superuser.com/questions/453446/how-can-i-stop-windows-re-positioning-after-waking-from-sleep) actually seemed to help... but all i did was simply delete the whole registry folder `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Configuration` (i probably had at least 50 entries in there) and let Windows recreate.

## favorite screensavers
* **Flurry** - https://www.wincustomize.com/explore/screensavers/75
  <img width="200" style="float: right" src="https://user-images.githubusercontent.com/6301228/74005888-01295d00-492f-11ea-8cf9-24abeffe9c07.png">
* **SereneScreen Marine Acquarium** - https://www.serenescreen.com by Jim Sachs an OG from Commodore 64 and Amiga days!
  <img width="200" style="float: right" src="https://user-images.githubusercontent.com/6301228/113747965-c8188400-96bc-11eb-8bd4-312f400bfa8b.png">
