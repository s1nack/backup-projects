using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.DirectoryServices;
using System.IO;
using System.Windows.Controls;
using System.Windows;
using System.ComponentModel;
using System.Windows.Data;

namespace WpfApplication1
{
    class LDAP_Connector
    {
        private BackgroundWorker myLdapWindowSender;
        private DoWorkEventArgs myLdapWindowEventArg;
        private bool RunFromWindow;
        public string ldap_server;
        public string ldap_OU;
        public string ldap_username;
        public string ldap_password;

        public LDAP_Connector()
        {
            //LDAP_Retrieve_OU();
        }

        public void LDAP_Retrieve_OU(object sender, DoWorkEventArgs e, XmlDataProvider xdp)
        {
            if (sender != null)
            {
                myLdapWindowSender = sender as BackgroundWorker;
                myLdapWindowEventArg = e as DoWorkEventArgs;
                RunFromWindow = true;
            }
            else
            {
                RunFromWindow = false;
            }

            myLdapWindowSender.ReportProgress(5);

            List<string> alObjects = new List<string>();
            string cur_obj;

            try
            {
                DirectoryEntry directoryObject = new DirectoryEntry(ldap_server + ldap_OU, ldap_username, ldap_password);
                DirectorySearcher searcher = new DirectorySearcher(directoryObject);
                searcher.Filter = "(objectClass=computer)";

                myLdapWindowSender.ReportProgress(5);

                foreach (SearchResult result in searcher.FindAll())
                {
                    DirectoryEntry DirEntry = result.GetDirectoryEntry();
                    cur_obj = DirEntry.Name.ToString();
                    alObjects.Add(cur_obj.Replace("CN=", ""));
                }

                //foreach (DirectoryEntry child in directoryObject.Children)
                //{
                //    if (RunFromWindow)
                //    {
                //        myLdapWindowSender.ReportProgress(5);
                //    }
                //    string childPath = child.Path.ToString();
                //    alObjects.Add(childPath.Remove(0, 7));
                //    //remove the LDAP prefix from the path

                //    child.Close();
                //    child.Dispose();
                //}
                //directoryObject.Close();
                //directoryObject.Dispose();
                //string obj_attrs = directoryObject.Name.ToString();
                //string obj_name = obj_attrs.Replace("CN=", "");
                //MessageBox.Show("1 : " + obj_name);

                //foreach (string strAttrName in directoryObject.Properties.PropertyNames)
                //{
                //    alObjects.Add(strAttrName);
                //}
            }
            catch (DirectoryServicesCOMException f)
            {
                MessageBox.Show("An Error Occurred: " + f.Message.ToString());
            }

            string babar = string.Join<string>(", ", alObjects);

            //MessageBox.Show(babar);

            //AddMachine(string hostname, string vessel, string os, XmlDataProvider xmlResource)
            
            foreach (string cur_machine in alObjects)
            {
                DialogAddMachine.AddMachine(cur_machine, "SNIP", "Windows", xdp);
            }
        }
    }
}
