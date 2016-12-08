Import-Module ApplicationInsightsLogging;

#This is your Application Insight Instrumentation Key from the Azure Portal. Stored in an Azure automation variable.
$InstrumentationKey = Get-AutomationVariable -Name 'AI_ApiKey'
$Operation = '6-Azure Automation';
$Version = '2016-12-01';
Connect-ApplicationInsights -InstrumentationKey $InstrumentationKey -OperationName $Operation -ComponentVersion $Version
$stopwatch = [System.Diagnostics.StopWatch]::StartNew();


$url = "http://speedtest.ftp.otenet.gr/files/test1Mb.db"
$output = "$PSScriptRoot\1meg.test"
$start_time = Get-Date

Invoke-WebRequest -Uri $url -OutFile $output
$msg = "Time taken: $((Get-Date).Subtract($start_time).TotalMilliseconds) millisecond(s)"
$msg | Out-ApplicationInsights
$msg;



$metrics = Get-ApplicationInsightsMetricsDictionary;
$metrics['Runtime'] = $stopwatch.Elapsed.TotalSeconds;
$client = Get-ApplicationInsightsTelemetryClient;
$client.TrackEvent($Operation);
$client.Flush();