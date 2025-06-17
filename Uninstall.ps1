Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define Services and Apps
$services = @("XboxGipSvc","xbgm","XblAuthManager","XblGameSave","XboxNetApiSvc","WMPNetworkSvc","WerSvc","SysMain","RetailDemo","irmon","Fax","WdiSystemHost","WdiServiceHost","DPS","BITS","WpcMonSvc","wmiApSrv","WbioSrvc","WalletService","TabletInputService","SystemUsageReportSvc_WILLAMETTE","SkypeUpdate","ShareItSvc","MapsBroker","lfsvc")
$apps = @("Microsoft.messaging","Microsoft.GetHelp","Microsoft.GetStarted","Microsoft.Microsoft3DViewer","Microsoft.BingNews","Microsoft.BingWeather","Microsoft.BingSports","Microsoft.BingFinance","Microsoft.MicrosoftOfficeHub","Microsoft.MicrosoftSolitaireCollection","Microsoft.Office.OneNote","Microsoft.OneConnect","Microsoft.People","Microsoft.Print3D","Microsoft.SkypeApp","Microsoft.Wallet","microsoft.windowscommunicationsapps","Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps","Microsoft.WindowsPhone","Microsoft.Xbox.TCUI","Microsoft.XboxApp","Microsoft.XboxGameOverlay","Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay","Microsoft.ZuneMusic","Microsoft.ZuneVideo","Microsoft.MinecraftUWP","Facebook.Facebook","flaregamesGmbH.RoyalRevolt2","king.com.CandyCrushSodaSaga","Microsoft.BioEnrollment","Microsoft.Windows.ShellExperienceHost","Microsoft.Windows.CloudExperienceHost","Microsoft.Windows.ContentDeliveryManager","Microsoft.Windows.ParentalControls","Microsoft.Windows.SecondaryTileExperience","Microsoft.Advertising.Xaml","Microsoft.CommsPhone","Microsoft.Windows.FeatureOnDemand.InsiderHub","Microsoft.Appconnector","Microsoft.Office.Sway","Microsoft.Office.OneNote","Windows.ContactSupport","Microsoft.XboxGameCallableUI","Microsoft.Windows.PeopleExperienceHost","38062AvishaiDernis.DiscordUWP","Facebook.InstagramBeta")

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "App & Service Manager"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

# Services CheckedListBox
$svcLabel = New-Object System.Windows.Forms.Label
$svcLabel.Text = "Select Services to Disable"
$svcLabel.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($svcLabel)

$svcList = New-Object System.Windows.Forms.CheckedListBox
$svcList.Size = New-Object System.Drawing.Size(350,400)
$svcList.Location = New-Object System.Drawing.Point(10,30)
$svcList.Items.AddRange($services)
$form.Controls.Add($svcList)

# Apps CheckedListBox
$appLabel = New-Object System.Windows.Forms.Label
$appLabel.Text = "Select Apps to Uninstall"
$appLabel.Location = New-Object System.Drawing.Point(400,10)
$form.Controls.Add($appLabel)

$appList = New-Object System.Windows.Forms.CheckedListBox
$appList.Size = New-Object System.Drawing.Size(350,400)
$appList.Location = New-Object System.Drawing.Point(400,30)
$appList.Items.AddRange($apps)
$form.Controls.Add($appList)

# Run Button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Apply Changes"
$runButton.Location = New-Object System.Drawing.Point(350,500)
$form.Controls.Add($runButton)

# Output TextBox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.Size = New-Object System.Drawing.Size(760,60)
$outputBox.Location = New-Object System.Drawing.Point(10,430)
$form.Controls.Add($outputBox)

# Button Click Event
$runButton.Add_Click({
    $outputBox.Clear()
    # Disable selected services
    foreach ($svc in $svcList.CheckedItems) {
        try {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            $outputBox.AppendText("Disabled service: $svc`r`n")
        } catch {
            $outputBox.AppendText("Error disabling service: $svc`r`n")
        }
    }
    # Uninstall selected apps
    foreach ($app in $appList.CheckedItems) {
        $Packages = Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq $app}
        if ($Packages) {
            foreach ($Package in $Packages) {
                try {
                    Remove-AppxPackage -Package $Package.PackageFullName -ErrorAction SilentlyContinue
                    $outputBox.AppendText("Removed Appx Package: $app`r`n")
                } catch {
                    $outputBox.AppendText("Error removing Appx Package: $app`r`n")
                }
            }
        } else {
            $outputBox.AppendText("Unable to find package: $app`r`n")
        }
        $ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $app}
        if ($ProvisionedPackage) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $ProvisionedPackage.PackageName -ErrorAction SilentlyContinue
                $outputBox.AppendText("Removed Provisioned Package: $app`r`n")
            } catch {
                $outputBox.AppendText("Error removing Provisioned Package: $app`r`n")
            }
        } else {
            $outputBox.AppendText("Unable to find provisioned package: $app`r`n")
        }
    }
    # Optionally, handle OneDrive
    if ($appList.CheckedItems.Contains("OneDrive")) {
        try {
            Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
            Start-Process "C:\Windows\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait
            $outputBox.AppendText("Uninstalled OneDrive`r`n")
        } catch {
            $outputBox.AppendText("Error uninstalling OneDrive`r`n")
        }
    }
    $outputBox.AppendText("All selected actions completed.`r`n")
})

# Show form
[void]$form.ShowDialog()
