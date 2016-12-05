
function Connect-ApplicationInsights
{
	<#
	.SYNOPSIS
	.DESCRIPTION 
	.PARAMETER InstrumentationKey
	.EXAMPLE f24a3b1c-6b88-4ec8-9627-89761718b578
	#>
	param (
		[parameter(Mandatory=$true)][Guid]$InstrumentationKey,
		[parameter(Mandatory=$false)][string]$OperationId = [System.Guid]::NewGuid().ToString(),
		[parameter(Mandatory=$false)][string]$OperationName = 'PowerShell Script',
		[parameter(Mandatory=$false)][string]$ComponentVersion = 'NA'
	)

	$AI = [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active;

	if(-not $global:ApplicationInsightsConnected) {
		$global:ApplicationInsightsConnected = $true;	
		$AI.DisableTelemetry = $false;
	}
	if(-not $global:ApplicationInsightsInited) {
		$global:ApplicationInsightsInited = $true;
		$telemetryInitializers = @(
			'Microsoft.ApplicationInsights.WindowsServer.AzureRoleEnvironmentTelemetryInitializer',
			'Microsoft.ApplicationInsights.Extensibility.SequencePropertyInitializer',
			'Microsoft.ApplicationInsights.Extensibility.OperationCorrelationTelemetryInitializer'
			#'Microsoft.ApplicationInsights.WindowsServer.BuildInfoConfigComponentVersionTelemetryInitializer'
		);
		$telemetryInitializers | ForEach { $obj = New-Object $_; $AI.TelemetryInitializers.Add($obj); }
		
		if($global:TelemetryInit) {
			#.\lib\TelemetryInitializer.ps1;
			$AI.TelemetryInitializers.Add($global:TelemetryInit);
		}
		
		$telemetryModules = @(
			'Microsoft.ApplicationInsights.DependencyCollector.DependencyTrackingTelemetryModule'
			#'Microsoft.ApplicationInsights.Extensibility.PerfCounterCollector.PerformanceCollectorModule'
			#'Microsoft.ApplicationInsights.WindowsServer.UnhandledExceptionTelemetryModule'
			#'Microsoft.ApplicationInsights.WindowsServer.UnobservedExceptionTelemetryModule'
		);
		$TelemetryModulesObj = [Microsoft.ApplicationInsights.Extensibility.Implementation.TelemetryModules]::Instance;
		$telemetryModules | ForEach { $obj = New-Object $_;	$TelemetryModulesObj.Modules.Add($obj); }

		$AI.TelemetryInitializers | where {$_ -is 'Microsoft.ApplicationInsights.Extensibility.ITelemetryModule'} | ForEach { $_.Initialize($AI); }
		$AI.TelemetryProcessorChain.TelemetryProcessors | where {$_ -is 'Microsoft.ApplicationInsights.Extensibility.ITelemetryModule'} | ForEach { $_.Initialize($AI); }
		$TelemetryModulesObj.Modules | where {$_ -is 'Microsoft.ApplicationInsights.Extensibility.ITelemetryModule'} | ForEach { $_.Initialize($AI); }
		
		$traceListener = New-Object Microsoft.ApplicationInsights.TraceListener.ApplicationInsightsTraceListener;
		[void] [System.Diagnostics.Trace]::Listeners.Add($traceListener);
		[System.Diagnostics.Trace]::AutoFlush = $true;
	}

	$global:TelemetryClient = New-Object Microsoft.ApplicationInsights.TelemetryClient;

	$AI.InstrumentationKey = $InstrumentationKey;

	$global:TelemetryClient.Context.Operation.Id = $OperationId;
	$global:TelemetryClient.Context.Operation.Name = $OperationName;
	$global:TelemetryClient.Context.Component.Version = $ComponentVersion;
	if($global:TelemetryInit) {
		$global:TelemetryInit.OperationId = $OperationId;
		$global:TelemetryInit.OperationName = $OperationName;
		$global:TelemetryInit.ComponentVersion = $ComponentVersion;
	}
}

function Disconnect-ApplicationInsights
{
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	
	if($global:ApplicationInsightsConnected) {
		$global:ApplicationInsightsConnected = $false;
		$AI = [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active;
		
		$AI.DisableTelemetry = $true;
	}
}

function Get-ApplicationInsightsTelemetryClient{
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	return $global:TelemetryClient;
}

function Set-ApplicationInsightsOperationId{
	<#
	.SYNOPSIS
	.DESCRIPTION 
	.PARAMETER OperationId
	.EXAMPLE f24a3b1c-6b88-4ec8-9627-89761718b578
	#>
	param (
		[parameter(Mandatory=$true)][string]$OperationId
	)
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	$global:TelemetryClient.Context.Operation.Id = $OperationId;
	if($global:TelemetryInit) {
		$global:TelemetryInit.OperationId = $OperationId;
	}
}

function Set-ApplicationInsightsOperationName{
	<#
	.SYNOPSIS
	.DESCRIPTION 
	.PARAMETER OperationName
	.EXAMPLE Test Application Insights
	#>
	param (
		[parameter(Mandatory=$true)][string]$OperationName
	)
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	$global:TelemetryClient.Context.Operation.Name = $OperationName;
	if($global:TelemetryInit) {
		$global:TelemetryInit.OperationName = $OperationName;
	}
}

function Set-ApplicationInsightsComponentVersion{
	<#
	.SYNOPSIS
	.DESCRIPTION 
	.PARAMETER ComponentVersion
	.EXAMPLE 1.1
	#>
	param (
		[parameter(Mandatory=$true)][string]$ComponentVersion
	)
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	$global:TelemetryClient.Context.Component.Version = $ComponentVersion;
	if($global:TelemetryInit) {
		$global:TelemetryInit.ComponentVersion = $ComponentVersion;
	}
}

function Out-ApplicationInsights{
	param (
		[parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][string]$Text
	)
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	$global:TelemetryClient.TrackTrace($Text);
}