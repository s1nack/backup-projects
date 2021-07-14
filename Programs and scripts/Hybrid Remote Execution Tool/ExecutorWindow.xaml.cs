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
    /// Interaction logic for ExecutorWindow.xaml
    /// </summary>
    public partial class ExecutorWindow : Window
    {
        BackgroundWorker execBackground = new BackgroundWorker();
        Executor myExecutor;

        public ExecutorWindow()
        {
            InitializeComponent();
            ExecutorProgressBar.Minimum = 0;
            ExecutorProgressBar.Maximum = MainWindow.nbMachines * 2;
            ExecutorProgressBar.Value = 0;
            RunExecutorWithWindow();
        }

        public void RunExecutorWithWindow()
        {
            // CREATE BACKGROUNDWORKER FOR EXECUTOR
            execBackground.DoWork += new DoWorkEventHandler(execBackground_DoWork);
            execBackground.RunWorkerCompleted += new RunWorkerCompletedEventHandler(execBackground_RunWorkerCompleted);
            execBackground.ProgressChanged += new ProgressChangedEventHandler(execBackground_ProgressChanged);
            execBackground.WorkerReportsProgress = true;
            execBackground.WorkerSupportsCancellation = true;
            // RUN BACKGROUNDWORKER
            execBackground.RunWorkerAsync();
        }

        private void execBackground_DoWork(object sender, DoWorkEventArgs e)
        {
            myExecutor = new Executor(MainWindow.poolSize, MainWindow.nbMachines, MainWindow.selectedMachines_List, MainWindow.exec_Script);
            myExecutor.RunWhileRemainMachines(sender, e);
        }

        private void execBackground_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            //MessageBox.Show("RunWorkerCompleted execBackground");
        }

        private void execBackground_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            ExecutorProgressBar.Value += 1;
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            this.execBackground.CancelAsync();

            button1.IsEnabled = false;
        }
    }
}
