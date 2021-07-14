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
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for TextEditorToolbar.xaml
    /// </summary>
    public partial class TextEditorToolbar : UserControl
    {
        public TextEditorToolbar()
        {
            InitializeComponent();
        }

        private void AddMachineToolbar_Click(object sender, RoutedEventArgs e)
        {
            DialogAddMachine mdlg = new DialogAddMachine();
            mdlg.ShowDialog();
        }

        private void AddLdapToolbar_Click(object sender, RoutedEventArgs e)
        {
            DialogAddLdap ldlg = new DialogAddLdap();
            ldlg.ShowDialog();
        }

        private void AddScriptToolbar_Click(object sender, RoutedEventArgs e)
        {
            DialogAddScript sdlg = new DialogAddScript();
            sdlg.ShowDialog();
        }

        private void OptionsToolbar_Click(object sender, RoutedEventArgs e)
        {
            DialogOptions odlg = new DialogOptions();
            odlg.ShowDialog();
        }
    }
}
