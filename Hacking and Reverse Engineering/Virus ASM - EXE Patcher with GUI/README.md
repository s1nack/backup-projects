# ASM PE Files Patcher

An x86 Assembly Windows virus creation tool, with GUI

![screenshot virus](https://raw.githubusercontent.com/s1nack/backup-projects/main/Hacking%20and%20Reverse%20Engineering/Virus%20ASM%20-%20EXE%20Patcher%20with%20GUI/Patcher%20virus.PNG)

This patcher uses [RadASM](https://github.com/mrfearless/RadASM2) to provide a basic GUI.

It adds a hidden section in a PE file and lets you decide of the payload to be executed (PE Entrypoint is modified). It provides the basic tools needed for the payload to locate itself in OS memory and find the most common Windows DLLs (e.g., Kernel32) out of the blue (Delta routine).


