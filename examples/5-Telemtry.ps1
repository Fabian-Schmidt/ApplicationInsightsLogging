Import-Module ApplicationInsightsLogging

#This is your Application Insight Instrumentation Key from the Azure Portal
$InstrumentationKey = 'f01a3b1c-6b88-4ec8-9627-89761718b578';
$Operation = $script:MyInvocation.MyCommand.Name;
$Version = (Get-Item $script:MyInvocation.MyCommand.Source).LastWriteTime.ToString('u');

Connect-ApplicationInsights -InstrumentationKey $InstrumentationKey -OperationName $Operation -ComponentVersion $Version
$stopwatch = [System.Diagnostics.StopWatch]::StartNew();


$properties = Get-ApplicationInsightsPropertiesDictionary;
$properties['Event Source'] = 'Task Scheduler';
$properties['Event Argument 1'] = 'Foo';
$properties['Event Argument 2'] = 'Bar';
$properties['Event Argument 3'] = 'FooBar';


$metrics = Get-ApplicationInsightsMetricsDictionary;
$metrics['QueueLength'] = [System.DateTime]::UtcNow.Hour;
$metrics['CPU Load'] = (Get-WmiObject win32_processor).LoadPercentage;


$metrics = Get-ApplicationInsightsMetricsDictionary;
$metrics['Runtime'] = $stopwatch.Elapsed.TotalSeconds;
$client = Get-ApplicationInsightsTelemetryClient;
$client.TrackEvent($Operation);
$client.Flush();