# #########################################################
# Common Function 
# #########################################################



function Get-SelectedDrivers
{
    
    $SelectedDrivers = $Datagrid.DataContext | ?{$_.Files.IsSelected -eq $true}
    return $SelectedDrivers
}


function Download-Drivers
{

    param (
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [string]$UrlSelected,
        [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
        [string]$DownloadDirectory
    )

    Write-Host "Initiating download of URL '$UrlSelected' with BITS"
    Try
    {
        # Begin the download
        Start-BitsTransfer -Source $UrlSelected -Destination $DownloadDirectory
    }
    Catch
    {
        $_
    }
    
}




