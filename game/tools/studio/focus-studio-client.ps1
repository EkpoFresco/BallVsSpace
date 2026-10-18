param([int]$StudioProcessId)
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$p = Get-Process -Id $StudioProcessId
if ($p.ProcessName -ne 'RobloxStudioBeta' -or $p.MainWindowTitle -notlike '*BallVsSpace*') { throw 'Not the verified BallVsSpace window' }
$w = [System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
$c = [System.Windows.Automation.PropertyCondition]::new([System.Windows.Automation.AutomationElement]::NameProperty,'Client')
foreach ($e in $w.FindAll([System.Windows.Automation.TreeScope]::Descendants,$c)) {
 if ($e.Current.ControlType -eq [System.Windows.Automation.ControlType]::TabItem) { $e.SetFocus(); Write-Output 'Focused BallVsSpace Client viewport'; break }
}
