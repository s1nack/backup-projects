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
using System.Text;

namespace WpfApplication1
{
    class RemoteProcess
    {
        string RemoteMachine;
        string RemoteScript;
        private static StringBuilder sortOutput = new StringBuilder();
        private static int numOutputLines = 0;

        public RemoteProcess(string machine, string script)
        {
            RemoteMachine = machine;
            RemoteScript = script;
        }

        public string TrueExec()
        {
            Process myProcess = new Process();

            string result_output = null;
            ProcessStartInfo start = new ProcessStartInfo();
            
            start.RedirectStandardOutput = false;
            start.UseShellExecute = true;
            start.WindowStyle = ProcessWindowStyle.Normal;
            start.CreateNoWindow = false;

            start.FileName = "cmd.exe";
            string username = "";
            string password = "";
            string arg_path = "";
            start.Arguments = " /C psexec \\\\" + RemoteMachine + " -u " + username + " -p " + password + " ipconfig " + arg_path;

            myProcess.OutputDataReceived += new DataReceivedEventHandler(SortOutputHandler);
            myProcess = Process.Start(start);

            // Read the standard output of the spawned process.
            //result_output = myStreamReader.ReadToEnd();
            //Process process = Process.Start(start);
            //process.OutputDataReceived += new DataReceivedEventHandler(SortOutputHandler);
            //process.BeginOutputReadLine();
            //using (Process process = Process.Start(start))
            //{
                //using (StreamReader reader = process.StandardOutput)
                //{
                //    result_output = reader.ReadToEnd();
              //  }
            //}
            //result_output = process.StandardOutput.ReadToEnd();
            //process.WaitForExit();
            
            //result_output = process.StandardOutput.ReadToEnd();
            //process.Close();
            //result_output = sortOutput.ToString();
            myProcess.WaitForExit();
            myProcess.Close();
            return result_output;
        }

        private static void SortOutputHandler(object sendingProcess, DataReceivedEventArgs outLine)
        {
            if (!String.IsNullOrEmpty(outLine.Data))
            {
                numOutputLines++;
                sortOutput.Append(Environment.NewLine + "[" + numOutputLines.ToString() + "] - " + outLine.Data);
            }
        }
    }
}
