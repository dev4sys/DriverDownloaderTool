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



$ddlCategoryWeb =[xml]@'
<select id="ddl-category" class="w-100 form-control custom-select drivers-select">
    <option value="">All</option>
    <option value="AP"> Application </option>
    <option value="AU"> Audio </option>
    <option value="BI"> BIOS </option>
	<option value="BR"> Backup and Recovery </option>
    <option value="CS"> Chipset </option>
    <option value="DP"> Dell Data Security </option>
    <option value="DK"> Docks/Stands </option>
	<option value="FW"> Firmware </option>
    <option value="CM"> Modem/Communications </option>
    <option value="IN"> Mouse, Keyboard &amp; Input Devices </option>
    <option value="NI"> Network </option>
    <option value="SY"> Security </option>
    <option value="SA"> Serial ATA </option>
    <option value="PC"> Solid State Storage </option>
	<option value="UT"> System Utilities </option>
    <option value="SM"> Systems Management </option>
    <option value="TDS"> Trusted Device Security </option>
    <option value="VI"> Video </option>
</select>
'@


$Script:dictionaryCategory = @{}
$ddlCategoryWeb.select.option | Foreach {$Script:dictionaryCategory[$_.value] = $_.'#text'.Trim()}



$Script:ddlCategoryWeb =[xml]@'
<select id="operating-system" class="w-100 form-control custom-select drivers-select">
	<option value="BIOSA">BIOS</option>
	<option value="NAA">Not Applicable</option>
	<option value="UB16G">Ubuntu 16.04</option>
	<option value="UB18P">Ubuntu 18.04.3 LTS</option>
	<option value="W732">Windows 7, 32-bit</option>
	<option value="W764">Windows 7, 64-bit</option>
	<option value="WB32A">Windows 8.1, 32-bit</option>
	<option value="WB64A">Windows 8.1, 64-bit</option>
	<option value="WT32A">Windows 10, 32-bit</option>
	<option value="WT64A">Windows 10, 64-bit</option>
</select>
'@



###################################################################
# -------------------------------------------------------
# *** CLASS ***
# -------------------------------------------------------
###################################################################


