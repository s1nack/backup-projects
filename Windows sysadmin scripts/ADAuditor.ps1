# Import modules
#Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -Assembly System.Drawing

[Windows.Forms.Application]::EnableVisualStyles()

$RunDir = Split-Path $MyInvocation.MyCommand.Definition
. "$RunDir/ADAuditor-lib.ps1"

$users_list = @()
$users = @{}
$user_matrix = @{}
$props = [ordered]@{}
$domains = @("redacted.PRIV", "GVA.redacted.PRIV", "EXT")
$domain_servers = "redacteddc04.redacted.priv"
$Static_domain = "redacted.PRIV"
$OU = "DC=redacted,DC=PRIV"

#########################################################################
## Get DC from domain
#########################################################################

# Function returns server (DC) from domain


#########################################################################
## Retrieve list of groups from domain
#########################################################################

# $DomainGroups = @() = GetGroupsFromDomains($domain)
$sensitive_groups = @( `
	"Enterprise Admins", `
	"Domain Admins", `
	"Administrators", `
	"Schema Admins", `
	"redacted-ADM-Password Policy High", `
	"redacted-ADM-Domain Admins Write Member", `
	"redacted-ADM-Servers HQ Admin", `
	"redacted-ADA-Users HQ Admin Mgmt" `
)

$domain_groups = @( `
    "Remote users", `
    "ERP users", `
    "Enterprise Admins", `
	"Domain Admins", `
	"Administrators", `
	"Schema Admins", `
	"redacted-ADM-Password Policy High", `
	"redacted-ADM-Domain Admins Write Member", `
	"redacted-ADM-Servers HQ Admin", `
	"redacted-ADA-Users HQ Admin Mgmt", `
    "Test application", `
    "Remote users", `
    "ERP users", `
    "Enterprise Admins", `
	"Domain Admins", `
	"Administrators", `
	"Schema Admins", `
    "Remote users", `
    "ERP users", `
    "Enterprise Admins", `
	"Domain Admins", `
	"Administrators", `
	"Schema Admins", `
    "Export" `
)

#########################################################################
## Retrieve list of users properties
#########################################################################

$ADUsersProperties = @( `
    ”AccountExpirationDate”, `
    ”AccountLockoutTime”, `
    ”AccountNotDelegated”, `
    ”AllowReversiblePasswordEncryption”, `
    ”BadLogonCount”, `
    ”CannotChangePassword”, `
    ”CanonicalName”, `
    ”Certificates”, `
    ”ChangePasswordAtLogon”, `
    ”City”, `
    ”CN”, `
    ”Company”, `
    ”Country”, `
    ”Created”, `
    ”Deleted”, `
    ”Department”, `
    ”Description”, `
    ”DisplayName”, `
    ”DistinguishedName”, `
    ”Division”, `
    ”DoesNotRequirePreAuth”, `
    ”EmailAddress”, `
    ”EmployeeID”, `
    ”EmployeeNumber”, `
    ”Enabled”, `
    ”Fax”, `
    ”GivenName”, `
    ”HomeDirectory”, `
    ”HomedirRequired”, `
    ”HomeDrive”, `
    ”HomePage”, `
    ”HomePhone”, `
    ”Initials”, `
    ”LastBadPasswordAttempt”, `
    ”LastKnownParent”, `
    ”LastLogonDate”, `
    ”LockedOut”, `
    ”LogonWorkstations”, `
    ”Manager”, `
    ”MemberOf”, `
    ”MNSLogonAccount”, `
    ”MobilePhone”, `
    ”Modified”, `
    ”Name”, `
    ”ObjectCategory”, `
    ”ObjectClass”, `
    ”ObjectGUID”, `
    ”Office”, `
    ”OfficePhone”, `
    ”Organization”, `
    ”OtherName”, `
    ”PasswordExpired”, `
    ”PasswordLastSet”, `
    ”PasswordNeverExpires”, `
    ”PasswordNotRequired”, `
    ”POBox”, `
    ”PostalCode”, `
    ”PrimaryGroup”, `
    ”ProfilePath”, `
    ”ProtectedFromAccidentalDeletion”, `
    ”SamAccountName”, `
    ”ScriptPath”, `
    ”ServicePrincipalNames”, `
    ”SID”, `
    ”SIDHistory”, `
    ”SmartcardLogonRequired”, `
    ”State”, `
    ”StreetAddress”, `
    ”Surname”, `
    ”Title”, `
    ”TrustedForDelegation”, `
    ”TrustedToAuthForDelegation”, `
    ”UseDESKeyOnly”, `
    ”UserPrincipalName”`
)

$ADUsersSecurityProperties = @( `
    ”AccountExpirationDate”, `
    ”AccountLockoutTime”, `
    ”AccountNotDelegated”, `
    ”AllowReversiblePasswordEncryption”, `
    ”BadLogonCount”, `
    ”CannotChangePassword”, `
    ”ChangePasswordAtLogon”, `
    ”Created”, `
    ”Deleted”, `
    ”LastBadPasswordAttempt”, `
    ”LastLogonDate”, `
    ”LockedOut”, `
    ”LogonWorkstations”, `
    ”Modified”, `
    ”PasswordExpired”, `
    ”PasswordLastSet”, `
    ”PasswordNeverExpires”, `
    ”PasswordNotRequired”, `
    ”ProtectedFromAccidentalDeletion”, `
    ”SamAccountName”, `
    ”SmartcardLogonRequired”, `
    ”TrustedForDelegation”, `
    ”TrustedToAuthForDelegation”, `
    ”UseDESKeyOnly” `
)

