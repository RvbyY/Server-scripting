/* ------------------------------------------------------------------------------------ *
 *                                                                                      *
 * EPITECH PROJECT - Sat, Aug, 2025                                                     *
 * Title           - integrit                                                           *
 * Description     -                                                                    *
 *     ServerDetectionApp                                                               *
 *                                                                                      *
 * ------------------------------------------------------------------------------------ *
 *                                                                                      *
 *       _|_|_|_|  _|_|_|    _|_|_|  _|_|_|_|_|  _|_|_|_|    _|_|_|  _|    _|           *
 *       _|        _|    _|    _|        _|      _|        _|        _|    _|           *
 *       _|_|_|    _|_|_|      _|        _|      _|_|_|    _|        _|_|_|_|           *
 *       _|        _|          _|        _|      _|        _|        _|    _|           *
 *       _|_|_|_|  _|        _|_|_|      _|      _|_|_|_|    _|_|_|  _|    _|           *
 *                                                                                      *
 * ------------------------------------------------------------------------------------ */

using System;
using System.Windows.Forms;

public delegate void FunctionDelegate(string[] args, Env env);

public class Function
{
    public type Type { get; set; }
    public FunctionDelegate FunctionToCall { get; set; }
    public string Filepath { get; set; }
}

namespace ServerDetecionApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            comboBoxServerType.Items.AddRange(new string[]{"Active Directory",
                "mssql", "RDS", "print", "hypervisor", "file"});
        }

        private void ButtonDetect_Click(object sender, EventArgs e)
        {
            string selectedServer = comboBoxServerType.SelectedItem?.ToString();
            string result = DetectServer(selectedServer);
            labelResult.Text = result;
        }

        static void RunScript(string scriptPath)
        {
            var p = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "powershell",
                    Arguments = $"-ExecutionPolicy Bypass -File {scriptPath}",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                }
            };
            p.Start();
            Console.WriteLine(p.StandardOutput.ReadToEnd());
            p.WaitForExit();
        }

        private string DetectedServer(string serverType)
        {
            string scriptpath = string.Empty;
           switch (serverType)
           {
               case "Active Directory":
                   /*scriptpath*/
                   break;
               case "mssql":
                   /*scriptpath*/
                   break;
               case "RDS":
                   /*scriptpath*/
                   break;
               case "print":
                   /*scriptpath*/
                   break;
               case "hypervisor":
                   /*scriptpath*/
                   break;
               case "file":
               /*scriptpath*/
               default:
                   scriptpath = "C:\\Users\\Public\\Server-scripting\\smbv1checker.ps1";
                   break;
           }
        }
    }
}

// // Define the delegate type
// public delegate void FunctionDelegate(string[] args, Env env);

// // Enum for function types (optional)
// public enum FunctionType
// {
//     Semicolon,
//     Pipe,
//     RedirectR,
//     DoubleRedirectR,
//     RedirectL,
//     DoubleRedirectL,
//     Error
// }

// // Class to store function information
// public class Function
// {
//     public FunctionType Type { get; set; }
//     public FunctionDelegate FunctionToCall { get; set; }
//     public string Filepath { get; set; }

//     // Constructor
//     public Function(FunctionType type, FunctionDelegate functionToCall, string filepath)
//     {
//         Type = type;
//         FunctionToCall = functionToCall;
//         Filepath = filepath;
//     }
// }

// // Example usage
// public class Example
// {
//     public static void MySemicolon(string[] args, Env env)
//     {
//         // Your logic here
//     }

//     public static void Main()
//     {
//         // Array of functions similar to your C array
//         var functions = new Function[]
//         {
//             new Function(FunctionType.Semicolon, MySemicolon, "path/to/semicolon/file"),
//             new Function(FunctionType.Pipe, MyPipe, "path/to/pipe/file")
//             // Add more functions as necessary
//         };

//         // Example of calling a function
//         var semicolonFunc = functions[0];  // Access the semicolon function
//         semicolonFunc.FunctionToCall(new string[] { "arg1", "arg2" }, new Env()); // Call it
//     }

//     public static void MyPipe(string[] args, Env env)
//     {
//         // Another function implementation
//     }
// }