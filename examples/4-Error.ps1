Import-Module ApplicationInsightsLogging

#This is your Application Insight Instrumentation Key from the Azure Portal
$InstrumentationKey = 'f01a3b1c-6b88-4ec8-9627-89761718b578';
$Operation = $script:MyInvocation.MyCommand.Name;
$Version = (Get-Item $script:MyInvocation.MyCommand.Source).LastWriteTime.ToString('u');

Connect-ApplicationInsights -InstrumentationKey $InstrumentationKey -OperationName $Operation -ComponentVersion $Version
$stopwatch = [System.Diagnostics.StopWatch]::StartNew();



	$url = "http://mirror.internode.on.net/pub/test/nonexisting"
	$output = "$PSScriptRoot\1meg.test"
	Invoke-WebRequest -Uri $url -OutFile $output
	try {
		Invoke-WebRequest -Uri $url -OutFile $output
	} catch {
		$client = Get-ApplicationInsightsTelemetryClient;
		$client.TrackException($_.Exception);
	}



$metrics = Get-ApplicationInsightsMetricsDictionary;
$metrics['Runtime'] = $stopwatch.Elapsed.TotalSeconds;
$client = Get-ApplicationInsightsTelemetryClient;
$client.TrackEvent($Operation);
$client.Flush();