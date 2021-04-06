# Turn display off by calling WindowsAPI.
# from: http://www.powershellmagazine.com/2013/07/18/pstip-how-to-switch-off-display-with-powershell/
Add-Type -TypeDefinition '
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class Win32Helpers
{
  [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
  public static extern int GetLongPathName(
      [MarshalAs(UnmanagedType.LPTStr)]
      string path,
      [MarshalAs(UnmanagedType.LPTStr)]
      StringBuilder longPath,
      int longPathLength
  );

  public static string GetLongPath(string shortPath)
  {
    StringBuilder longPath = new StringBuilder(255);
    GetLongPathName(shortPath, longPath, longPath.Capacity);
    return longPath.ToString();
  }

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
'

Add-Type -AssemblyName System.Windows.Forms

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = New-Object System.Drawing.Icon "$(Split-Path -parent $PSCommandPath)\icon.ico"
$notifyIcon.Text = "Hot Corners"

function showContextMenu {
  #nugget: ContextMenu.Show() yields a known popup positioning bug... this trick leverages notifyIcons private method that properly handles positioning
  [System.Windows.Forms.NotifyIcon].GetMethod("ShowContextMenu", [System.Reflection.BindingFlags] "NonPublic, Instance").Invoke($script:notifyIcon, $null)
}

$notifyIcon.add_MouseDown( {
    if ($script:contextMenu.Visible) { $script:contextMenu.Hide(); return }
    if ($_.Button -ne [System.Windows.Forms.MouseButtons]::Left) { return }

    #from: http://stackoverflow.com/questions/21076156/how-would-one-attach-a-contextmenustrip-to-a-notifyicon
    showContextMenu
  })

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$contextMenu.ShowImageMargin = $false
$notifyIcon.ContextMenuStrip = $contextMenu

# create menu entries to blank each screen individually (not a true sleep)
if ([System.Windows.Forms.Screen]::AllScreens.length -gt 1) {
  [System.Windows.Forms.Screen]::AllScreens | % {
    # create a blank window to selectively blank out one screen without the other
    $frmBlank = New-Object System.Windows.Forms.Form
    $frmBlank.Text = $_.DeviceName.Replace("\\.\", "")
    $frmBlank.BackColor = [System.Drawing.Color]::FromName("Black")
    $frmBlank.ShowInTaskbar = $false
    $frmBlank.TopMost = $true
    $frmBlank.Show() #crucial sequence to show and then set bounds or else window top/left don't get set properly
    $frmBlank.Bounds = $_.Bounds
    #this prevented bounds restore after sleep - $frmBlank.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $frmBlank.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $frmBlank.Hide()

    $menuItem = $contextMenu.Items.Add("Blank $($frmBlank.Text)")
    $menuItem.Tag = New-Object -TypeName PSObject -Property @{Form = $frmBlank; Bounds = $_.Bounds }

    $menuItem.add_Click( {
        $thisForm = $this.Tag.Form
        @($thisForm.Show, $thisForm.Hide)[$thisForm.Visible].Invoke()
        $thisForm.Bounds = $this.Tag.Bounds #restore bounds because monitor sleep can shuffle windows to different screens
        [System.Windows.Forms.Application]::DoEvents() #crucial to allow blank form to cover task bar
        $thisForm.BringToFront() #also crucial to cover task bar
        $this.Text = @("Blank", "Show")[$thisForm.Visible] + " " + $thisForm.Text
      })
  }
}

$contextMenu.Items.Add( "E&xit", $null, { $notifyIcon.Visible = $false; [System.Windows.Forms.Application]::Exit() } ) | Out-Null

$screenSaverPath = (Get-ItemProperty "HKCU:\Control Panel\Desktop").{SCRNSAVE.EXE}
$screenSaverPath = [Win32Helpers]::GetLongPath($screenSaverPath) #this converts what is often an old school 8.3 tilde short path to a long path that powershell core can launch, legacy powershell didn't have this problem
$screenSaverFileName = [System.IO.Path]::GetFileName($screenSaverPath)

$timer = New-Object System.Timers.Timer
$timer.Interval = 1000
$timer.add_Elapsed( {
    $mouse = [System.Windows.Forms.Cursor]::Position
    $bounds = [System.Windows.Forms.Screen]::FromPoint($mouse).Bounds #thank you! - http://stackoverflow.com/questions/26402955/finding-monitor-screen-on-which-mouse-pointer-is-present

    # Here's the BEEF
    <#  __  __              _          __  __            __              ____
       / / / /__  ________ ( )_____   / /_/ /_  ___     / /_  ___  ___  / __/
      / /_/ / _ \/ ___/ _ \|// ___/  / __/ __ \/ _ \   / __ \/ _ \/ _ \/ /_
     / __  /  __/ /  /  __/ (__  )  / /_/ / / /  __/  / /_/ /  __/  __/ __/
    /_/ /_/\___/_/   \___/ /____/   \__/_/ /_/\___/  /_.___/\___/\___/_/     #>

    # mouse/screen coords are based on UPPER LEFT equals X=0,Y=0
    # just expand this to multiple IF blocks to support triggers in additional mouse locations

    # the following expression currently triggers at the LOWER RIGHT corner
    # i.e. mouseX within 10px of right edge, mouseY 10px from bottom edge

    # this targets my second screen on the right where the Screen.Bounds.X has a non zero value.
    # see readme.md for brief explanation, or drop me an issue if no worky for your monitor arrangement.
    
    if ($mouse.X -lt 10 -and $mouse.Y -lt 10) { # upper left corner

      # invoke Windows lock screen
      #Invoke-Command { rundll32.exe user32.dll, LockWorkStation }

      # and turn off the display
      [Win32Helpers]::PowerOff()
    }
    elseif ($mouse.X - $bounds.X -gt $bounds.Width - 10 -and $mouse.Y -lt 10) { # upper right corner
      if (!(get-process $screenSaverFileName -ErrorAction SilentlyContinue)) {
        & $screenSaverPath
      }
    }

    ###################################################################################################
    ### uncomment the following to determine mouse coords for your (multiple) monitor configuration ###
    ###################################################################################################
    # run the ps1 from console to see this output
    #debug: Write-Host "x: $($mouse.X), y:$($mouse.Y), width: $($bounds.Width), height: $($bounds.Height), trigger: $($mouse.X-$bounds.X -gt $bounds.Width-10 -and $mouse.Y -gt $bounds.Height-10)"
  })

#just to initialize the window handle to give to $timer.SynchronizingObject below
showContextMenu; $contextMenu.Hide();

#frugally reusing $contextMenu vs firing up another blank form, not really necessary but i was curious if it'd work... the notify icon itself does not implement InvokeRequired
#see this for why SynchronizingObject necessary: http://stackoverflow.com/questions/15505812/why-dont-add-eventname-work-with-timer
$timer.SynchronizingObject = $contextMenu

$timer.start()
$notifyIcon.Visible = $true
[System.Windows.Forms.Application]::Run()
