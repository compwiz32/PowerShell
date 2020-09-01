{
$PromptData="PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
$host.ui.RawUI.WindowTitle=$PromptData+’-‘+(Get-Date).tostring()
# .Link# http://go.microsoft.com/fwlink/?LinkID=225750
# .ExternalHelp System.Management.Automation.dll-help.xml
}