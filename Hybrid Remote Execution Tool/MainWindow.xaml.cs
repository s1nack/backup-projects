using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Xml;
using System.Diagnostics;
using System.Threading;
using System.ComponentModel;
using Microsoft.Win32;
using System.DirectoryServices;


/*
 * add option : force script reload even if it already has been uploaded (psexec -f)
 */

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public static List<string> selectedMachines_List = new List<string>();
        public static string exec_Script;
        public static int poolSize = 5; 
        public static int nbMachines = 0;

        public static XmlDataProvider xdp_hosts;

        public static string XML_Hosts_Path = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\hosts.xml";
        public static string XML_Scripts_Path = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData) + "\\scripts.xml";

        public MainWindow()
        {
            InitializeComponent();

            xdp_hosts = this.Resources["HostsData"] as XmlDataProvider;

            Uri uri_hostsfile_path = new Uri(XML_Hosts_Path);
            (this.Resources["HostsData"] as XmlDataProvider).Source = uri_hostsfile_path;
            (this.Resources["HostsData"] as XmlDataProvider).XPath = "Hosts/Host";

            Uri uri_scriptsfile_path = new Uri(XML_Scripts_Path);
            (this.Resources["ScriptsData"] as XmlDataProvider).Source = uri_scriptsfile_path;
            (this.Resources["ScriptsData"] as XmlDataProvider).XPath = "Scripts/Script";

            FileSystemWatcher f = new FileSystemWatcher();
            f.Path = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            f.Filter = "hosts.xml";
            f.Changed += new FileSystemEventHandler(f_Changed); 
            f.EnableRaisingEvents = true;

            FileSystemWatcher f2 = new FileSystemWatcher();
            f2.Path = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            f2.Filter = "scripts.xml";
            f2.Changed += new FileSystemEventHandler(f2_Changed);
            f2.EnableRaisingEvents = true;

            InitRemEx();
        }

/**********************************************************************************************/
/****************************************   CALLBACKS   ***************************************/
/**********************************************************************************************/

        // REFRESH MACHINES LIST WHEN CHANGED
        void f_Changed(object sender, FileSystemEventArgs e)
        {
            XmlDataProvider odp = this.TryFindResource("HostsData") as XmlDataProvider;
            if (odp != null)
            {
                using (odp.DeferRefresh())
                {
                    odp.Source = new Uri(XML_Hosts_Path, UriKind.Absolute);
                }
            }
        }

        // REFRESH SCRIPTS LIST WHEN CHANGED
        void f2_Changed(object sender, FileSystemEventArgs e)
        {
            XmlDataProvider odp = this.TryFindResource("ScriptsData") as XmlDataProvider;
            if (odp != null)
            {
                using (odp.DeferRefresh())
                {
                    odp.Source = new Uri(XML_Scripts_Path, UriKind.Absolute);
                }
            }
        }

/**********************************************************************************************/
/****************************************   INITIALIZATION   **********************************/
/**********************************************************************************************/
        private void InitRemEx()
        {
            // check psexec exists (registry key), if not message box
            // check reg key "Accept EULA"
            // check path contains psexec, if not add it
            // check fichiers XML exist

            //if (check_psexec_registry() == true)
            //    MessageBox.Show("INSTALLED OK");
            //else
            //    MessageBox.Show("NOT INSTALLED");

            check_path();
            check_xml_files();
        }

        private bool check_psexec_registry()
        {
            const string psexecKeyName = @"Software\7-Zip\FM\Columns\";

            using (RegistryKey root = Registry.CurrentUser)
            {
                if (root != null)
                {
                    using (RegistryKey psexecKey = root.OpenSubKey(psexecKeyName, false))
                    {
                        if (psexecKey == null)
                        {
                            //MessageBox.Show("Unable to open " + root.Name + psexecKeyName);
                            return false;
                        }
                        else
                        {
                            //string contentKey = psexecKey.GetValue("7-Zip.PE").ToString();
                            //MessageBox.Show("Success open : " + contentKey);
                            return true;
                        }
                    }
                }
                else
                {
                    return false;
                }
            }
        }

        private bool set_EULA()
        {
            return false;
        }

        private bool check_path()
        {
            string env = System.Environment.GetEnvironmentVariable("Path");
            return false;
        }

        private bool set_path()
        {
            return false;
        }

        private bool check_xml_files()
        {
            if (!File.Exists(XML_Hosts_Path))
            {
                MessageBox.Show(XML_Hosts_Path + " not found !");
                return false;
            }

            if (!File.Exists(XML_Scripts_Path))
            {
                MessageBox.Show(XML_Scripts_Path + " not found !");
                return false;
            }

            return true;
        }

