using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Windows.Forms;

[assembly: AssemblyTitle("WampDeck")][assembly: AssemblyProduct("WampDeck")]
[assembly: AssemblyDescription("WampDeck panel launcher")]
[assembly: AssemblyVersion("2.0.0.0")]
[assembly: AssemblyFileVersion("2.0.0.0")]

namespace WampDeck
{
    internal static class Launcher
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern IntPtr FindWindow(string className, string windowName);

        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int command);

        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        // Give the PowerShell-hosted panel a WampDeck AppUserModelID so the
        // taskbar shows the WampDeck icon instead of "Windows PowerShell 5.1".
        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
        private static extern void SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string appID);

        private static bool IsProcessElevated()
        {
            try
            {
                using (WindowsIdentity identity = WindowsIdentity.GetCurrent())
                {
                    return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
                }
            }
            catch
            {
                return false;
            }
        }

        private static string DropMarkerPath()
        {
            return Path.Combine(Path.GetTempPath(), "wampdeck-elevation-drop.txt");
        }

        private static bool RecentlyDropped()
        {
            try
            {
                string marker = DropMarkerPath();
                if (!File.Exists(marker))
                {
                    return false;
                }
                return (DateTime.UtcNow - File.GetLastWriteTimeUtc(marker)).TotalSeconds < 15;
            }
            catch
            {
                return false;
            }
        }

        // A stable per-folder id so two different WampDeck copies can run
        // side by side, while two launches of the same copy share one panel.
        private static string InstanceId()
        {
            string root = Path.GetFullPath(AppDomain.CurrentDomain.BaseDirectory)
                .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
                .ToLowerInvariant();

            using (SHA1 sha = SHA1.Create())
            {
                byte[] hash = sha.ComputeHash(Encoding.UTF8.GetBytes(root));
                StringBuilder builder = new StringBuilder(16);
                for (int i = 0; i < 8; i++)
                {
                    builder.Append(hash[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        private static bool IsRunning(string mutexName)
        {
            try
            {
                using (Mutex mutex = Mutex.OpenExisting(mutexName))
                {
                    return true;
                }
            }
            catch (WaitHandleCannotBeOpenedException)
            {
                return false;
            }
            catch (UnauthorizedAccessException)
            {
                // The mutex exists but this process may not open it.
                return true;
            }
        }

        private static void ActivateExisting(string eventName, bool tray)
        {
            if (tray)
            {
                return;
            }

            // The running panel listens on this event and restores itself,
            // including when it is hidden in the notification area. The event
            // is per install folder, so this never touches another copy.
            try
            {
                using (EventWaitHandle activation = EventWaitHandle.OpenExisting(eventName))
                {
                    activation.Set();
                    return;
                }
            }
            catch (WaitHandleCannotBeOpenedException) { }
            catch (UnauthorizedAccessException) { }

            // Legacy fallback for a panel built before the activation event.
            IntPtr window = FindWindow(null, "WampDeck");
            if (window != IntPtr.Zero)
            {
                ShowWindow(window, 9); // SW_RESTORE
                SetForegroundWindow(window);
            }
        }

        [STAThread]
        private static void Main(string[] args)
        {
            try { SetCurrentProcessExplicitAppUserModelID("OryxIndia.WampDeck.Panel"); } catch { }

            // Setup runs elevated. Its post-install launch, and anyone who uses
            // "Run as administrator", can hand us an elevated token even though
            // the launcher manifest is asInvoker. An elevated panel starts
            // elevated nginx/mysqld that a later normal launch cannot stop.
            // Re-launch through the shell (medium integrity) and exit. Explorer
            // does not forward arguments, so this path starts a visible panel;
            // the recent-marker guard stops a loop if Explorer itself is
            // elevated.
            if (IsProcessElevated() && !RecentlyDropped())
            {
                try
                {
                    File.WriteAllText(DropMarkerPath(), DateTime.UtcNow.ToString("o"));

                    ProcessStartInfo relaunch = new ProcessStartInfo();
                    relaunch.FileName = "explorer.exe";
                    relaunch.Arguments = "\"" + Application.ExecutablePath + "\"";
                    relaunch.UseShellExecute = true;
                    Process.Start(relaunch);
                    return;
                }
                catch
                {
                    // Fall through and start the panel with the current token.
                }
            }

            string root = AppDomain.CurrentDomain.BaseDirectory;
            string script = Path.Combine(root, "panel.ps1");
            bool tray = false;

            foreach (string argument in args)
            {
                if (string.Equals(argument, "-Tray", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(argument, "--tray", StringComparison.OrdinalIgnoreCase))
                {
                    tray = true;
                }
            }

            if (!File.Exists(script))
            {
                MessageBox.Show(
                    "panel.ps1 was not found next to WampDeck.exe.\r\n\r\nKeep the launcher inside the WampDeck folder.",
                    "WampDeck",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            string id = InstanceId();
            string mutexName = @"Local\WampDeckPanel_" + id;
            string eventName = @"Local\WampDeckActivate_" + id;

            // Check the mutex first: it exists from the first moment the
            // panel starts, before its window is created.
            if (IsRunning(mutexName))
            {
                ActivateExisting(eventName, tray);
                return;
            }

            string powerShell = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.System),
                @"WindowsPowerShell\v1.0\powershell.exe");
            if (!File.Exists(powerShell))
            {
                powerShell = "powershell.exe";
            }

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = powerShell;
            startInfo.Arguments = "-Sta -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" +
                script + "\"" + (tray ? " -Tray" : string.Empty);
            startInfo.WorkingDirectory = root;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;

            try
            {
                Process.Start(startInfo);
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Could not start WampDeck.\r\n\r\n" + ex.Message,
                    "WampDeck",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }
    }
}
