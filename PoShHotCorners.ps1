# Turn display off by calling WindowsAPI.
# from: http://www.powershellmagazine.com/2013/07/18/pstip-how-to-switch-off-display-with-powershell/
Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;
 
namespace Utilities {
   public static class Display
   {
      [DllImport("user32.dll", CharSet = CharSet.Auto)]
      private static extern IntPtr SendMessage(
         IntPtr hWnd,
         UInt32 Msg,
         IntPtr wParam,
         IntPtr lParam
      );
 
      public static void PowerOff ()# Turn display off by calling WindowsAPI.
# from: http://www.powershellmagazine.com/2013/07/18/pstip-how-to-switch-off-display-with-powershell/
Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;
 
namespace Utilities {
   public static class Display
   {
      [DllImport("user32.dll", CharSet = CharSet.Auto)]
      private static extern IntPtr SendMessage(
         IntPtr hWnd,
         UInt32 Msg,
         IntPtr wParam,
         IntPtr lParam
      );
 
      public static void PowerOff ()
      {
         SendMessage(
            (IntPtr)0xffff, // HWND_BROADCAST
            0x0112,         // WM_SYSCOMMAND
            (IntPtr)0xf170, // SC_MONITORPOWER
            (IntPtr)0x0002  // POWER_OFF
         );
      }
   }
}
'

Add-Type -AssemblyName System.Windows.Forms

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = New-Object System.Drawing.Icon "$(Split-Path -parent $PSCommandPath)\icon.ico"
$notifyIcon.Text = "Hot Corners"

$notifyIcon.add_MouseDown( { 
  if ($script:contextMenu.Visible) { $script:contextMenu.Hide(); return }
  if ($_.Button -ne [System.Windows.Forms.MouseButtons]::Left) {return}

  #from: http://stackoverflow.com/questions/21076156/how-would-one-attach-a-contextmenustrip-to-a-notifyicon
  #nugget: ContextMenu.Show() yields a known popup positioning bug... this trick leverages notifyIcons private method that properly handles positioning
  [System.Windows.Forms.NotifyIcon].GetMethod("ShowContextMenu", [System.Reflection.BindingFlags] "NonPublic, Instance").Invoke($script:notifyIcon, $null)
})

$screens = [System.Windows.Forms.Screen]::AllScreens

# create a blank window to selectively blank out one screen without the other
$frmBlank =  New-Object System.Windows.Forms.Form
$frmBlank.Name = "frmBlank"
$frmBlank.Text = "PoShHotCorners"
$frmBlank.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$frmBlank.BackColor = "Black"
$frmBlank.ShowInTaskbar = $false
$frmBlank.TopMost = $true

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$contextMenu.ShowImageMargin = $false
$notifyIcon.ContextMenuStrip = $contextMenu
$contextMenu.Show(); $contextMenu.Hide() #just to initialize the window handle to give to $timer.SynchronizingObject below

# create menu entries to blank each screen individually
$screens | % {
  $bounds = $_.Bounds
  $displayName = $_.DeviceName.Replace("\\.\", "")
  $menuItem = $null
  $menuItem = $contextMenu.Items.Add("Blank $displayName")
  $menuItem.add_Click({
    $script:frmBlank.Bounds = $bounds
    if ($menuItem.Text.StartsWith("Blank")) { $script:frmBlank.Show(); $menuItem.Text = $menuItem.Text.Replace("Blank", "Show") }
    else { $script:frmBlank.Hide(); $menuItem.Text = $menuItem.Text.Replace("Show", "Blank") }
  }.GetNewClosure() ) #nugget: GetNewClosure() separates each instance of $menuItem
}

$contextMenu.Items.Add( "E&xit", $null, { $notifyIcon.Visible = $false; [System.Windows.Forms.Application]::Exit() } ) | Out-Null

$timer = New-Object System.Timers.Timer
$timer.Interval = 1000
$timer.add_Elapsed({
  $mouse = [System.Windows.Forms.Cursor]::Position
  $bounds = [System.Windows.Forms.Screen]::FromPoint($mouse).Bounds #thank you! - http://stackoverflow.com/questions/26402955/finding-monitor-screen-on-which-mouse-pointer-is-present

  <#  __  __              _          __  __            __              ____
     / / / /__  ________ ( )_____   / /_/ /_  ___     / /_  ___  ___  / __/
    / /_/ / _ \/ ___/ _ \|// ___/  / __/ __ \/ _ \   / __ \/ _ \/ _ \/ /_  
   / __  /  __/ /  /  __/ (__  )  / /_/ / / /  __/  / /_/ /  __/  __/ __/  
  /_/ /_/\___/_/   \___/ /____/   \__/_/ /_/\___/  /_.___/\___/\___/_/     #>
  # currently set to trigger at lower right corner... season to your own taste (e.g. upper left = 0,0)
  if ($mouse.X-$bounds.X -gt $bounds.Width-10 -and $mouse.Y -gt $bounds.Height-10 `
    -and $bounds.X) # target second screen specifically
    { [Utilities.Display]::PowerOff() }
    
  #run the ps1 from command line to see this output
  #debug: Write-Host "x: $($mouse.X), y:$($mouse.Y), width: $($bounds.Width), height: $($bounds.Height), sleep: $($mouse.X-$bounds.X -gt $bounds.Width-10 -and $mouse.Y -gt $bounds.Height-10)"
})

#frugally reusing $contextMenu vs firing up another blank form, not really necessary but i was curious if it'd work... the notify icon itself does not implement InvokeRequired
#see this for why SynchronizingObject necessary: http://stackoverflow.com/questions/15505812/why-dont-add-eventname-work-with-timer
$timer.SynchronizingObject = $contextMenu

$timer.start()
$notifyIcon.Visible = $true
[System.Windows.Forms.Application]::Run()

      {
         SendMessage(
            (IntPtr)0xffff, // HWND_BROADCAST
            0x0112,         // WM_SYSCOMMAND
            (IntPtr)0xf170, // SC_MONITORPOWER
            (IntPtr)0x0002  // POWER_OFF
         );
      }
   }
}
'

Add-Type -AssemblyName System.Windows.Forms

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = New-Object System.Drawing.Icon "$(Split-Path -parent $PSCommandPath)\icon.ico"
$notifyIcon.Text = "Hot Corners"

$notifyIcon.add_MouseDown( { 
  if ($script:contextMenu.Visible) { $script:contextMenu.Hide(); return }
  if ($_.Button -ne [System.Windows.Forms.MouseButtons]::Left) {return}

  #from: http://stackoverflow.com/questions/21076156/how-would-one-attach-a-contextmenustrip-to-a-notifyicon
  #nugget: ContextMenu.Show() yields a known popup positioning bug... this trick leverages notifyIcons private method that properly handles positioning
  [System.Windows.Forms.NotifyIcon].GetMethod("ShowContextMenu", [System.Reflection.BindingFlags] "NonPublic, Instance").Invoke($script:notifyIcon, $null)
})

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$contextMenu.ShowImageMargin = $false
$notifyIcon.ContextMenuStrip = $contextMenu
$contextMenu.Items.Add( "E&xit", $null, { $notifyIcon.Visible = $false; [System.Windows.Forms.Application]::Exit() } ) | Out-Null
$contextMenu.Show(); $contextMenu.Hide() #just to initialize the window handle to give to $timer.SynchronizingObject below

$timer = New-Object System.Timers.Timer
$timer.Interval = 500
$timer.add_Elapsed({
  $mouse = [System.Windows.Forms.Cursor]::Position
  $bounds = [System.Windows.Forms.Screen]::FromPoint($mouse).Bounds #thank you! - http://stackoverflow.com/questions/26402955/finding-monitor-screen-on-which-mouse-pointer-is-present

  <#    __  __              _          __  __            __              ____
       / / / /__  ________ ( )_____   / /_/ /_  ___     / /_  ___  ___  / __/
      / /_/ / _ \/ ___/ _ \|// ___/  / __/ __ \/ _ \   / __ \/ _ \/ _ \/ /_  
     / __  /  __/ /  /  __/ (__  )  / /_/ / / /  __/  / /_/ /  __/  __/ __/  
    /_/ /_/\___/_/   \___/ /____/   \__/_/ /_/\___/  /_.___/\___/\___/_/     #>
  # currently set to trigger at lower right corner... season to your own taste (e.g. upper left = 0,0)
  if ($mouse.X-$bounds.X -gt $bounds.Width-10 -and $mouse.Y -gt $bounds.Height-10 -and $bounds.X) { [Utilities.Display]::PowerOff() }

  #run the ps1 from command line to see this output
  #debug: Write-Host "x: $($mouse.X), y:$($mouse.Y), width: $($bounds.Width), height: $($bounds.Height), sleep: $($mouse.X-$bounds.X -gt $bounds.Width-10 -and $mouse.Y -gt $bounds.Height-10)"
})

#frugally reusing $contextMenu vs firing up another blank form, not really necessary but i was curious if it'd work... the notify icon itself does not implement InvokeRequired
#see this for why SynchronizingObject necessary: http://stackoverflow.com/questions/15505812/why-dont-add-eventname-work-with-timer
$timer.SynchronizingObject = $contextMenu

$timer.start()
$notifyIcon.Visible = $true
[System.Windows.Forms.Application]::Run()
