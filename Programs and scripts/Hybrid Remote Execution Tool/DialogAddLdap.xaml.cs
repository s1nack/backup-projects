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
using System.Diagnostics;
using System.Threading;
using System.ComponentModel;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for DialogAddLdap.xaml
    /// </summary>
    public partial class DialogAddLdap : Window
    {
        BackgroundWorker ldapBackground = new BackgroundWorker();
        LDAP_Connector myLdapConnector;
        string LdapServer;
        string LdapOU;
        string LdapUsername;
        string LdapPassword;

        public DialogAddLdap()
        {
            InitializeComponent();
        }

        private void DialogAddLdapOKButton_Click(object sender, RoutedEventArgs e)
        {
            // RETRIEVE LDAP VALUES
            LdapServer = "LDAP://" + LdapServerTextBox.Text + "/";
            LdapOU = LdapOUTextBox.Text;
            LdapUsername = LdapUsernameTextBox.Text;
            LdapPassword = LdapPasswordTextBox.Text;
            // CREATE BACKGROUNDWORKER FOR LDAP_Connector
            ldapBackground.DoWork += new DoWorkEventHandler(ldapBackground_DoWork);
            ldapBackground.RunWorkerCompleted += new RunWorkerCompletedEventHandler(ldapBackground_RunWorkerCompleted);
            ldapBackground.ProgressChanged += new ProgressChangedEventHandler(ldapBackground_ProgressChanged);
            ldapBackground.WorkerReportsProgress = true;
            ldapBackground.WorkerSupportsCancellation = true;
            // RUN BACKGROUNDWORKER
            ldapBackground.RunWorkerAsync();
        }

        private void ldapBackground_DoWork(object sender, DoWorkEventArgs e)
        {
            myLdapConnector = new LDAP_Connector();
            myLdapConnector.ldap_server = LdapServer;
            myLdapConnector.ldap_OU = LdapOU;
            myLdapConnector.ldap_username = LdapUsername;
            myLdapConnector.ldap_password = LdapPassword;
            myLdapConnector.LDAP_Retrieve_OU(sender, e, MainWindow.xdp_hosts);
        }

        private void ldapBackground_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            LdapProgressBar.Value = 100;
            MessageBox.Show("DialogAddLdap ldapBackground complete");
            this.DialogResult = true;
        }

        private void ldapBackground_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            LdapProgressBar.Value = e.ProgressPercentage;
        }

        private void DialogAddLdapCANCELButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }
    }
}
