<#
.SYNOPSIS
    Creates a preset for a Discord Webhook.
.DESCRIPTION
    Saves a preset file with the Webhook URL inside
.EXAMPLE
    New-DiscordHook -Name "Build-Completed" -URL "<Discord WebHook URL>"
.EXAMPLE
    New-DiscordHook -Name "Build-Completed" -URL "<Discord WebHook URL>" -Force
.INPUTS
    Name
    URL
.COMPONENT
    PS-Discord.psm1
#>
function New-DiscordHook {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias("New-dhook")]
    [OutputType([Boolean])]
    param (
        # Name for the Discord WebHook
        [Parameter(
            Mandatory = $true,
            Position=0,
            ValueFromPipeline=$True
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,
        # URL for the Discord WebHook
        [Parameter(
            Mandatory = $true,
            Position=1,
            ValueFromPipeline=$True
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $URL,
        # Forces the creation of the new WebHook, even if it already exists.
        [Parameter(
            Mandatory = $false
        )]
        [Switch]
        $Force
    )
    begin{
        #Verify the PS-Discord Folders Exist.
        $PSDiscordPath = "$($env:LOCALAPPDATA)\PS-Discord"
        $PSDiscordPath_Hooks = "$($PSDiscordPath)\Hooks"
        $PSDiscordPath_Logs = "$($PSDiscordPath)\Logs"
        if (!(Test-Path -Path $PSDiscordPath -PathType Container)) {
            New-Item -Path $env:LOCALAPPDATA -Name "PS-Discord" -ItemType "Directory" -Force > $null
            New-Item -Path $PSDiscordPath -Name "Logs" -ItemType "Directory" -Force > $null
            New-Item -Path $PSDiscordPath -Name "Hooks" -ItemType "Directory" -Force > $null
        }
        elseif (!(Test-Path -Path $PSDiscordPath_Hooks -PathType Container)) {
            New-Item -Path $PSDiscordPath -Name "Hooks" -ItemType "Directory" -Force > $null
        }
        elseif (!(Test-Path -Path $PSDiscordPath_Logs -PathType Container)) {
            New-Item -Path $PSDiscordPath -Name "Logs" -ItemType "Directory" -Force > $null 
        }
    }
    process {
        #Check to see if the Hook Already exists, and check if the action was forced.
        switch ($Force) {
            $true {
                New-Item -Path $PSDiscordPath_Hooks -Name "$($Name).hook" -ItemType File -Value $URL -Force -Confirm:$false > $null
            }
            $false {
                if (!(Test-Path -Path "$($PSDiscordPath_Hooks)\$($Name).hook" -PathType Leaf)) {
                    New-Item -Path $PSDiscordPath_Hooks -Name "$($Name).hook" -ItemType File -Value $URL > $null
                }
                else {
                    throw "Error: Unable to Create Discord Hook, as the hook already exists. ($($PSDiscordPath_Hooks)\$($Name).hook)"
                }
            }
        }
    }
    end{
        #Verify the Hook was created successfully
        switch (Test-Path -Path "$($PSDiscordPath_Hooks)\$($Name).hook" -PathType Leaf) {
            $true { return $true }
            $false { return $false }
        }
    }
}
<#
.SYNOPSIS
    Invokes a Discord Webhook Preset
.DESCRIPTION
    Invokes a Post Method to a Discord Webhook using a defined preset, or a URL.
.EXAMPLE
    Invoke-DiscordHook -Name "Build-Completed" -Value "This Build has completed."
.EXAMPLE
    Invoke-DiscordHook -URL "<Discord WebHook URL>" -Value "This Build has Completed."
.INPUTS
    Name
    URL
    Value
.COMPONENT
    PS-Discord.psm1
#>
function Invoke-DiscordHook {
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias("Invoke-dhook")]
    [OutputType([Boolean])]
    param (
        # Name for the Discord WebHook
        [Parameter(
            Mandatory = $false,
            Position=0,
            ValueFromPipeline=$True
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,
        # Content for the Discord WebHook to output
        [Parameter(
            Mandatory = $true,
            Position=1,
            ValueFromPipeline=$True
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Value,
        # URL for the Discord WebHook
        [Parameter(
            Mandatory = $false,
            Position=2,
            ValueFromPipeline=$True
        )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]
        $URL
    )
    begin{
        $PSDiscordPath = "$($env:LOCALAPPDATA)\PS-Discord"
        $PSDiscordPath_Hooks = "$($PSDiscordPath)\Hooks"
        foreach ($Hook in (Get-ChildItem -Path $PSDiscordPath_Hooks -Recurse)) {
            if ($Hook.Name -like ("$($Name).hook")) {
                $URL = Get-Content -Path "$($PSDiscordPath_Hooks)\$($Name).hook"
            }
        }
        $Pre_Payload = 
@"
$($Value)
"@
        $Payload = [PSCustomObject]@{
            content = $Pre_Payload
        }
        
    }
    process{
        try {
            Invoke-RestMethod -uri $URL -Method Post -Body ($Payload | ConvertTo-Json) -ContentType 'Application/Json'
            $ReturnValue = $true
        }
        catch {
            $ReturnValue = $false
            throw $_
        }
    }
    end{
        Return $ReturnValue
    }
}