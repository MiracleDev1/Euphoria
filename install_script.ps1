# Function to check if Steam is running
function Test-SteamRunning {
    return (Get-Process -Name "steam" -ErrorAction SilentlyContinue) -ne $null
}

# Function to get Steam window handle dynamically
function Get-SteamWindowHandle {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@
    # Try finding the Steam window
    $steamHwnd = [Win32]::FindWindow("Valve001", $null)
    
    # If we didn't find it, look for any active Steam window
    if ($steamHwnd -eq [IntPtr]::Zero) {
        $steamProcess = Get-Process | Where-Object { $_.MainWindowTitle -match "Steam" }
        if ($steamProcess) {
            $steamHwnd = [Win32]::GetForegroundWindow()
        }
    }
    return $steamHwnd
}

# Function to minimize Steam
function Hide-SteamWindow {
    $steamHwnd = Get-SteamWindowHandle
    if ($steamHwnd -ne [IntPtr]::Zero) {
        Write-Host "Minimizing Steam window..."
        [Win32]::ShowWindow($steamHwnd, 6)  # 6 = Minimize
    } else {
        Write-Host "Steam window not found! Cannot minimize."
    }
}

# Step 1: Start Steam if it's not running
if (-not (Test-SteamRunning)) {
    Write-Host "Launching Steam..."
    Start-Process "steam://open/console"
    while (-not (Test-SteamRunning)) {
        Start-Sleep -Milliseconds 500
    }
    Write-Host "Steam launched successfully!"
}

# Step 2: Open the Steam console
Write-Host "Opening Steam console..."
Start-Process "steam://open/console"
Start-Sleep -Milliseconds 200

# Step 3: Focus the Steam console window
Write-Host "Focusing Steam console..."
Start-Sleep -Milliseconds 50

# Step 4: Send keyboard inputs (Expecting Flutter to handle clipboard)
Write-Host "Sending keyboard inputs..."

Add-Type -AssemblyName System.Windows.Forms

# Save current cursor position
$originalPos = [System.Windows.Forms.Cursor]::Position

# Calculate center of the screen
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$centerX = [int]($screenWidth / 2)
$centerY = [int]($screenHeight / 2)

# Move cursor to center of the screen
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($centerX, $centerY)
Start-Sleep -Milliseconds 100

# Perform mouse click using native user32.dll
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Clicker {
    [DllImport("user32.dll")]
    public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
}
"@

[Clicker]::mouse_event(0x0002, 0, 0, 0, 0) # Mouse left down
Start-Sleep -Milliseconds 50
[Clicker]::mouse_event(0x0004, 0, 0, 0, 0) # Mouse left up
Start-Sleep -Milliseconds 100

# Restore cursor position
[System.Windows.Forms.Cursor]::Position = $originalPos

# Send keyboard inputs to Steam
$wshell = New-Object -ComObject WScript.Shell
$wshell.SendKeys("{TAB}")   # Focus input field
Start-Sleep -Milliseconds 500
$wshell.SendKeys("^v")      # Ctrl + V (paste)
Start-Sleep -Milliseconds 50
$wshell.SendKeys("{ENTER}") # Execute command

# Step 5: Minimize Steam
Write-Host "Minimizing Steam..."
Hide-SteamWindow

Write-Host "Script execution completed!"