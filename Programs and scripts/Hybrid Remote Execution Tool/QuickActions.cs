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
    class QuickActions
    {
        BackgroundWorker execBackground = new BackgroundWorker();
        Executor myExecutor;

        public QuickActions()
        {

        }

        public void RunExecutorFromQA()
        {
            execBackground.DoWork += new DoWorkEventHandler(execBackground_DoWork);
            execBackground.RunWorkerCompleted += new RunWorkerCompletedEventHandler(execBackground_RunWorkerCompleted);
            //execBackground.WorkerReportsProgress = true;
            execBackground.WorkerSupportsCancellation = true;
            execBackground.RunWorkerAsync();
        }

        private void execBackground_DoWork(object sender, DoWorkEventArgs e)
        {
            myExecutor = new Executor(MainWindow.poolSize, MainWindow.nbMachines, MainWindow.selectedMachines_List, MainWindow.exec_Script);
            myExecutor.RunWhileRemainMachines(null, null);
        }

        private void execBackground_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {

        }
    }
}
