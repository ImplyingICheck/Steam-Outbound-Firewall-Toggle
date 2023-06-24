Add-Type -AssemblyName System.Windows.Forms

. (Join-Path $PSScriptRoot main.ps1)

$DEFAULTSTYLE = @{
    ForeColor = "White"
    Font = [System.Drawing.Font]::new( "Segoi UI", 20, [System.Drawing.FontStyle]::Bold )
}
$RULEACTIVE = @{
                  Text = "Steam is actively being smothered."
                  BackColor = "Red"
              } + $DEFAULTSTYLE
$RULENOTACTIVE = @{
                     Text = "Steam is currently allowed to breathe."
                     BackColor = "Green"
                 } + $DEFAULTSTYLE
$CREATERULE = @{
                  Text = "Create firewall rule for Steam."
                  BackColor = "Blue"
              } + $DEFAULTSTYLE


function Get-QuarterScreenSize {
    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
    # Use the square of the desired scaling factor
    $desiredWidth = [math]::Round( $screenWidth * 0.50 )
    $desiredHeight = [math]::Round( $screenHeight * 0.50 )
    @{
        Width = $desiredWidth
        Height = $desiredHeight
    }
}

function Get-ButtonStyle {
    if (Get-SWdfRule) {
        if (Test-SWdfRuleIsEnabled) {
            $RULEACTIVE
        } else {
            $RULENOTACTIVE
        }
    } else {
        $CREATERULE
    }
}

function Set-ButtonStyle( $button, $style ) {
    $button.Text = $style["Text"]
    $button.BackColor = $style["BackColor"]
    $button.ForeColor = $style["ForeColor"]
    $button.Font = $style["Font"]
}

function New-GUI {
    # Create a form
    $form = [System.Windows.Forms.Form]( @{
                                             Text = "Toggle Steam Firewall Rule"
                                         } + ( Get-QuarterScreenSize ) )
    # Create a button
    $toggleButton = [System.Windows.Forms.Button]@{
        Width = $form.Width
        Height = $form.Height
    }
    Set-ButtonStyle $toggleButton ( Get-ButtonStyle )
    # Define a click event handler for the toggle button
    $toggleButton.Add_Click( {
                                 $currentStyle = Get-ButtonStyle
                                 if ($currentStyle -eq $RULEACTIVE) {
                                     Switch-SWdfRule
                                     Set-ButtonStyle $toggleButton $RULENOTACTIVE
                                 } elseif ($currentStyle -eq $RULENOTACTIVE) {
                                     Switch-SWdfRule
                                     Set-ButtonStyle $toggleButton $RULEACTIVE
                                 } elseif ($currentStyle -eq $CREATERULE) {
                                     New-SWdfRule
                                     Set-ButtonStyle $toggleButton $RULEACTIVE
                                 }
                             } )
    # Resize the button along with the form
    $form.add_Resize( {
                          $toggleButton.Width = $form.Width
                          $toggleButton.Height = $form.Height
                          $toggleButton.Left = ($form.Width - $toggleButton.Width ) / 2
                          $toggleButton.Top = ($form.Height - $toggleButton.Height ) / 2
                      } )
    # Add button
    $form.Controls.Add( $toggleButton )
    $form.ShowDialog()
}

if (-not( Test-IsAdministrator )) {
    Start-AsAdministrator $PSCommandPath
} else {
    New-GUI
}
