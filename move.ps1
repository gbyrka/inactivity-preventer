Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class MouseMover {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
    
    public struct POINT {
        public int X;
        public int Y;
    }
}
"@ | Out-Null

while ($true) {
    $point = New-Object MouseMover+POINT
    [MouseMover]::GetCursorPos([ref]$point) | Out-Null
    $x = $point.X
    $y = $point.Y
    [MouseMover]::SetCursorPos($x, $y + 1) | Out-Null
    Start-Sleep -Milliseconds 100
    [MouseMover]::SetCursorPos($x, $y) | Out-Null
    Start-Sleep -Seconds 59
}
