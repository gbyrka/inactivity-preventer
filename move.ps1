Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class PowerHelper {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
    
    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);
    
    public struct POINT {
        public int X;
        public int Y;
    }
}

[Flags]
public enum EXECUTION_STATE : uint {
    ES_CONTINUOUS = 0x80000000,
    ES_SYSTEM_REQUIRED = 0x00000001,
    ES_DISPLAY_REQUIRED = 0x00000002
}
"@ | Out-Null

function Prevent-Sleep {
    [PowerHelper]::SetThreadExecutionState(
        [EXECUTION_STATE]::ES_CONTINUOUS -bor
        [EXECUTION_STATE]::ES_SYSTEM_REQUIRED -bor
        [EXECUTION_STATE]::ES_DISPLAY_REQUIRED
    ) | Out-Null
}

try {
    while ($true) {
        Prevent-Sleep
        $point = New-Object PowerHelper+POINT
        [PowerHelper]::GetCursorPos([ref]$point) | Out-Null
        $x = $point.X
        $y = $point.Y
        $newX = $x + 10
        $newY = $y + 10
        [PowerHelper]::SetCursorPos($newX, $newY) | Out-Null
        Start-Sleep -Milliseconds 100
        [PowerHelper]::SetCursorPos($x, $y) | Out-Null
        Start-Sleep -Seconds 59
    }
} finally {
    # Reset execution state
    [PowerHelper]::SetThreadExecutionState([EXECUTION_STATE]::ES_CONTINUOUS) | Out-Null
}
