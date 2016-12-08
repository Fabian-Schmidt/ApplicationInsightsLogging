Import-Module ApplicationInsightsLogging

#This is your Application Insight Instrumentation Key from the Azure Portal
$InstrumentationKey = 'f01a3b1c-6b88-4ec8-9627-89761718b578';
$Operation = $script:MyInvocation.MyCommand.Name;
$Version = (Get-Item $script:MyInvocation.MyCommand.Source).LastWriteTime.ToString('u');

Connect-ApplicationInsights -InstrumentationKey $InstrumentationKey -OperationName $Operation -ComponentVersion $Version
$stopwatch = [System.Diagnostics.StopWatch]::StartNew();



	Import-Module SharePointPnPPowerShellOnline -WarningAction Ignore

	$SharePointOnlineUrl = 'https://mod527448.sharepoint.com/sites/pwa-fab';
	Connect-SPOnline -Url $SharePointOnlineUrl -Credentials Office365DemoAdmin

	$web = Get-SPOWeb;
	$web.Context.Load($web);
	$web.Context.ExecuteQuery();
	$web.Title | Out-ApplicationInsights
	$web.Title



$metrics = Get-ApplicationInsightsMetricsDictionary;
$metrics['Runtime'] = $stopwatch.Elapsed.TotalSeconds;
$client = Get-ApplicationInsightsTelemetryClient;
$client.TrackEvent($Operation);
$client.Flush();