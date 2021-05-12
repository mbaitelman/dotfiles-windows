function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "PowerShell"
    $Toast.Group = "PowerShell"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $Notifier.Show($Toast);
}

function Show-TKNotification {
    param (
        [Parameter(Mandatory=$false)][string]$suites = ''
    )
    $response_data = @()
    $files = Get-ChildItem -Path inspecreports -Recurse -Include *.json -Filter *$filefilter* #This assumes you have a folder called inspecreports for the responses 
    $response_data = @()
    for($i=0; $i -lt $files.Count; $i++){
        $inspec_json = (convertfrom-json (get-content $files[$i]) ) 
        $suite_name = $files[$i].name.trim('.json')

        $passed = 0
        $failed = 0
    
        foreach($control in $inspec_json.profiles[0].controls){
            foreach($result in $control.results){
                if( $result.status -eq 'passed'){
                    $passed ++
                } else {
                    $failed ++ 
                }
            }
        }
        # array add text
        $response_data += "$suite_name $passed/$failed"
    }

    Show-Notification -ToastTitle "TK Complete" -ToastText ($response_data -join "`r`n" | Out-String)

}
