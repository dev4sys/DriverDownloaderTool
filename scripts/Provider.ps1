####################################################################
# SHOULD BE AN ABSTRACT CLASS
# PLEASE DO NOT INSTANCIATE
#################################################################### 



Class Provider{

    
    Static [String]$_vendorName = $null
	
	# Contructor
    Provider()
    {
        $type = $this.GetType()
        if ($type -eq [Provider])
        {
            throw("Class $type must be inherited")
        }
    }


	#####################################################################
    # Get all Data from HP 
    #####################################################################
    
    Static hidden [Object[]] GetDevicesCatalog()
    {
		 return $null
	}
	
	
	#########################################################################
    # Find Model Based on User input
    #########################################################################

    [Object[]] FindModel($userInputModel)
    {
		return $null
	}
	
	
	#########################################################################
    # Get Product URL
    #########################################################################

    Static hidden [string] GetModelHomepageURL($devicePath)
    {
		return $null
    }
	
	
    #########################################################################
    # Get Json Data for a HP Device from its GUID
    #########################################################################

    hidden [Object[]] GetModelWebResponse($modelGUID)
    {
		return $null
	}
	
	
	#########################################################################
    # Load All Drivers to exploitable format
    #########################################################################

    hidden [Object[]]LoadDriversFromWebResponse($webresponse)
    {
		 return $null
	}
	
	
	
	#########################################################################
    # Download Selected Drivers of the model 
    #########################################################################

    Static [Diagnostics.Stopwatch] StartDriversGroupDownload($selectedDrivers ,$DownloadFolder)
    {
		
		return return $null
	}
	
	
	
	#########################################################################
    # Extract All Drivers inside DownloadFolder
    #########################################################################

    Static [Diagnostics.Stopwatch] StartDriversGroupExtract($DownloadFolder)
    {
		
        return $null
		
	}
	
	
	
}




