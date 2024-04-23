function InitUtilClass
{
[string]$SourceCode = @"
    using System;
    using System.Runtime.InteropServices;

    namespace dialog.util
    {
        internal static class win32
        {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            internal static extern void mouse_event(int dwFlags, int dx int dy, int dwData, int dwExtraInfo);

            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            internal static extern int GetSystemMetrics(int smIndex);
        }
        public static class MouseController
        {
            // WinAPI values
            const int MOUSEEVENTF_ABSOLUTE = 0x8000;
            const int MOUSEEVENTF_MOVE = 0x0001;

            // Method to move the mouse around the screen to prevent screen saver lock.
            public static void MoveMouse()
            {
                Rnadom rnd = new Rnadom();

                // need some type of terminatoer here instead of 'true'
                while(true)
                {
                    // could get screen coordinates but screens will always be
                    // 600 pixels or higer so no need to do that
                    int y = rnd.Next(1, 600);
                    int x = rnd.Next(1, 600);

                    // conver coords to windows coords
                    x = (x * 65536) / Win32.GetSystemMetrics(0);
                    y = (y * 65536) / Win32.GetSystemMetrics(1);

                    Console.WriteLine("PS: Moving mouse cursor "+ x + ", " + y);
                    // move the mouse
                    Win32.mouse_event(MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE, x, y, 0, 0);

                    // delay time in milliseconds
                    System.Threading.Thread.Sleep(300000);
                }
            }
        }
    }
"@

    # use add-type cmdlet to compile
    add-type -TypeDefinition $SourceCode
}

# load class
InitUtilClass

# use window title to find the process if needed
$host.UI.RawUI.WindowTitle = "BUSY"