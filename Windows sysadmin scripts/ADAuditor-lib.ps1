function GUI_DisplayMainForm($mainForm) { 
    $mainForm.TopMost = $true
    $mainForm.Width = 700
    $mainForm.Height = 700
    $mainForm.MainMenuStrip = $menuMain
    $mainForm.StartPosition = "CenterScreen"
    $mainForm.Text = "Active Directory Audit Toolkit"
    $mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;
    $mainForm.MaximizeBox = $false;
    $mainForm.Controls.Add($menuMain)
}

function GetUsersGroupsMatrix() {
    
}
