using System;
using System.Windows.Forms;

namespace ServerDetecionApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
            comboBoxServerType.Items.AddRange(new string[]{"Active Directory", "mssql"});
        }

        private void ButtonDetect_Click(object sender, EventArgs e)
        {
            string selectedServer = comboBoxServerType.SelectedItem?.ToString();
            string result = DetectServer(selectedServer);
            labelResult.Text = result;
        }

        private string DetectedServer(string serverType)
        {
            switch (serverType)
            {
                case "Active Directory":
                    return "Active Directory Server is running on this device.";
                case "mssql":
                    return "mssql Server is running on this device.";
                default:
                    return "Basic server is running on this device.";
            }
        }
    }
}
