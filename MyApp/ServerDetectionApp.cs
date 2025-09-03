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
    public Function(string? type, string? filepath) {
        Type = type;
        Filepath = filepath;
    }
}

namespace ServerDetectionApp
{
    public class MainForm : Form {
        private ComboBox comboBoxServerType;
        private Label labelResult;
        private Button buttonDetect;

        public MainForm() {
            InitializeComponent();
            comboBoxServerType.Items.AddRange(new string[] {
                "Active Directory", "mssql", "RDS", "print", "hypervisor", "file"
            });
        }

        private void InitializeComponent()
        {
            this.comboBoxServerType = new ComboBox();
            this.labelResult = new Label();
            this.buttonDetect = new Button();
            this.comboBoxServerType.Location = new System.Drawing.Point(20, 20);
            this.comboBoxServerType.Size = new System.Drawing.Size(200, 25);
            this.labelResult.Location = new System.Drawing.Point(20, 60);
            this.labelResult.Size = new System.Drawing.Size(300, 30);
            this.labelResult.Text = "";
            this.buttonDetect.Location = new System.Drawing.Point(20, 100);
            this.buttonDetect.Size = new System.Drawing.Size(100, 30);
            this.buttonDetect.Text = "Detect";
            this.buttonDetect.Click += ButtonDetect_Click;
            this.Text = "Server Detection App";
            this.ClientSize = new System.Drawing.Size(400, 200);
            this.Controls.Add(this.comboBoxServerType);
            this.Controls.Add(this.labelResult);
            this.Controls.Add(this.buttonDetect);
        }

        private void ButtonDetect_Click(object sender, EventArgs e)
        {
            string selectedServer = comboBoxServerType.SelectedItem?.ToString();
            string? scriptPath;
            string result;
            string f = @".\info.txt";

            if (string.IsNullOrEmpty(selectedServer))
            {
                labelResult.Text = "Please select a server type.";
                return;
            }
            scriptPath = DetectServer(selectedServer);
            if (!string.IsNullOrEmpty(scriptPath))
            {
                if (File.Exists(f))
                    File.Delete(f);
                else
                    File.Create(f).Close();
                if (!scriptPath.Equals(Path.Combine("scripts", "Hypervisor.ps1")))
                    RunScript(Path.Combine("scripts", "Hypervisor.ps1"));
                result = RunScript(scriptPath);
                labelResult.Text = $"Detection script launched for: {selectedServer}";
                RunScript(Path.Combine("scripts", "txtToHTML.ps1"));
            }
            else
                labelResult.Text = "Server type not recognized.";
        }

        private static string RunScript(string scriptPath)
        {
            var p = new Process {
                StartInfo = new ProcessStartInfo {
                    FileName = "powershell",
                    Arguments = $"-ExecutionPolicy Bypass -File \"{scriptPath}\"",
                    RedirectStandardError = true,
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };

            p.Start();
            string output = p.StandardOutput.ReadToEnd();
            string error = p.StandardError.ReadToEnd();
            p.WaitForExit();
            return string.IsNullOrEmpty(error) ? output : $"Error: {error}";
        }


        private string? DetectServer(string serverType)
        {
            var functions = new Function[] {
                new Function("Active Directory", Path.Combine("scripts", "ActiveDirectory.ps1")),
                new Function("mssql", Path.Combine("scripts", "MsSql.ps1")),
                new Function("RDS", Path.Combine("scripts", "RDS.ps1")),
                new Function("print", Path.Combine("scripts", "Print.ps1")),
                new Function("hypervisor", Path.Combine("scripts", "Hypervisor.ps1")),
                new Function("file", Path.Combine("scripts", "File.ps1")),
            };

            foreach (var func in functions) {
                Console.WriteLine("server: {0}", func.Type);
                if (serverType.Equals(func.Type, StringComparison.OrdinalIgnoreCase))
                {
                    return func.Filepath;
                }
            }
            return null;
        }

        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }
}
