/* ------------------------------------------------------------------------------------ *
 * EPITECH PROJECT - Sat, Aug, 2025                                                     *
 * Title           - integrit                                                           *
 * Description     - ServerDetectionApp                                                 *
 * ------------------------------------------------------------------------------------ */

using System;
using System.Diagnostics;
using System.Windows.Forms;
using System.IO;

public class Function
{
    public string? Type { get; set; }
    public string? Filepath { get; set; }
    public Function(string? type, string? filepath)
    {
        Type = type;
        Filepath = filepath;
    }
}

namespace ServerDetectionApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            comboBoxServerType.Items.AddRange(new string[]
            {
                "Active Directory", "mssql", "RDS", "print", "hypervisor", "file"
            });
        }

        private void ButtonDetect_Click(object sender, EventArgs e)
        {
            string selectedServer = comboBoxServerType.SelectedItem?.ToString();
            if (string.IsNullOrEmpty(selectedServer))
            {
                labelResult.Text = "Please select a server type.";
                return;
            }

            string? scriptPath = DetectServer(selectedServer);
            if (!string.IsNullOrEmpty(scriptPath))
            {
                RunScript(scriptPath);
                labelResult.Text = $"Detection script launched for: {selectedServer}";
            }
            else
            {
                labelResult.Text = "Server type not recognized.";
            }
        }

        static void RunScript(string scriptPath)
        {
            var p = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "powershell",
                    Arguments = $"-ExecutionPolicy Bypass -File \"{scriptPath}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            p.Start();
            Console.WriteLine(p.StandardOutput.ReadToEnd());
            p.WaitForExit();
        }

        private string? DetectServer(string serverType)
        {
            var functions = new Function[]
            {
                new Function("Active Directory", Path.Combine("scripts", "ActiveDirectory.ps1")),
                new Function("mssql", Path.Combine("scripts", "MsSql.ps1")),
                new Function("RDS", Path.Combine("scripts", "RDS.ps1")),
                new Function("print", Path.Combine("scripts", "Print.ps1")),
                new Function("hypervisor", Path.Combine("scripts", "Hypervisor.ps1")),
                new Function("file", Path.Combine("scripts", "File.ps1")),
            };

            for (int i = 0; i < functions.Length; i++)
            {
                if (serverType.Equals(functions[i].Type, StringComparison.OrdinalIgnoreCase))
                    return functions[i].Filepath;
            }
            return null;
        }
    }
}
