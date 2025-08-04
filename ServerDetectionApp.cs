using System;
using System.Windows.Forms;

namespace ServerDetecionApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            comboBoxServerType.Items.AddRange(new string[]{"Active Directory",
                "mssql", "windows server 2019", "windows server 2021"});
        }

        private void ButtonDetect_Click(object sender, EventArgs e)
        {
            string selectedServer = comboBoxServerType.SelectedItem?.ToString();
            string result = DetectServer(selectedServer);
            labelResult.Text = result;
        }

        private string DetectedServer(string serverType)
        {
            string scriptpath = string.Empty;
            switch (serverType)
            {
                case "Active Directory":
                    /*scriptpath*/
                    return "Active Directory Server is running on this device.";
                case "mssql":
                    /*scriptpath*/
                    return "mssql Server is running on this device.";
                case "windows server 2019":
                    /*scriptpath*/
                    return "windows server 2019 is running on this device";
                case "windows server 2021":
                    /*scriptpath*/
                    return "windows server 2021 is running on this device";
                default:
                    scriptpath = "C:\\Users\\Public\\Server-scripting\\smbv1checker.ps1";
                    return "Basic server is running on this device.";
            }
        }
    }
}