#########################################################################
## Get list of users for each group under review
#########################################################################
## Output for this function is a hashtable of arrays with username as key
## i.e. user_matrix["my_username"]
## Values are:
## [0] = (array) [x,0,x,...,n] with array index = index of groups array
##    n = number of groups
##    x = user is a member of n (positive flag)
##    0 = user not a member of n (negative flag)
## [1] = (string) additional parameters retrieved for user (e.g. password infos)
#########################################################################

$users_groups_matrix = GetUsersGroupsMatrix($sensitive_groups, $domain_servers)
<#
For ($i=0; $i -lt $sensitive_groups.Count; $i++) {
	$cur_group_users = get-adgroupmember -server $domain_servers $sensitive_groups[$i] -recursive | select -ExpandProperty distinguishedName
	ForEach ($u in $cur_group_users) {
		if (! $user_matrix.containsKey($u)) {
			$user_matrix[$u] = @{}
			$user_matrix[$u][0] = @("") * $sensitive_groups.Count
		}
		$user_matrix[$u][0][$i] = "x"
	}
}
#>

#########################################################################
## Create custom Powershell objects from list of users (required for Excel dump)
#########################################################################

<#
$data = $user_matrix.GetEnumerator() | 
	foreach {
		$props["User"] = $($_.key)
		for ($i=0; $i -lt $sensitive_groups.Count; $i++) { 
			$current_group = $sensitive_groups[$i]
			$props["$current_group"] = $($_.value[0][$i])
		}
		New-Object Psobject -Property $props 
	} 
#>

#########################################################################
## Initialize Excel report parameters
#########################################################################

<#
$RandomStyle = {
    param(
        $workSheet,
        $totalRows,
        $lastColumn
    )    
    
    $nbCols = [convert]::ToInt32($worksheet.Dimension.End.Column, 10)
    $workSheet.Cells["A:$lastColumn"].Style.Font.Size = 9
    $topCellLastColumn = "$lastColumn" + 1
    $workSheet.Cells["B1:$topCellLastColumn"].Style.TextRotation = 45

    for($i=2;$i -lt $nbCols+1; $i++) {
        $worksheet.Column($i).Width = 3    
    }
}

$p=@{
    WorkSheetname = "AD Access Review"
	FreezeTopRow = $true
	BoldTopRow = $true
	AutoFilter = $true
    Show = $true
    AutoSize = $true
    CellStyleSB = $RandomStyle
}
#>

#########################################################################
## Generate Excel report
#########################################################################

#$file = ".\test.xlsx"
#rm $file -ErrorAction Ignore
#$data | Export-Excel $file @p

#########################################################################
## GUI
#########################################################################

