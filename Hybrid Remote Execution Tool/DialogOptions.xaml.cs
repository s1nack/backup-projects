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

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for Options.xaml
    /// </summary>
    public partial class DialogOptions : Window
    {
        public DialogOptions()
        {
            InitializeComponent();
        }

        private void OptionsSAVEButton_Click(object sender, RoutedEventArgs e)
        {
            MainWindow.poolSize = Convert.ToInt32(OptionsMaxPoolSize.Text);
            this.DialogResult = true;
        }

        private void OptionsCANCELButton_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = false;
        }
    }
}
