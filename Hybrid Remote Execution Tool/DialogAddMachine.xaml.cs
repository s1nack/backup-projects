using System;
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
using System.Windows.Shapes;
using System.Xml;
using System.IO;
using System.Resources;
using System.Globalization;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for DialogAddMachine.xaml
    /// </summary>
    public partial class DialogAddMachine : Window
    {
        string AddMachine_hostname;
        string AddMachine_vessel;
        string AddMachine_os;

        public DialogAddMachine()
        {
            InitializeComponent();
        }

        private void DialogAddMachineOKButton_Click(object sender, RoutedEventArgs e)
        {
            AddMachine_hostname = HostnameTextBox.Text;
            AddMachine_vessel = VesselTextBox.Text;
            if (WindowsRadioButton.IsChecked == true)
                AddMachine_os = WindowsRadioButton.Content.ToString();
            else if (LinuxRadioButton.IsChecked == true)
                AddMachine_os = LinuxRadioButton.Content.ToString();
            else if (CiscoRadioButton.IsChecked == true)
                AddMachine_os = CiscoRadioButton.Content.ToString();
            else
                AddMachine_os = "Windows";
            //XmlDataProvider xdp = this.TryFindResource("HostsData") as XmlDataProvider;

            bool myAdd = AddMachine(AddMachine_hostname, AddMachine_vessel, AddMachine_os, MainWindow.xdp_hosts);

            if (!myAdd)
                MessageBox.Show("DialogAddMachine.AddMachine() failed.");
        }

        private void DialogAddMachineCANCELButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }

        public static bool AddMachine(string hostname, string vessel, string os, XmlDataProvider xmlResource)
        {
            if (xmlResource != null)
            {
                XmlDocument XMLHosts = new XmlDocument();
                XMLHosts.Load(MainWindow.XML_Hosts_Path);
                if (XMLHosts == null)
                {
                    MessageBox.Show("Can't locate " + MainWindow.XML_Hosts_Path);
                }
                else
                {
                    XmlElement newmachine = XMLHosts.CreateElement("Host");

                    XmlAttribute newmachineattr = XMLHosts.CreateAttribute("Vessel");
                    newmachineattr.Value = vessel;
                    newmachine.SetAttributeNode(newmachineattr);

                    XmlElement newHostname = XMLHosts.CreateElement("HostName");
                    newHostname.InnerText = hostname;
                    newmachine.AppendChild(newHostname);

                    XmlElement newOS = XMLHosts.CreateElement("OS");
                    newOS.InnerText = os;
                    newmachine.AppendChild(newOS);

                    XMLHosts.DocumentElement.InsertAfter(newmachine, XMLHosts.DocumentElement.LastChild);
                    XMLHosts.Save(MainWindow.XML_Hosts_Path);
                }
                return true;
            }
            else
            {
                MessageBox.Show("DialogAddMachine.AddMachine() : Failed to load resource HostsData");
                return false;
            }
        }
    }
}