$menuMain         = New-Object System.Windows.Forms.MenuStrip
$menuFile         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuView         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuTools        = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOpen         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSave         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSaveAs       = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFullScr      = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions      = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions1     = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions2     = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout        = New-Object System.Windows.Forms.ToolStripMenuItem
$mainToolStrip    = New-Object System.Windows.Forms.ToolStrip
$toolStripOpen    = New-Object System.Windows.Forms.ToolStripButton
$toolStripSave    = New-Object System.Windows.Forms.ToolStripButton
$toolStripSaveAs  = New-Object System.Windows.Forms.ToolStripButton
$toolStripFullScr = New-Object System.Windows.Forms.ToolStripButton
$toolStripAbout   = New-Object System.Windows.Forms.ToolStripButton
$toolStripExit    = New-Object System.Windows.Forms.ToolStripButton
$statusStrip      = New-Object System.Windows.Forms.StatusStrip
$statusLabel      = New-Object System.Windows.Forms.ToolStripStatusLabel

$baseHeight = 20
$baseWidth = 25

$mainForm = New-Object system.Windows.Forms.Form
GUI_DisplayMainForm($mainForm)

# Main ToolStrip
#[void]$mainForm.Controls.Add($mainToolStrip)
 
# Main Menu Bar
[void]$mainForm.Controls.Add($menuMain)
 
# Menu Options
$menuFile.Text = "File"
[void]$menuMain.Items.Add($menuFile)
$menuView.Text = "View"
[void]$menuMain.Items.Add($menuView)
$menuTools.Text = "Tools"
[void]$menuMain.Items.Add($menuTools)
$menuHelp.Text = "Help"
[void]$menuMain.Items.Add($menuHelp)

#########################################################################
## SCOPE CONTROLS
#########################################################################

#################################
## HEADER 
#################################



#################################
## DOMAIN 
#################################
$domainBaseWidth = [convert]::ToInt32($baseWidth+0,10)
$domainBaseHeight = [convert]::ToInt32($baseHeight+30,10)

$DomainsLabel = New-Object system.windows.Forms.Label
$DomainsLabel.Text = "Scope"
$DomainsLabel.AutoSize = $true
$DomainsLabel.Width = 25
$DomainsLabel.Height = 10
$DomainsLabel.location = new-object system.drawing.point($domainBaseWidth,$domainBaseHeight)
$DomainsLabel.Font = "Segoe UI,9,style=Bold"
$mainForm.controls.Add($DomainsLabel)

$DomainsLabel2 = New-Object system.windows.Forms.Label
$DomainsLabel2.Text = "Domain :"
$DomainsLabel2.AutoSize = $true
$DomainsLabel2.location = new-object system.drawing.point($domainBaseWidth,[convert]::ToInt32($domainBaseHeight+25,10))
$DomainsLabel2.Font = "Segoe UI,8"
$mainForm.controls.Add($DomainsLabel2)

$DomainsComboBox = New-Object system.windows.Forms.ComboBox
$DomainsComboBox.Width = 200
$DomainsComboBox.Height = 20
$DomainsComboBox.location = new-object system.drawing.point([convert]::ToInt32($domainBaseWidth+70,10),[convert]::ToInt32($domainBaseHeight+22,10))
$DomainsComboBox.Font = "Segoe UI,9"
$mainForm.Controls.Add($DomainsComboBox)
foreach($domain in $domains) { $DomainsComboBox.Items.add($domain) | Out-Null }

$DomainsLabel2 = New-Object system.windows.Forms.Label
$DomainsLabel2.Text = "OU :"
$DomainsLabel2.AutoSize = $true
$DomainsLabel2.location = new-object system.drawing.point($domainBaseWidth,[convert]::ToInt32($domainBaseHeight+60,10))
$DomainsLabel2.Font = "Segoe UI,8"
$mainForm.controls.Add($DomainsLabel2)

$DomainsComboBox = New-Object system.windows.Forms.ComboBox
$DomainsComboBox.Width = 200
$DomainsComboBox.Height = 20
$DomainsComboBox.location = new-object system.drawing.point([convert]::ToInt32($domainBaseWidth+70,10),[convert]::ToInt32($domainBaseHeight+55,10))
$DomainsComboBox.Font = "Segoe UI,9"
foreach($domain in $domains) { $DomainsComboBox.Items.add($domain) | Out-Null }
$mainForm.Controls.Add($DomainsComboBox)

