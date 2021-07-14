using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using System.Threading;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;

namespace WpfApplication1
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>

    public partial class App : Application
    {
        //public static BackgroundWorker[] executorsArray = new BackgroundWorker[10];
        //public static int currentExecutor = 0;
    }



    //public class RemoteProcess
    //{
    //    string RemoteMachine;
    //    string RemoteScript;
        
    //    public RemoteProcess(string machine, string script)
    //    {
    //        RemoteMachine = machine;
    //        RemoteScript = script;
    //    }

    //    public int FalseExec()
    //    {
    //        MessageBox.Show("Psexec \\\\" + RemoteMachine + " -c " + RemoteScript);
    //        return 0;
    //    }

    //    public int TrueExec()
    //    {
    //        ProcessStartInfo start = new ProcessStartInfo();
    //        start.FileName = "ping.exe";
    //        start.RedirectStandardOutput = true;
    //        start.UseShellExecute = false;
    //        start.WindowStyle = ProcessWindowStyle.Hidden;
    //        start.CreateNoWindow = true;
    //        //start.Arguments = "\\\\" + RemoteMachine + " -c " + RemoteScript + " -f";
    //        start.Arguments = RemoteMachine;

    //        using (Process process = Process.Start(start))
    //        {
    //            using (StreamReader reader = process.StandardOutput)
    //            {
    //                string result_output = reader.ReadToEnd();
    //            }
    //        }
    //        return 0;
    //    }
    //}


    //public class Executor
    //{
    //    private int nbCurrentRunning = 0;
    //    private static int nbToExec;
    //    private int j = 0;
    //    private static int maxThreads;
    //    private List<string> exec_Machines = new List<string>();
    //    private string exec_Script;
    //    private BackgroundWorker[] threadArray;
    //    private RemoteProcess[] RemoteArray;
    //    private static List<string> output_machines_list = new List<string>();

    //    public Executor(int poolSize, int nbMachines, List<string> run_Machines, string run_Script)
    //    {
    //        maxThreads = poolSize;
    //        nbToExec = nbMachines;
    //        exec_Script = run_Script;
    //        exec_Machines = run_Machines;
    //        threadArray = new BackgroundWorker[maxThreads];
    //        RemoteArray = new RemoteProcess[nbToExec];

    //        // PREPARE A THREAD FOR EACH REMOTE EXECUTION
    //        InitializeBackgoundWorkers();

    //        // RUN [maxThreads] THREADS
    //        RunFirstPool();
    //    }

    //    private void InitializeBackgoundWorkers()
    //    {
    //        for (int f = 0; f < maxThreads; f++)
    //        {
    //            threadArray[f] = new BackgroundWorker();
    //            threadArray[f].DoWork += new DoWorkEventHandler(backgroundWorkerFiles_DoWork);
    //            threadArray[f].RunWorkerCompleted += new RunWorkerCompletedEventHandler(backgroundWorkerFiles_RunWorkerCompleted);
    //            threadArray[f].ProgressChanged += new ProgressChangedEventHandler(backgroundWorkerFiles_ProgressChanged);
    //            threadArray[f].WorkerReportsProgress = true;
    //            threadArray[f].WorkerSupportsCancellation = true;
    //        }
    //    }

    //    public void RunFirstPool()
    //    {
    //        while (nbCurrentRunning < maxThreads)
    //        {
    //            if (nbToExec > 0)
    //            {
    //                // RUN A THREAD 
    //                threadArray[nbCurrentRunning].RunWorkerAsync();

    //                // ADJUST COUNTERS
    //                nbCurrentRunning++;
    //                nbToExec--;
    //            }
    //        }
    //    }

    //    private int RunOneMore()
    //    {
    //        //event handler fin process
    //        //nbCurrentRunning--
    //        //nbDone++;
    //        //if nbToExec > 0
    //        // machine[i].run
    //        // nbToExec--
    //        // nbCurrentRunning++
    //        // i++
    //        return 0;
    //    }

    //    private void backgroundWorkerFiles_DoWork(object sender, DoWorkEventArgs e)
    //    {
    //        // CREATE RemoteProcess INSTANCE IN THE CURRENT THREAD
    //        RemoteArray[j] = new RemoteProcess(exec_Machines[j], exec_Script);

    //        // RUN RemoteProcess EXECUTION
    //        //e.Result = RemoteArray[j].FalseExec();
    //        string temp = RemoteArray[j].TrueExec();
    //        output_machines_list.Add(temp);

    //        // INCREMENT RemoteProcess ARRAY INDEX
    //        j++;
    //    }

    //    private void backgroundWorkerFiles_ProgressChanged(object sender, ProgressChangedEventArgs e)
    //    {
    //        // REPORT PROGRESS TO GUI
    //    }

    //    private void backgroundWorkerFiles_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
    //    {
    //        if (e.Error != null)
    //        {
    //            MessageBox.Show(e.Error.Message);
    //        }

    //        if (nbCurrentRunning == 0)
    //        {
    //            var output = string.Join(String.Empty, output_machines_list);
    //            MessageBox.Show(output);
    //        }

    //        nbCurrentRunning--;
    //    }
    //}
}
