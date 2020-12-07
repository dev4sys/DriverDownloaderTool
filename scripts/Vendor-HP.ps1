####################################################################
# THIS CLASS IMPLEMENTS ALL METHODS THAT A DEVICE
# CONSTRUCTOR SHOULD HAVE
#################################################################### 


$Script:7zipExtractExe = (Get-Item "$($PSScriptRoot)\..\resources\7z2002-x64\7z.exe").FullName



###################################################################
# -------------------------------------------------------
# *** DEPENDENCY ***
# -------------------------------------------------------
#
# This scripts requires: 
#
# --> 7z.exe used to decompress all other extractable archive type
#       
# 
###################################################################



Class HP{

    
    Static [String]$_vendorName = "Hewlett-Packard"
	[Object[]] hidden $_deviceCatalog 
	
	# Contructor
    HP()
    {
        $this._deviceCatalog = [HP]::GetDevicesCatalog()
    }

	
	
	#####################################################################
    # Get all Data from HP 
    #####################################################################
    
    Static hidden [Object[]]GetDevicesCatalog()
    {
		 return $jsonObject
	}
	
	
	#########################################################################
    # Find Model Based on User input
    #########################################################################

    [Object[]]FindModel($userInputModel)
    {
		return $SearchResultFormatted
	}
	
	
	#########################################################################
    # Get Product URL
    #########################################################################

    Static hidden [string] GetModelHomepageURL($devicePath)
    {
		return $Homepage
    }
	
	
    #########################################################################
    # Get Json Data for a HP Device from its GUID
    #########################################################################

    hidden [Object[]] GetModelWebResponse($modelGUID)
    {
		return $xmlModelInput
	}
	
	
	#########################################################################
    # Load All Drivers to exploitable format
    #########################################################################

    hidden [Object[]]LoadDriversFromWebResponse($webresponse)
    {
		 return $DownloadItemsObj
	}
	
	
	
	#########################################################################
    # Download Selected Drivers of the model 
    #########################################################################

    Static [Diagnostics.Stopwatch] StartDriversGroupDownload($selectedDrivers ,$DownloadFolder)
    {
		
		$GroupsByCategory = $selectedDrivers | Group-Object -Property Category
        # Start a timer
        $Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $Stopwatch.Start()



		$Stopwatch.Stop()
        Write-Host ""
        Write-Host "Completed in $($Stopwatch.Elapsed.Minutes) minutes and $($Stopwatch.Elapsed.Seconds) seconds"

		return $Stopwatch
	}
	
	
	
	#########################################################################
    # Extract All Drivers inside DownloadFolder
    #########################################################################

    Static [Diagnostics.Stopwatch] StartDriversGroupExtract($DownloadFolder)
    {
		
        # Start a timer
        $Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $Stopwatch.Start()



		$Stopwatch.Stop()
		return $Stopwatch
		
	}
	
	
	
	#########################################################################
    # Extract Dell Drivers
    #########################################################################
    
    Static hidden [Void] ExtractDriversContent($file,$destination)
    {
	
	
	}
	
}