#################################
## OU 
#################################

#########################################################################
## GROUPS CONTROLS
#########################################################################
$GroupsBaseWidth = $domainBaseWidth
$GroupsBaseHeight = [convert]::ToInt32($domainBaseHeight+100,10)

$GroupsLine = New-Object system.windows.Forms.Label
$GroupsLine.Text = ""
$GroupsLine.Height = 2
$GroupsLine.Width = $mainForm.Width
$GroupsLine.BorderStyle = "Fixed3D"
$GroupsLine.AutoSize = $false
$GroupsLine.location = new-object system.drawing.point(0,[convert]::ToInt32($GroupsBaseHeight,10))
$GroupsLine.Font = "Segoe UI,9,style=Bold"
$mainForm.controls.Add($GroupsLine)

$GroupsLabel = New-Object system.windows.Forms.Label
$GroupsLabel.Text = "Groups"
$GroupsLabel.AutoSize = $true
$GroupsLabel.Width = 25
$GroupsLabel.Height = 10
$GroupsLabel.location = new-object system.drawing.point($GroupsBaseWidth,[convert]::ToInt32($GroupsBaseHeight+15,10))
$GroupsLabel.Font = "Segoe UI,9,style=Bold"
$mainForm.controls.Add($GroupsLabel)

$GroupsLabel2 = New-Object system.windows.Forms.Label
$GroupsLabel2.Text = "Select groups to audit :"
$GroupsLabel2.AutoSize = $true
$GroupsLabel2.location = new-object system.drawing.point($GroupsBaseWidth,[convert]::ToInt32($GroupsBaseHeight+40,10))
$GroupsLabel2.Font = "Segoe UI,8"
$mainForm.controls.Add($GroupsLabel2)

$RefreshGroupsButton = New-Object system.windows.Forms.Button
$RefreshGroupsButton.Width = 20
$RefreshGroupsButton.Height = 20
$RefreshGroupsButton.AutoSize = $true
$RefreshGroupsButton.location = new-object system.drawing.point([convert]::ToInt32($domainBaseWidth+250,10),[convert]::ToInt32($GroupsBaseHeight+33,10))
$RefreshImage = [System.Drawing.Image]::FromFile("E:\Work\Powershell\reload-blue-mini.png")
$RefreshGroupsButton.Image = $RefreshImage
$RefreshGroupsButton.BackColor = [System.Drawing.Color]::Transparent
$RefreshGroupsButton.FlatStyle = [System.Windows.Forms.Flatstyle]::Flat
$RefreshGroupsButton.FlatAppearance.BorderSize = 0;
$RefreshGroupsButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::LightBlue
$RefreshGroupsButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::Transparent
$RefreshGroupsButton.ForeColor = [System.Drawing.Color]::White
$mainForm.controls.Add($RefreshGroupsButton)
$RefreshGroupsButton.Add_Click({ [Windows.Forms.MessageBox]::Show("Refresh AD groups", "AD Groups", [Windows.Forms.MessageBoxButtons]::OK) })

$GroupsSelectAll = New-Object system.windows.Forms.Label
$GroupsSelectAll.Text = "Select All  | "
$GroupsSelectAll.AutoSize = $true
$GroupsSelectAll.ForeColor = "#1c47d9"
$GroupsSelectAll.location = new-object system.drawing.point([convert]::ToInt32($GroupsBaseWidth+175,10),[convert]::ToInt32($GroupsBaseHeight+385,10))
$GroupsSelectAll.Font = "Segoe UI,8"
$mainForm.controls.Add($GroupsSelectAll)
$GroupsSelectAll.Add_Click({ for ($i=0; $i -lt $GroupsCheckedListBox.Items.Count; $i++) { $GroupsCheckedListBox.SetItemChecked($i, "true") } })


$GroupsSelectNone = New-Object system.windows.Forms.Label
$GroupsSelectNone.Text = "None"
$GroupsSelectNone.AutoSize = $true
$GroupsSelectNone.ForeColor = "#1c47d9"
$GroupsSelectNone.location = new-object system.drawing.point([convert]::ToInt32($GroupsBaseWidth+240,10),[convert]::ToInt32($GroupsBaseHeight+385,10))
$GroupsSelectNone.Font = "Segoe UI,8"
$mainForm.controls.Add($GroupsSelectNone)
$GroupsSelectNone.Add_Click({ for ($i=0; $i -lt $GroupsCheckedListBox.Items.Count; $i++) { $GroupsCheckedListBox.SetItemCheckState($i, 0) } })


