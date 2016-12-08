
$script:Assem = ( 
    "Microsoft.ApplicationInsights, Version=2.1.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    );

$script:Source = @"
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

public class PowerShellTelemetryInitializer : ITelemetryInitializer
{
	public IDictionary<string, string> TelemetryProperties;
	public IDictionary<string, double> TelemetryMetrics;
	public string SessionId;
	public string OperationId;
	public string OperationName;
	public string ComponentVersion;
	
	public PowerShellTelemetryInitializer()
	{
		TelemetryProperties = new Dictionary<string, string>();
		TelemetryMetrics = new Dictionary<string, double>();
	}

	public void Initialize(ITelemetry telemetry)
	{
		if (telemetry == null || telemetry.Context == null) return;

		telemetry.Context.Session.Id = SessionId;
		telemetry.Context.Operation.Id = OperationId;
		telemetry.Context.Operation.Name = OperationName;
		telemetry.Context.Component.Version = ComponentVersion;
		
		if (TelemetryProperties != null && TelemetryProperties.Count > 0)
		{
			foreach (var property in TelemetryProperties)
			{
				if (!telemetry.Context.Properties.ContainsKey(property.Key))
					telemetry.Context.Properties.Add(property);
			}
		}
		
		if (TelemetryMetrics != null && TelemetryMetrics.Count > 0)
		{
			var eventTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.EventTelemetry;
			if (eventTelemetry != null)
			{
				foreach (var property in TelemetryMetrics)
				{
					if (!eventTelemetry.Metrics.ContainsKey(property.Key))
						eventTelemetry.Metrics.Add(property);
				}
			}
			var pageViewTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.PageViewTelemetry;
			if (pageViewTelemetry != null)
			{
				foreach (var property in TelemetryMetrics)
				{
					if (!pageViewTelemetry.Metrics.ContainsKey(property.Key))
						pageViewTelemetry.Metrics.Add(property);
				}
			}
			//var availabilityTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.AvailabilityTelemetry;
			//if (availabilityTelemetry != null)
			//{
			//	foreach (var property in TelemetryMetrics)
			//	{
			//		if (!availabilityTelemetry.Metrics.ContainsKey(property.Key))
			//			availabilityTelemetry.Metrics.Add(property);
			//	}
			//}
			var exceptionTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.ExceptionTelemetry;
			if (exceptionTelemetry != null)
			{
				foreach (var property in TelemetryMetrics)
				{
					if (!exceptionTelemetry.Metrics.ContainsKey(property.Key))
						exceptionTelemetry.Metrics.Add(property);
				}
			}
			var requestTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.RequestTelemetry;
			if (requestTelemetry != null)
			{
				foreach (var property in TelemetryMetrics)
				{
					if (!requestTelemetry.Metrics.ContainsKey(property.Key))
						requestTelemetry.Metrics.Add(property);
				}
			}
			//var dependencyTelemetry = telemetry as Microsoft.ApplicationInsights.DataContracts.DependencyTelemetry;
			//if (dependencyTelemetry != null)
			//{
			//	foreach (var property in TelemetryMetrics)
			//	{
			//		if (!dependencyTelemetry.Metrics.ContainsKey(property.Key))
			//			dependencyTelemetry.Metrics.Add(property);
			//	}
			//}
		}
	}
}
"@

Add-Type -ReferencedAssemblies $script:Assem -TypeDefinition $script:Source -Language CSharp  
$global:TelemetryInit = New-Object PowerShellTelemetryInitializer;

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
		[parameter(Mandatory=$false)][string]$SessionId = [System.Guid]::NewGuid().ToString(),
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

	$global:TelemetryClient.Context.Session.Id = $SessionId;
	$global:TelemetryClient.Context.Operation.Id = $OperationId;
	$global:TelemetryClient.Context.Operation.Name = $OperationName;
	$global:TelemetryClient.Context.Component.Version = $ComponentVersion;
	if($global:TelemetryInit) {
		$global:TelemetryInit.SessionId = $SessionId;
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

function Send-ApplicationInsightsData{
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	$global:TelemetryClient.Flush();
}

function Get-ApplicationInsightsPropertiesDictionary{
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	return $global:TelemetryInit.TelemetryProperties;
}

function Get-ApplicationInsightsMetricsDictionary{
	if(-not $global:ApplicationInsightsConnected) {
		throw 'Run Connect-ApplicationInsights before.';
	}
	return $global:TelemetryInit.TelemetryMetrics;
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