/**********************************************************************************************/
/****************************************   ACTIONS   *****************************************/
/**********************************************************************************************/

        private void button_DryRun_Click(object sender, RoutedEventArgs e)
        {
            // CLEAR PREVIOUS SELECTIONS
            selectedMachines_List.Clear();
            exec_Script = null;

            // GET SELECTED MACHINES
            foreach (var selectedMachines in MachinesList.SelectedItems.OfType<XmlElement>())
            {
                string foo = selectedMachines["HostName"].InnerText;
                selectedMachines_List.Add(foo + Environment.NewLine);
            }

            // GET SELECTED SCRIPT
            // refactoring needed (only 1 element is selected, no foreach needed)
            foreach (var selectedScript in ScriptsList.SelectedItems.OfType<XmlElement>())
            {
                string bar = selectedScript["File"].InnerText;
                exec_Script = bar;
            }

            // DISPLAY WHAT WOULD BE RUN
            var message_Dryrun = string.Join(String.Empty, selectedMachines_List);
            MessageBox.Show("The following script :" + Environment.NewLine + exec_Script + Environment.NewLine +
                Environment.NewLine + "Will be executed on : " + Environment.NewLine + message_Dryrun + Environment.NewLine + "Options : " + Environment.NewLine + poolSize.ToString() + " parallel executions",
                "Dry run", MessageBoxButton.OK, MessageBoxImage.Exclamation);
        }

        private void button_Run_Click(object sender, RoutedEventArgs e)
        {
            // CLEAR PREVIOUS SELECTIONS
            selectedMachines_List.Clear();
            exec_Script = null;

            // GET SELECTED MACHINES
            foreach (var selectedMachines in MachinesList.SelectedItems.OfType<XmlElement>())
            {
                string selectedMachine = selectedMachines["HostName"].InnerText;
                selectedMachines_List.Add(selectedMachine);
            }
            nbMachines = MachinesList.SelectedItems.Count;

            // GET SELECTED SCRIPT
            // refactoring needed (only 1 element is selected, no foreach needed)
            foreach (var selectedScript in ScriptsList.SelectedItems.OfType<XmlElement>())
            {
                string bar = selectedScript["File"].InnerText;
                exec_Script = bar;
            }

            // RUN THE EXECUTOR WINDOW
            ExecutorWindow myExecWindow = new ExecutorWindow();
            myExecWindow.Show();
        }

        private void button_QuickAction_Ping_Click(object sender, RoutedEventArgs e)
        {
            Button QA_Button = sender as Button;

            // CLEAR PREVIOUS SELECTIONS
            selectedMachines_List.Clear();
            exec_Script = null;

            // GET SELECTED MACHINES
            foreach (var selectedMachines in MachinesList.SelectedItems.OfType<XmlElement>())
            {
                string selectedMachine = selectedMachines["HostName"].InnerText;
                selectedMachines_List.Add(selectedMachine);
            }
            nbMachines = MachinesList.SelectedItems.Count;

            exec_Script = (string)QA_Button.Content;

            QuickActions myQuickAction = new QuickActions();
            myQuickAction.RunExecutorFromQA();
        }

        private void button4_Click(object sender, RoutedEventArgs e)
        {
            List<string> mylist = new List<string>();
            mylist.Clear();
            mylist.Add("192.168.1.8");
            Executor myexecutor = new Executor(3,1,mylist,@"D:\ipconfig.bat");
            myexecutor.RunWhileRemainMachines(null,null);
            MessageBox.Show("END");
        }
    }
}
 