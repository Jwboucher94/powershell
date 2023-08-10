function Join-Azure {
    if ($null -eq (Get-Module -ListAvailable -Name DCToolbox)){
        Write-Host "Installing DCToolbox"
        Install-Module -Name DCToolbox -Scope AllUsers -Force
    }
    if ($null -eq (Get-Module -ListAvailable -Name AzureADPreview)){
        Install-Module -name AzureADPreview -Scope AllUsers -Force
        Write-Host "Installing AzureADPreview"
    }
    if ($null -eq (Get-Module -ListAvailable -Name msal.ps)){
        Start-Process powershell.exe "Install-Package msal.ps -AcceptLicense -Force -Scope Allusers" -Verb RunAs
    }
    Connect-AzureAD
}

function Join-Roles {
    $roleChoice = Read-Host @'
    Please choose from the following roles:
    1. Exchange Administrator
    2. User Administrator
    3. Azure AD Joined Device Local Administrator
    4. Groups Administrator
    5. All above

    9. Custom Role
    0. Quit
    > 
'@

    switch ($roleChoice) {
        '1' { Enable-Role('Exchange Administrator') ; Join-Roles }
        '2' { Enable-Role('User Administrator') ; Join-Roles }
        '3' { Enable-Role('Azure AD Joined Device Local Administrator') ; Join-Roles }
        '4' { Enable-Role('Groups Administrator') ; Join-Roles }
        '5' { Enable-Role('Groups Administrator') ; Enable-Role('User Administrator') ; Enable-Role('Azure AD Joined Device Local Administrator') ; Enable-Role('Exchange Administrator') ; Join-Roles}
        '9' { $roleName = Read-Host "Please enter the full role name here:" ; Enable-Role($roleName) ; Join-Roles }
        '0' { Write-Host 'Quitting...'; Pause; Exit }
    }

}

function Enable-Role($roleName) {
    if ($time -eq 'True') {
        Enable-DCAzureADPIMRole -RolesToActivate $roleName -UseMaximumTimeAllowed -Reason $reason
    } else {
        Enable-DCAzureADPIMRole -RolesToActivate $roleName -Reason $reason
    }
}

Write-Warning 'This will connect you to Azure AD service. Do you agree?' -WarningAction Inquire
Join-Azure
$global:reason = Read-Host "Please enter your reason for activating your role(s):"
$title    = 'Max Time'
$question = 'Do you want to use the maximum time? (8 Hours)'
$choices  = '&Yes', '&No'
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
if ($decision -eq 0) {
    $global:time = 'True'
} else {
    $global:time = 'False'
}
Join-Roles