function InitializeFeatureList([REF]$GroupsCheckedListBox)
{
    if ($GroupsCheckedListBox -ne $null) {
        foreach($domain_group in $domain_groups) {
            $GroupsCheckedListBox.Value.Items.Add("$domain_group") | Out-Null;
        }
    }
}

$GroupsCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox;
$GroupsCheckedListBox.Width = 275;
$GroupsCheckedListBox.Height = 325;
$GroupsCheckedListBox.location = new-object system.drawing.point($GroupsBaseWidth,[convert]::ToInt32($GroupsBaseHeight+60,10))
$GroupsCheckedListBox.CheckOnClick = $true
InitializeFeatureList ([REF]$GroupsCheckedListBox)
$mainForm.Controls.Add($GroupsCheckedListBox);
$GroupsCheckedListBox.ClearSelected();

$SensitiveGroupsCheckbox = New-Object system.windows.Forms.CheckBox
$SensitiveGroupsCheckbox.Text = "Select sensitive groups"
$SensitiveGroupsCheckbox.AutoSize = $true
$SensitiveGroupsCheckbox.Width = 95
$SensitiveGroupsCheckbox.Height = 20
$SensitiveGroupsCheckbox.location = new-object system.drawing.point($GroupsBaseWidth,[convert]::ToInt32($GroupsBaseHeight+381,10))
$SensitiveGroupsCheckbox.Font = "Segoe UI,9"
$mainForm.controls.Add($SensitiveGroupsCheckbox)

#########################################################################
## USERS CONTROLS
#########################################################################
$UsersBaseWidth = [convert]::ToInt32($baseWidth+350,10)
$UsersBaseHeight = [convert]::ToInt32($domainBaseHeight+100,10)

$UsersLabel = New-Object system.windows.Forms.Label
$UsersLabel.Text = "Users"
$UsersLabel.AutoSize = $true
$UsersLabel.location = new-object system.drawing.point($UsersBaseWidth,[convert]::ToInt32($UsersBaseHeight+15))
$UsersLabel.Font = "Segoe UI,9,style=Bold"
$mainForm.controls.Add($UsersLabel)

$UsersLabel2 = New-Object system.windows.Forms.Label
$UsersLabel2.Text = "Select properties to extract for each user :"
$UsersLabel2.AutoSize = $true
$UsersLabel2.location = new-object system.drawing.point($UsersBaseWidth,[convert]::ToInt32($UsersBaseHeight+40,10))
$UsersLabel2.Font = "Segoe UI,8"
$mainForm.controls.Add($UsersLabel2)

$UsersSelectAll = New-Object system.windows.Forms.Label
$UsersSelectAll.Text = "Select All  | "
$UsersSelectAll.AutoSize = $true
$UsersSelectAll.ForeColor = "#1c47d9"
$UsersSelectAll.location = new-object system.drawing.point([convert]::ToInt32($UsersBaseWidth+175,10),[convert]::ToInt32($UsersBaseHeight+385,10))
$UsersSelectAll.Font = "Segoe UI,8"
$UsersSelectAll.Add_Click({
    for ($i=0; $i -lt $UsersCheckedListBox.Items.Count; $i++)
    {
        $UsersCheckedListBox.SetItemChecked($i, "true")
    }
})
$mainForm.controls.Add($UsersSelectAll)

$UsersSelectNone = New-Object system.windows.Forms.Label
$UsersSelectNone.Text = "None"
$UsersSelectNone.AutoSize = $true
$UsersSelectNone.ForeColor = "#1c47d9"
$UsersSelectNone.location = new-object system.drawing.point([convert]::ToInt32($UsersBaseWidth+240,10),[convert]::ToInt32($UsersBaseHeight+385,10))
$UsersSelectNone.Font = "Segoe UI,8"
$UsersSelectNone.Add_Click({
    for ($i=0; $i -lt $UsersCheckedListBox.Items.Count; $i++) {
        $UsersCheckedListBox.SetItemCheckState($i, 0)
    }
})
$mainForm.controls.Add($UsersSelectNone)

