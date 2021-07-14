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
    /// Interaction logic for TextEditorMenu.xaml
    /// </summary>
    public partial class TextEditorMenu : UserControl
    {
        public TextEditorMenu()
        {
            InitializeComponent();
        }

        private void ButtonMenuAddMachine_click(object sender, RoutedEventArgs e)
        {
            DialogAddMachine mdlg = new DialogAddMachine();
            mdlg.ShowDialog();
        }

        private void ButtonMenuAddScript_click(object sender, RoutedEventArgs e)
        {
            DialogAddScript sdlg = new DialogAddScript();
            sdlg.ShowDialog();
        }

        private void ButtonMenuExit_click(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }

        private void ButtonMenuOptions_click(object sender, RoutedEventArgs e)
        {
            DialogOptions odlg = new DialogOptions();
            odlg.ShowDialog();
        }

        private void ButtonMenuAbout_Click(object sender, RoutedEventArgs e)
        {
        MessageBox.Show(
        "RemEx(c). " + Environment.NewLine + "Author : Marc Impini" + Environment.NewLine + "Version : beta 1",
        "About"
        );
        }
    }
}
