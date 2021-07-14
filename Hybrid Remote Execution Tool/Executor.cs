using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Windows;

namespace WpfApplication1
{
    class Executor
    {
        private int MaxThreadsRunning = 0;
        public int LeftToRun = 0;
        private List<string> list_Machines = new List<string>();
        private string ScriptToRun = null;
        private int CurrentRunningThreads = 0;
        private string logdate;
        private TextWriter logfile;
        private BackgroundWorker myExecutorWindowSender;
        private DoWorkEventArgs myExecutorWindowEventArg;
        private bool RunFromWindow;

        public Executor(int poolSize, int nbMachines, List<string> run_Machines, string run_Script)
        {
            MaxThreadsRunning = poolSize;
            LeftToRun = nbMachines;
            list_Machines = run_Machines;
            ScriptToRun = run_Script;
            logdate = GetTimestamp(DateTime.Now);
            logfile = new StreamWriter("RemoteExec-" + logdate + ".log");
        }

        private String GetTimestamp(DateTime value)
        {
            return value.ToString("yyyyMMddHHmm");
        }

        public void RunWhileRemainMachines(object sender, DoWorkEventArgs e)
        {
            if (sender != null)
            {
                myExecutorWindowSender = sender as BackgroundWorker;
                myExecutorWindowEventArg = e as DoWorkEventArgs;
                RunFromWindow = true;
            }
            else
            {
                RunFromWindow = false;
            }

            string[] options = new string[2];
            int i = 0;

            while (LeftToRun > 0)
            {
                if (CurrentRunningThreads < MaxThreadsRunning)
                {
                    if (RunFromWindow == true)
                    {
                        if (myExecutorWindowSender.CancellationPending == true)
                        {
                            MessageBox.Show("Task cancelled successfully");
                            myExecutorWindowEventArg.Cancel = true;
                            break;
                        }
                    }

                    BackgroundWorker myThread = new BackgroundWorker();
                    myThread.DoWork += new DoWorkEventHandler(backgroundWorkerRemoteProcess_DoWork);
                    myThread.RunWorkerCompleted += new RunWorkerCompletedEventHandler(backgroundWorkerRemoteProcess_RunWorkerCompleted);
                    myThread.ProgressChanged += new ProgressChangedEventHandler(backgroundWorkerRemoteProcess_ProgressChanged);
                    myThread.WorkerReportsProgress = true;
                    myThread.WorkerSupportsCancellation = true;
                    
                    myThread.RunWorkerAsync(new string[2] {list_Machines[i], ScriptToRun});

                    CurrentRunningThreads++;
                    i++;
                    LeftToRun--;      
                }
            }

            while (CurrentRunningThreads > 0) { }
            logfile.Close();
            //Task finished
        }

        private void backgroundWorkerRemoteProcess_DoWork(object sender, DoWorkEventArgs e)
        {
            BackgroundWorker myBackgroundWorker = sender as BackgroundWorker;
            string[] options = (string[])e.Argument;
            string machine = options[0];
            string script = options[1];
            
            if (RunFromWindow == true)
            {
                myBackgroundWorker.ReportProgress(1);
            }

            RemoteProcess myRemoteProcess = new RemoteProcess(machine, script);
            string output = myRemoteProcess.TrueExec();

            if (RunFromWindow == true)
            {
                myBackgroundWorker.ReportProgress(1);
            }

            if (output != null)
            {
                MessageBox.Show("Output : " + output);
                this.logfile.WriteLine(output);
            }
        }

        private void backgroundWorkerRemoteProcess_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            CurrentRunningThreads--;
        }

        private void backgroundWorkerRemoteProcess_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            myExecutorWindowSender.ReportProgress(1);
        }

    }
}
