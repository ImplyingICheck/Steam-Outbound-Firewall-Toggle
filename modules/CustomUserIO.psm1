# TODO: Create module manifest

function Exit-OnKeyPress {
    <#
    .SYNOPSIS
        Shows a message to the user, then exits upon a key press.
    .DESCRIPTION
        Shows a message to the end user through the Write-Information 
		pipeline. The final form of the messages is 
		"($Message)[`n][Press any key to exit...]($EndFormatting)"
		
		The script then ceases to execute.
		
		Checks if running Powershell ISE. If so, generates a default window
		and alerts to user to intended end-user behaviour (using a differing 
		instruction blurb).
	.PARAMETER Message
		An optional developer-designated message with no formating applied.
	.PARAMETER EndFormatting
		An optional end formatting and/or message to appear after the default 
		instructions. Can also be used to replace the instruction blurb alongside
		-NoInstructionBlurb
	.PARAMETER NoInstructionBlurb
		Allows removal of the default instruction blurb
	.PARAMETER NoDefaultFormatting
		Allows removal of the newline character prior to the instruction blurb.
    .EXAMPLE
        Exit-OnKeyPress "This is" "sandwiching the blurb" -NoDefaultFormatting
	.EXAMPLE
		Exit-OnKeyPress "Unexpected error occured" "<(@.@<)"
	.EXAMPLE
		Exit-OnKeyPress "This is" "<A custom error message>" -NoInstructionBlurb
    #>
    [CmdletBinding()]
    param ( [Parameter(Mandatory = $false)]
        [String]$Message = "",

        [Parameter(Mandatory = $false)]
        [String]$EndFormatting = "",

        [Parameter(Mandatory = $false)]
        [Switch]$NoInstructionBlurb,

        [Parameter(Mandatory = $false)]
        [Switch]$NoDefaultFormatting )
    begin {
    }
    process {
        $defaultNewline = if ($NoDefaultFormatting) {
            ""
        } Else {
            "`n"
        }
        $instructionBlurb = ""
        if (-not$NoInstructionBlurb) {
            $instructionBlurb = if ($PSIse) {
                "!!!PowerShell ISE Notice:!!!`n!!!THIS PROMPT WOULD EXIT ON ANY KEYPRESS FOR CONSOLE!!!"
            } else {
                "Press any key to exit..."
            }
        }
        $finalMessage = "{0}{1}{2}{3}" -f $Message, $defaultNewline, $instructionBlurb, $EndFormatting
        if ($PSIse) {
            Add-Type -AssemblyName System.Windows.Forms
            $null = [System.Windows.Forms.MessageBox]::Show( $finalMessage )
        } else {
            Write-Information $finalMessage
            $null = $host.ui.RawUI.ReadKey( "NoEcho,IncludeKeyDown" )
        }
        Exit
    }
    end {
    }
}

Export-ModuleMember -Function Exit-OnKeyPress