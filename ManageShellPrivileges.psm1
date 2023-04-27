Import-Module -Name .\CustomUserIO -Function Exit-OnKeyPress
# TODO: Create module manifest

function Check-IsAdmin {
	<#
    .SYNOPSIS
        Checks if the current console has administrator privileges
    .DESCRIPTION
        Queries the currently assigned role versus the system Administrator role. Returns a boolean.
    .EXAMPLE
        Check-IsAdmin | ...
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
    param ()
    begin {
	}
    process {
		$params = @{
			FilePath = "PowerShell"
			Verb = "RunAs"
			ArgumentList = "{0}" -f $PSCommandPath
		}
		Start-Process @params
    }
    end {
	}
}

function Get-AdminPrivilege {
    <#
    .SYNOPSIS
        Spawns a shell with administrator privileges and executes the rest of the script.
    .DESCRIPTION
        If the current shell does not have administrator privileges, a UAC request is sent to open 
		a new child shell with elevated permission. The child shell then receives the invoking script
		and continues to execute the code. If successful, the parent shell is then killed.
    .EXAMPLE
        Get-AdminPrivilege
    #>
    [CmdletBinding()]
    param ()
    begin {
    }
    process {
		if (-not ( Check-IsAdmin )) {
			try {
				New-AdminShell
			} catch { #TODO: Add explicit case
				Exit-OnKeyPress "FATAL ERROR: This script requires administrator privileges to run."
			}
		}
    }
    end {
    }
}

Export-ModuleMember -Function Get-AdminPrivilege