function InitializeFeatureList([REF]$UsersCheckedListBox) {
    if ($UsersCheckedListBox -ne $null) {
        foreach($ADUsersProperty in $ADUsersProperties) {
            $UsersCheckedListBox.Value.Items.Add("$ADUsersProperty") | Out-Null;
        }
    }
}

$UsersCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox;
$UsersCheckedListBox.Width = 275;
$UsersCheckedListBox.Height = 325;
$UsersCheckedListBox.location = new-object system.drawing.point($UsersBaseWidth,[convert]::ToInt32($UsersBaseHeight+60,10))
$UsersCheckedListBox.CheckOnClick = $true
InitializeFeatureList ([REF]$UsersCheckedListBox)
$mainForm.Controls.Add($UsersCheckedListBox);
$UsersCheckedListBox.ClearSelected();

$UserPasswordcheckBox = New-Object system.windows.Forms.CheckBox
$UserPasswordcheckBox.Text = "Select password properties"
$UserPasswordcheckBox.AutoSize = $true
$UserPasswordcheckBox.location = new-object system.drawing.point($UsersBaseWidth,[convert]::ToInt32($UsersBaseHeight+381,10))
$UserPasswordcheckBox.Font = "Segoe UI,9"
$mainForm.controls.Add($UserPasswordcheckBox)
$UserPasswordcheckBox.Add_CheckStateChanged({
    if ($UserPasswordcheckBox.Checked -eq $true) {
            #for ($i=0; $i -lt $UsersCheckedListBox.Items.Count; $i++) {
                #foreach ($UsersCheckedListBox as $User)
                    #$UsersCheckedListBox.SetItemChecked($i, "true")
                    #$UsersCheckedListBox.
            #}
    }
    #add here code triggered by the event
    $ADUsersSecurityProperties
})

#########################################################################
## ACTION CONTROLS
#########################################################################
$ActionsBaseWidth = 0
$ActionsBaseHeight = [convert]::ToInt32($GroupsBaseWidth+580,10)

$ActionBarLine = New-Object system.windows.Forms.Label
$ActionBarLine.Text = ""
$ActionBarLine.Height = 2
$ActionBarLine.Width = $mainForm.Width
$ActionBarLine.BorderStyle = "Fixed3D"
$ActionBarLine.AutoSize = $false
$ActionBarLine.location = new-object system.drawing.point($ActionsBaseWidth,$ActionsBaseHeight)
$ActionBarLine.Font = "Segoe UI,9,style=Bold"
$mainForm.controls.Add($ActionBarLine)

function AcceptFeatures($GroupsCheckedListBox, $UsersCheckedListBox)
{
    if(($GroupsCheckedListBox -eq $null) -or ($GroupsCheckedListBox.CheckedItems.Count -eq 0) -or ($UsersCheckedListBox -eq $null) -or ($UsersCheckedListBox.CheckedItems.Count -eq 0))
    {
        [Windows.Forms.MessageBox]::Show("You must select at least one group and one user property.", "Selection error", [Windows.Forms.MessageBoxButtons]::OK)
    }
    else
    {
        $groupsCount = $GroupsCheckedListBox.CheckedItems.Count
        $usersCount = $UsersCheckedListBox.CheckedItems.Count
        [Windows.Forms.MessageBox]::Show("$groupsCount groups and $usersCount users", "OK", [Windows.Forms.MessageBoxButtons]::OK)
    }
}

$ReportButton = New-Object system.windows.Forms.Button
#$ReportButton.AutoSize = $true
$ReportButton.Width = 80
$ReportButton.Height = 30
$ReportButton.Text = "Report"
$ReportButton.location = new-object system.drawing.point([convert]::ToInt32($mainForm.Width-110,10),[convert]::ToInt32($ActionsBaseHeight+20,10))
$ReportButton.add_Click({AcceptFeatures ($GroupsCheckedListBox) ($UsersCheckedListBox)})
$mainForm.controls.Add($ReportButton)

#########################################################################
## SHOW GUI
#########################################################################
[void]$mainForm.ShowDialog()
$mainForm.Dispose()
