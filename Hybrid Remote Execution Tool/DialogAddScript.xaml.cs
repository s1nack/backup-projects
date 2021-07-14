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
    /// Interaction logic for DialogAddScript.xaml
    /// </summary>
    public partial class DialogAddScript : Window
    {
        public DialogAddScript()
        {
            InitializeComponent();
        }

        private void DialogAddScriptOKButton_Click(object sender, RoutedEventArgs e)
        {
            XmlDataProvider xdp = this.TryFindResource("ScriptsData") as XmlDataProvider;
            if (xdp != null)
            {
                XmlDocument XMLHosts = new XmlDocument();
                XMLHosts.Load(MainWindow.XML_Scripts_Path);
                if (XMLHosts == null)
                {
                    MessageBox.Show("Can't locate " + MainWindow.XML_Scripts_Path);
                }
                else
                {
                    XmlElement newscript = XMLHosts.CreateElement("Script");
                    XmlAttribute newscriptattr = XMLHosts.CreateAttribute("Group");
                    newscriptattr.Value = GroupTextBox.Text;
                    newscript.SetAttributeNode(newscriptattr);
                    XmlElement newFile = XMLHosts.CreateElement("File");
                    newFile.InnerText = FileTextBox.Text;
                    newscript.AppendChild(newFile);
                    XmlElement newDescription = XMLHosts.CreateElement("Description");
                    newDescription.InnerText = DescriptionTextBox.Text;
                    newscript.AppendChild(newDescription);
                    XMLHosts.DocumentElement.InsertAfter(newscript, XMLHosts.DocumentElement.LastChild);
                    XMLHosts.Save(MainWindow.XML_Scripts_Path);
                }
                this.DialogResult = true;
            }
            else
            {
                this.DialogResult = false;
            }
        }

        private void DialogAddScriptCANCELButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }
    }
}