Class Dell 
{

    
    Static hidden [String]$_vendorName = "Dell"
    hidden [Object[]] $_deviceCatalog 
    hidden [Object[]] $_deviceImgCatalog 

    # Contructor
    Dell()
    {
        $this._deviceCatalog = [Dell]::GetDevicesCatalog()
        $this._deviceImgCatalog = [Dell]::GetDeviceImgCatalog()
        
    }



    #####################################################################
    # Get all Data from DELL (Gz format)
    #####################################################################
    # https://www.dell.com/support/components/eula/en-us/eula/api
    
    Static hidden [Object[]]GetDevicesCatalog()
    {
        
        # --------------------------------------------------------------------------------------------------------
        # Truncated Output exemple
        # PN                                         PC                                   
        # --                                         --                                   
        # Latitude 5290                              latitude-12-5290-laptop              
        # Latitude 5290 2-in-1                       latitude-12-5290-2-in-1-laptop       
        # Latitude 5300                              latitude-13-5300-laptop              
        # Latitude 5300 2-in-1                       latitude-13-5300-2-in-1-laptop    
        # --------------------------------------------------------------------------------------------------------

        $result = Invoke-WebRequest -Uri "https://www.dell.com/support/home/en-us/api/catalog/autosuggest" -Headers @{
            "method"="GET"
            "authority"="www.dell.com"
            "scheme"="https"
            "cache-control"="max-age=0"
            "upgrade-insecure-requests"="1"
            "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
            "sec-fetch-site"="none"
            "sec-fetch-mode"="navigate"
            "sec-fetch-user"="?1"
            "sec-fetch-dest"="document"
            "accept-encoding"="gzip, deflate, br"
            "accept-language"="en-US,en;q=0.9"
        }

        $jsonObject = ($result.Content | ConvertFrom-Json) | Select-Object -Property "PN","PC"
        return $jsonObject
    
    }


    Static hidden [Object[]] GetDeviceImgCatalog()
    {
        
        # --------------------------------------------------------------------------------------------------------
        # This object return another object with Product ID and Image URL associated
        # 
        # --------------------------------------------------------------------------------------------------------
        $gzProductContent = Invoke-WebRequest -Uri "https://downloads.dell.com/Published/data/Products.gz" -Headers @{
            "method"="GET"
            "authority"="www.dell.com"
            "scheme"="https"
            "cache-control"="max-age=0"
            "upgrade-insecure-requests"="1"
            "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
            "sec-fetch-site"="none"
            "sec-fetch-mode"="navigate"
            "sec-fetch-user"="?1"
            "sec-fetch-dest"="document"
            "accept-language"="en-US,en;q=0.9"
            }

        # Convert Stream Data to viewable Content 
        $data = $gzProductContent.Content
        $memoryStream = [System.IO.MemoryStream]::new()
        $memoryStream.Write($data, 0, $data.Length)
        $memoryStream.Seek(0,0) | Out-Null


        $gZipStream = [System.IO.Compression.GZipStream]::new($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
        $streamReader = [System.IO.StreamReader]::new($gZipStream)
        $xmlModelInputRaw = $streamReader.readtoend()  


        # ######################################################
        # Parse content 
        # ######################################################

        $xmlModelInput = New-Object -TypeName System.Xml.XmlDocument
        $xmlModelInput.LoadXml($xmlModelInputRaw)

        $productCatalogObj = $xmlModelInput.Catalog.Product | Select-Object -Property ID,Image


        # Works but too slooooowwww ..... keep for later
        #  $jsonObject =  $autoSuggestCatalog |% { 
        #    foreach ($product in $productCatalogObj) {
        #        if ($_.PC -eq $product.Id) {
        #            [pscustomobject]@{Name=$_.PN;ProductGuid=$_.PC;Image=$product.Image}
        #        }
        #    }
        #}
           
        return $productCatalogObj

    }


    #########################################################################
    # Find Model Based on User input
    #########################################################################

    [Object[]]FindModel($userInputModel)
    {

        # --------------------------------------------------------------------------------------------------------
        # return an Array of object of type: 
        # Name                                       Guid                                  Path                                           Image                 
        # ----                                       ----                                  ----                                           -----                 
        # Latitude 5300                              latitude-13-5300-laptop               /product/latitude-13-5300-laptop               //i.dell.com/is/ima...
        # Latitude 5300 2-in-1                       latitude-13-5300-2-in-1-laptop        /product/latitude-13-5300-2-in-1-laptop        //i.dell.com/is/ima
        # --------------------------------------------------------------------------------------------------------


        $userSearchResult = $this._deviceCatalog | Where-Object {($_.PN -match $userInputModel)} 

        $SearchResultFormatted = ( $userSearchResult | ForEach-Object { 
            if($_){
                $var = $_.PC;
                [PSCustomObject]@{
                    Name=$_.PN;
                    Guid=$_.PC;
                    Path="/product/$($_.PC)";
                    Image=$("https:$(($this._deviceImgCatalog | Where-Object{$_.Id -eq $var}).Image)")
                }
            }
        })

        return $SearchResultFormatted

    }

    
    #########################################################################
    # Get Product URL
    #########################################################################

    Static hidden [string] GetModelHomepageURL($devicePath)
    {

        $Homepage = "https://www.dell.com/support/home/en-us/product-support//$($devicePath)"
        return $Homepage

    }


    #########################################################################
    # Get Json Data for a Dell Device form its GUID
    #########################################################################

    hidden [Object[]] GetModelWebResponse($modelGUID)
    {

        #  ==== For Download  =======
        $modelGzURL = "https://downloads.dell.com/published/data/drivers/$($ModelGUID).gz"

        $gzContent = Invoke-WebRequest -Uri $modelGzURL -Headers @{
          "method"="GET"
          "authority"="www.dell.com"
          "scheme"="https"
          "cache-control"="max-age=0"
          "upgrade-insecure-requests"="1"
          "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
          "sec-fetch-site"="none"
          "sec-fetch-mode"="navigate"
          "sec-fetch-user"="?1"
          "sec-fetch-dest"="document"
          "accept-language"="en-US,en;q=0.9"
         }

        # === Convert Stream Data to viewable Content =====
        $data = $gzContent.Content
        $memoryStream = [System.IO.MemoryStream]::new()
        $memoryStream.Write($data, 0, $data.Length)
        $memoryStream.Seek(0,0) | Out-Null

        $gZipStream = [System.IO.Compression.GZipStream]::new($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
        $streamReader = [System.IO.StreamReader]::new($gZipStream)
        $xmlModelInputRaw = $streamReader.readtoend()  

        # === Parse content =======================
        $xmlModelInput = New-Object -TypeName System.Xml.XmlDocument
        $xmlModelInput.LoadXml($xmlModelInputRaw)

        return $xmlModelInput


    }

	
	#########################################################################
    # Get All Supported OS
    #########################################################################

    hidden [Object[]]GetAllSupportedOS($webresponse)
    {
		
		# Hard Coded until I find Dell Table
        $operatingSystemObj= $Script:ddlCategoryWeb.select.option | Foreach { [PSCustomObject]@{ Name = $_.'#text'.Trim(); Value = $_.value}}
		return $operatingSystemObj

	}

    #########################################################################
    # Load All Drivers to exploitable format
    #########################################################################

    hidden [Object[]]LoadDriversFromWebResponse($webresponse)
    {

        # Webresponse is a xml
        $DownloadItemsObj = [Collections.ArrayList]@()

        if($webresponse.Product.Drivers){

            $DownloadItemsRaw = $webresponse.Product.Drivers.Driver | Sort-Object -Property Title
            $DownloadItemsRawGrouped = $DownloadItemsRaw | Group-Object -Property Title
            
            ForEach ($Itemgroup in $DownloadItemsRawGrouped){
                $item = $null
                # Select only the latest version if multiple
                if($Itemgroup.Group.Count -ge 2){
                    $maximum = 0
                    foreach($vendorVer in $Itemgroup.Group){
                        if($vendorVer.VendorVersion -gt $maximum){
                            $maximum = $vendorVer.VendorVersion
                            #Write-Host $maximum
                            $item = $vendorVer
                        }
                    }
                }else{
                    $item = $Itemgroup.Group
                }

                # ==== Get the exe,zip ... ==========
                [Array]$ExeFiles = $item.File 

                $current = [PSCustomObject]@{
                    Title =$item.Title;
                    Category=$Script:dictionaryCategory[$item.Category];
                    Class=$item.Type;
                    OperatingSystemKeys=$item.OS.Split(",");

                    Files= [Array]($ExeFiles | ForEach-Object { 
                        if($_){
                            [PSCustomObject]@{
                                IsSelected=$false;
                                ID=$item.ID;
                                Name=$_.FileName.Split('/')[-1];
                                Size="$([Math]::Round($_.Size/1MB, 2)) MB";
                                Type=$item.Type;
                                Version=$item.VendorVersion
                                URL="https://dl.dell.com/$($_.FileName)";
                                Priority=$item.Importance ;
                                Date=$item.LastUpdateDate
                            }
                        }
                    })
                }

                $DownloadItemsObj.Add($current) | Out-Null
        
            }

        }

        return $DownloadItemsObj



    }




	#########################################################################
    # Prepare Drivers Download
    #########################################################################

    hidden [Object[]] PrepareDriversGroupDownload($selectedDrivers)
	{
		
		$GroupsByCategory = $selectedDrivers | Group-Object -Property Category
        $cat = $null

        $PreparedDownloadList = [Collections.ArrayList]@()

        foreach ($category in $GroupsByCategory){
       
            # Create category folder 
            switch ($category.Name) {
               "Dell Data Security"               {$cat = "Security"; break}
               "Docks/Stands"                     {$cat = "Docks"; break}
               "Modem/Communications"             {$cat = "Communications"; break}
               "Mouse, Keyboard & Input Devices"  {$cat = "Input"; break}
               "Serial ATA"                       {$cat = "Storage"; break}
               default                            {$cat = $category.Name ; break}
            }


            foreach($item in $category.Group){  
					
		        [Array]$item.Files | ForEach-Object {
                    
                    if($_.IsSelected){
    
                        $current = [PSCustomObject]@{
                            DownloadGroup = $cat;
                            DownLoadID    = $_.ID;
                            DownloadURL   = $_.URL;
                            DownloadSize  = $_.Size
                        }

                        $PreparedDownloadList.Add($current) | Out-Null
                    }

                }
               
            }
			
        }

		return $PreparedDownloadList

    }



    #########################################################################
    # Download Selected Driver of the model 
    #########################################################################

    [String] DownloadDriver($url ,$DownloadFolder )
    {

        $var = 'Success'
		$client = [System.Net.WebClient]::new()
				
        try {
					
            $sourceFileName = $url.SubString($url.LastIndexOf('/')+1)            
            $targetFileName = "$DownloadFolder\$sourceFileName"  

            Write-Host $targetFileName    
	
            $client.DownloadFile($url, $targetFileName)  
            #$client.DownloadFileAsync($UrlSelected, $targetFileName) 
                    
        } 
        Catch { 
            $var = "Error:  $($_.Exception.Message)" 
        }
		Finally{
					
			$client.dispose()
		}
     
        return $var
    }


    #########################################################################
    # Extract All DELL Drivers in DownloadFolder
    #########################################################################

    [String] ExtractDriver($file, $folderPath)
    {
    
		$output = ""


		# --------------------------------------------------------------------------------------------------------
		# buffer overflow in case of large files in output // RedirectStandardOutput = false
		# https://stackoverflow.com/questions/139593/processstartinfo-hanging-on-waitforexit-why
		# --------------------------------------------------------------------------------------------------------


		$pStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
		$pStartInfo.RedirectStandardError = $true
		$pStartInfo.RedirectStandardOutput = $false  
		$pStartInfo.UseShellExecute = $false
		$pStartInfo.CreateNoWindow = $true
		$pStartInfo.FileName = $Script:7zipExtractExe
		# $pStartInfo.Arguments = "x $file Production -o""$folderPath"" -r -y"
		$pStartInfo.Arguments = "x ""$file"" -o""$folderPath"" -r -y"
	
		$process = [System.Diagnostics.Process]::new()
		$process.StartInfo = $pStartInfo
		$process.Start() | Out-Null
		$process.WaitForExit()
		
		If($process.ExitCode -ne 0){
			$stderr = $process.StandardError.ReadToEnd()
			$output = "Exit code: $($process.ExitCode). Error: $stderr" 
		}
		Else{
			$output =  "Extract Succesful." 
		}

       
		return $output


    }



}





    