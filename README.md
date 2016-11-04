# PoShHotCorners
["Hot Corners"](https://en.wikipedia.org/wiki/Screen_hotspot) for Windows 

## install
* none really, simply download the ico and ps1 files to a folder and launch the ps1 
* for a little extra polish... go ahead and create a shortcut, configure it's shortcut icon, throw it in your Startup folder ("%appdata%\Microsoft\Windows\Start Menu\Programs\Startup") and set the shortcut target to:
  * ```PowerShell -WindowStyle Hidden "{full path to your ps1 file}.ps1"```

## notes
* currently set to put power down monitors triggered by mouse in lower right corner but it's just powershell so the sky's the limit.
* the lion share of the code is actually just for the task tray icon...
* look for "beef" as the key line where mouse location triggers action
* DOES work with multiple monitors.
* the timer loop inherently keeps watching the mouse so if your screens stubbornly randomly wake up like mine, this will bonk them right back to nappy time, yes!

![image](https://cloud.githubusercontent.com/assets/6301228/19920053/a7db19b0-a093-11e6-8c7c-19eca3e24c5c.png)

![shortcut snapshot](https://cloud.githubusercontent.com/assets/6301228/19919989/292fb6fc-a093-11e6-8d34-876ff3e5b4ac.png)

