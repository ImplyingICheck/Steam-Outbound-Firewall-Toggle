Import-Module -Name ($PSScriptRoot + "\CustomUserIO") -Function Exit-OnKeyPress
# TODO: Create module manifest

function Test-IsAdministrator {
	<#
    .SYNOPSIS
        Checks if the current console has administrator privileges
    .DESCRIPTION
        Queries the currently assigned role versus the system Administrator role. Returns a boolean.
    .EXAMPLE
        Test-IsAdministrator | ...
    #>
    [CmdletBinding()]
    param ()
    begin {
    }
    process {
		([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
    end {
    }
}

function New-AdminShell {
    <#
    .SYNOPSIS
        Spawns a child PowerShell process with administrator privileges.
    .DESCRIPTION
        Spawns a child PowerShell process with administrator privileges.
		This child process is forwarded the currently executing script. That
		is, the script which invoked New-AdminShell.
    .EXAMPLE
        New-AdminShell
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$ScriptPath = ""
    )
    begin {
	}
    process {
		$params = @{
			FilePath = "PowerShell"
			Verb = "RunAs"
			ArgumentList = $ScriptPath
		}
		Start-Process @params
    }
    end {
	}
}

function Start-AsAdministrator {
    <#
    .SYNOPSIS
        Spawns a shell with administrator privileges and executes the indicated script.
    .DESCRIPTION
        If the current shell does not have administrator privileges, a UAC request is sent to open 
		a new child shell with elevated permission. The child shell then receives the invoking script
		and continues to execute the code. If successful, the parent shell is then killed.
    .EXAMPLE
        Test-IsAdministrator $PSCommandPath
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$ScriptPath
    )
    begin {
    }
    process {
		try {
			New-AdminShell $ScriptPath
		} catch { # TODO: Add explicit case
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    $PSItem.Exception,
                    'ScriptNotRun',
                    [System.Management.Automation.ErrorCategory]::PermissionDenied,
                    $ScriptPath
                )
            )
		}
    }
    end {
    }
}

Export-ModuleMember -Function Start-AsAdministrator, Test-IsAdministrator