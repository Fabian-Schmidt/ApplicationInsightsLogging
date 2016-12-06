#
# Module manifest for module 'NewManifest'
#
# Generated by: Fabian Schmidt
#
# Generated on: 12/5/2016
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '0.3'

# ID used to uniquely identify this module
GUID = 'a32d2c5e-1d7d-432e-911c-fd69831580ae'

# Author of this module
Author = 'Fabian Schmidt'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2016 Fabian Schmidt.'

# Description of the functionality provided by this module
Description = 'Integrate Application Insights logging into PowerShell scripts.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @('Microsoft.ApplicationInsights.2.1.0\lib\net45\Microsoft.ApplicationInsights.dll',
        'Microsoft.ApplicationInsights.Agent.Intercept.1.2.1\lib\net45\Microsoft.AI.Agent.Intercept.dll', 
        'Microsoft.ApplicationInsights.DependencyCollector.2.1.0\lib\net45\Microsoft.AI.DependencyCollector.dll', 
        'Microsoft.ApplicationInsights.PerfCounterCollector.2.1.0\lib\net45\Microsoft.AI.PerfCounterCollector.dll',
        'Microsoft.ApplicationInsights.TraceListener.2.1.0\lib\net45\Microsoft.ApplicationInsights.TraceListener.dll',
        'Microsoft.ApplicationInsights.Web.2.1.0\lib\net45\Microsoft.AI.Web.dll',
        'Microsoft.ApplicationInsights.WindowsServer.2.1.0\lib\net45\Microsoft.AI.WindowsServer.dll')
       #'Microsoft.ApplicationInsights.WindowsServer.TelemetryChannel.2.1.0\lib\net45\Microsoft.AI.ServerTelemetryChannel.dll'

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules =  @('ApplicationInsightsLogging.psm1')
        

# Functions to export from this module
FunctionsToExport = @('Connect-ApplicationInsights', 
        'Disconnect-ApplicationInsights', 
        'Get-ApplicationInsightsTelemetryClient', 
        'Set-ApplicationInsightsOperationId', 
        'Set-ApplicationInsightsOperationName', 
        'Set-ApplicationInsightsComponentVersion',
        'Out-ApplicationInsights')

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = '.\Microsoft.ApplicationInsights.2.1.0\lib\net45\Microsoft.ApplicationInsights.dll',
        '.\Microsoft.ApplicationInsights.Agent.Intercept.1.2.1\lib\net45\Microsoft.AI.Agent.Intercept.dll', 
        '.\Microsoft.ApplicationInsights.DependencyCollector.2.1.0\lib\net45\Microsoft.AI.DependencyCollector.dll', 
        '.\Microsoft.ApplicationInsights.PerfCounterCollector.2.1.0\lib\net45\Microsoft.AI.PerfCounterCollector.dll',
        '.\Microsoft.ApplicationInsights.TraceListener.2.1.0\lib\net45\Microsoft.ApplicationInsights.TraceListener.dll',
        '.\Microsoft.ApplicationInsights.Web.2.1.0\lib\net45\Microsoft.AI.Web.dll',
        '.\Microsoft.ApplicationInsights.WindowsServer.2.1.0\lib\net45\Microsoft.AI.WindowsServer.dll', 
        '.\Microsoft.ApplicationInsights.WindowsServer.TelemetryChannel.2.1.0\lib\net45\Microsoft.AI.ServerTelemetryChannel.dll',
        'ApplicationInsightsLogging.psm1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags =  @('Logging', 'ApplicationInsights')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/Fabian-Schmidt/ApplicationInsightsLogging/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Fabian-Schmidt/ApplicationInsightsLogging'

        # A URL to an icon representing this module.
        IconUri = 'https://azure.microsoft.com/svghandler/application-insights/'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

