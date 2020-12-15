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



# ----------------------------------------------------
# Operating System
# ----------------------------------------------------
 
$Script:HPOSCategoryWeb =[xml]@'
<select>
    <span class="530006069043305437166081915438460">Linux</span>
    <span class="792898937266030878164166465223921">Windows 10 (64-bit)</span>
    <span class="29481326718665025226218600797815">Windows 8.1 (64-bit)</span>
    <span class="460644864015473348621734632283354">Windows 7 (64-bit)</span>
</select>
'@




Class HP{

    
    Static hidden [String]$_vendorName = "Hewlett-Packard"
	hidden [Object[]] $_deviceCatalog 
    hidden [Object[]] $_deviceImgCatalog  
	
	# Contructor
    HP()
    {
        $this._deviceCatalog = [HP]::GetDevicesCatalog()
        $this._deviceImgCatalog = $null
    }

	
	
	#####################################################################
    # Get all Data from HP 
    #####################################################################
    
    Static hidden [Object[]] GetDevicesCatalog()
    {
        # they do not provide it but we can query it :D
		return $null
	}


    Static hidden [Object[]] GetDeviceImgCatalog($category)
    {
        
        $basehref="https://support.hp.com/wps/portal/pps/Home/product-home/"
        $accessToken = "!ut/p/z1/04_Sj9CPykssy0xPLMnMz0vMAfIjo8zifRw9Ddw9TAy8LYL9LAwcvc39w_wtnY0NDEz0w8EKnN0dPUzMfQwM3ANNnAw8zX39vV2DLIwNPM30o4jRb4ADOBoQpx-Pgij8xofrR4GV4PMBITMKckNDIwwyHQHSQWSH/"
        $ajaxUrlSDL = 'p0/IZ7_3054ICK0KGTE30AQO5O3KA3G83=CZ6_LAI0GH40K8SN80AK7OVO9C3004=NJgetNextProductCategories=/'
        $uri = [System.String]::Concat($basehref,$accessToken,$ajaxUrlSDL)

        $categoryCatalog =  Invoke-WebRequest -Uri "$uri" `
        -Method "POST" `
        -Headers @{
        "method"="POST"
            "authority"="support.hp.com"
            "scheme"="https"
            "pragma"="no-cache"
            "cache-control"="no-cache"
            "accept"="*/*"
            "x-requested-with"="XMLHttpRequest"
            "origin"="https://support.hp.com"
            "sec-fetch-site"="same-origin"
            "sec-fetch-mode"="cors"
            "sec-fetch-dest"="empty"
            "accept-encoding"="gzip, deflate, br"
            "accept-language"="en-US,en;q=0.9"
            } `
        -ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
        -Body "categoryId=$($category)&cc=us&lc=en&firstLevel=false&callForHistoricProduct=false&driver=false"


        #$productCatalogObj = ($categoryCatalog.Content | ConvertFrom-Json).tmsResponse.fieldList | Select-Object -Property seoLabel,uid,imageUrl
        $productCatalogObj = $($categoryCatalog.Content | ConvertFrom-Json).tmsResponse.fieldList | Select-Object -Property uid,imageUrl
        

        return $productCatalogObj

    }
	
	
	#########################################################################
    # Find Model Based on User input
    #########################################################################

    [Object[]]FindModel($userInputModel)
    {
        # --------------------------------------------------------------------------------------------------------
        # return an Array of object of type: 
        # Name                                          Guid                            		 Path                                     Image                                                                   
        # ----                                          ----                            		 ----                                     -----                                                                   
        # HP EliteBook 820 G3 Notebook PC               hp-elitebook-820-g3-notebook-pc/7815289  hp-elitebook-820-g3-notebook-pc/7815289  https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04...
        # HP EliteBook 820 G4 Notebook PC               hp-elitebook-820-g4-notebook-pc/11122281 hp-elitebook-820-g4-notebook-pc/11122281 https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04...       
	   # --------------------------------------------------------------------------------------------------------


        $escapedChar = [System.Uri]::EscapeDataString($userInputModel)
		$uri = "https://support.hp.com/typeahead?q=$($escapedChar)&resultLimit=10&store=tmsstore&languageCode=en&filters=class:(pm_series_value%5E1.1%20OR%20pm_name_value%20OR%20pm_number_value)&printFields=tmspmnamevalue,title,body,class,productid,seofriendlyname,shortestnavigationpath"
		
        $jsonResult = Invoke-WebRequest -Uri $uri -Headers @{
        "method"="GET"
            "authority"="support.hp.com"
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

        # --------------------------------------------------------------------------------------------------------
        # jsonMatches content type: 
        # terms                  : HP EliteDesk 880 G1 Tower PC,880g1,880g2,88o 88x,elite desk,elitedesk880g1,g 1 hpg1 hp1,hp880,hp880g1,hp880g1 
        #                          880g1,hp880serie,hpbrand,hpelite,hpelitedesk,hpelitedesk880g1towerpc,twr
		# name                   : HP EliteDesk 880 G1 Tower PC
		# pmClass                : pm_series_value
		# childnodes             : 5399301|5399303|5399305|
		# seoFriendlyName        : hp-elitedesk-880-g1-tower-pc
		# shortestNavigationPath : 361645196193472854978928808138960|218999353636529622426797829401137|225219926964176542913212298878149|5399300|
		# matchScore             : 8,246627
		# productId              : 5399300
        # --------------------------------------------------------------------------------------------------------
        $SearchResultFormatted = @()

        $jsonMatches = $($jsonResult.Content | ConvertFrom-Json).Matches
        


        $basehref="https://support.hp.com/wps/portal/pps/Home/product-home/"
        $accessToken = "!ut/p/z1/04_Sj9CPykssy0xPLMnMz0vMAfIjo8zifRw9Ddw9TAy8LYL9LAwcvc39w_wtnY0NDEz0w8EKnN0dPUzMfQwM3ANNnAw8zX39vV2DLIwNPM30o4jRb4ADOBoQpx-Pgij8xofrR4GV4PMBITMKckNDIwwyHQHSQWSH/"
        $ajaxUrlSDL = 'p0/IZ7_3054ICK0KGTE30AQO5O3KA3G83=CZ6_LAI0GH40K8SN80AK7OVO9C3004=NJgetNextProductCategories=/'
        $uri = [System.String]::Concat($basehref,$accessToken,$ajaxUrlSDL)
        

        foreach($obj in $jsonMatches){
            
               $SearchResultFormatted += [PSCustomObject]@{
                    Name=$obj.name;
                    Guid="$($obj.seoFriendlyName)/$($obj.productId)";
                    Path="$($obj.seoFriendlyName)/$($obj.productId)";
                    Image=$( 
                        $shtNavPath = $obj.shortestNavigationPath.Split('|')

                        if($shtNavPath[-3].length -lt 30){
                            # for sub model
                            $uid = $shtNavPath[-3]
                            $categoryID = $shtNavPath[-4]
                        }else{
                            $uid = $shtNavPath[-2]
                            $categoryID = $shtNavPath[-3]
                        }


                        $categoryCatalog =  Invoke-WebRequest -Uri "$uri" `
                        -Method "POST" -Headers @{
                        "method"="POST"
                            "authority"="support.hp.com"
                            "scheme"="https"
                            "pragma"="no-cache"
                            "cache-control"="no-cache"
                            "accept"="*/*"
                            "x-requested-with"="XMLHttpRequest"
                            "origin"="https://support.hp.com"
                            "sec-fetch-site"="same-origin"
                            "sec-fetch-mode"="cors"
                            "sec-fetch-dest"="empty"
                            "accept-encoding"="gzip, deflate, br"
                            "accept-language"="en-US,en;q=0.9"
                            } `
                        -ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
                        -Body "categoryId=$($categoryID)&cc=us&lc=en&firstLevel=false&callForHistoricProduct=false&driver=false"
                        $obj = $(($categoryCatalog.Content | ConvertFrom-Json).tmsResponse.fieldList).Where({ $_.uid -eq $uid})

                        
                        # **** delegate don't like this inside runspace :'( ***
                        # $obj = $([HP]::GetDeviceImgCatalog($shtNavPath[-3])).Where({ $_.uid -eq $shtNavPath[-2]})

                        if($obj){
                            $obj.imageUrl
                        }else{
                            'https://support.hp.com/static/hp-support-site-console/resources/images/tms/tms-fallback.png'
                        }
                    )
                    
                }
                   
        }

        return $SearchResultFormatted

	}
	
	
	#########################################################################
    # Get Product URL
    #########################################################################

    Static hidden [string] GetModelHomepageURL($devicePath)
    {
        $Homepage = "https://support.hp.com/us-en/drivers/selfservice/$devicePath"
		return $Homepage
    }
	
	
    #########################################################################
    # Get Json Data for a HP Device from its GUID
    #########################################################################

    hidden [Object[]] GetModelWebResponse($modelGUID)
    {

        # --------------------------------------------------------------------------------------------------------
        # softwareDriversList : {@{latestVersionDriver=; previousVersionOfDriversList=System.Object[]; associatedContentList=System.Object[]; publicationId=COL53873; layoutType=default; subID=1; 
        #              submittalTypeID=1}, @{latestVersionDriver=; previousVersionOfDriversList=System.Object[]; associatedContentList=System.Object[]; publicationId=COL45700; 
        #              layoutType=default; subID=1; submittalTypeID=1}}
        # accordianName       : Software-Multimedia
        # id                  : 251408257123252905713957627306395
        # tmsName             : Software
        # severityWeight      : 3
        # typeDriver          : False
        # --------------------------------------------------------------------------------------------------------

        # Get infitial informations
        $obj = $modelGUID.Split('/')
        $productSeriesName = $obj[0]
        $productSeriesOid  = $obj[1]

        # query for the model
        $basehref="https://support.hp.com/wps/portal/pps/Home/SWDSelfServiceStep/!ut/p/z1/04_Sj9CPykssy0xPLMnMz0vMAfIjo8zifQ08DYy83A28LcK8TA0cHR39jN08gwwNjAz0w8EKnN0dPUzMfQwM3ANNnAw8zX39vV2DLIwNPM30o4jRb4ADOBoQpx-Pgij8xofrR4GV4PMBITMKckNDIwwyHQHZipEy/"
        $ajaxUrlSDL = 'p0/IZ7_M0I02JG0KGVO00AUBO4GT60082=CZ6_M0I02JG0K8VJ50AAAN3FIR1020=NJgetSoftwareDriverDetails=/'

        #$unescapedsessionData = '{"urlLanguage":"en","language":"en","osId":"792898937266030878164166465223921","countryCode":"us","productSeriesOid":"7343192","productSeriesName":"hp-elitebook-820-g2-notebook-pc"}'
        $unescapedsessionData = "{""urlLanguage"":""en"",""language"":""en"",""osId"":""792898937266030878164166465223921"",""countryCode"":""us"",""productSeriesOid"":""$($productSeriesOid)"",""productSeriesName"":""$($productSeriesName)""}"
 
        $sessionData = [Uri]::EscapeDataString($unescapedsessionData)

        $uri = [System.String]::Concat($basehref,$ajaxUrlSDL)
        
        $results = Invoke-WebRequest -Uri "$uri" `
        -Method "POST" `
        -Headers @{
        "method"="POST"
          "authority"="support.hp.com"
          "scheme"="https"
          "accept"="application/json, text/javascript, */*; q=0.01"
          "x-requested-with"="XMLHttpRequest"
          "origin"="https://support.hp.com"
          "sec-fetch-site"="same-origin"
          "sec-fetch-mode"="cors"
          "sec-fetch-dest"="empty"
          "accept-encoding"="gzip, deflate, br"
          "accept-language"="en-US,en;q=0.9"
         } `
        -ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
        -Body "requestJson=$sessionData"


        $json = $results.Content | ConvertFrom-Json
        $SelectedModelWebResponse = $json.swdJson | ConvertFrom-Json

		return $SelectedModelWebResponse


	}
	
	#########################################################################
    # Get All Supported OS
    #########################################################################

    hidden [Object[]]GetAllSupportedOS($webresponse)
    {
		
		# Hard Coded until I find Dell Table
        $operatingSystemObj= $Script:HPOSCategoryWeb.select.span | Foreach { [PSCustomObject]@{ Name = $_.'#text'.Trim() ; Value =  $_.'#text'.Trim() ; Tag = $_.class }}
		return $operatingSystemObj

	}
	
	#########################################################################
    # Load All Drivers to exploitable format
    #########################################################################

    hidden [Object[]]LoadDriversFromWebResponse($webresponse)
    {

        $DownloadItemsObj = [Collections.ArrayList]@()

        ForEach ($item in $webresponse){


            [Array]$latestVersionDrivers = $item.softwareDriversList.latestVersionDriver 
            
            Foreach ($latestVersionDriver in $latestVersionDrivers){
                $current = [PSCustomObject]@{
                    Title=$latestVersionDriver.title;
                    Category=$item.accordianName;
                    Class=$item.tmsName;
                    OperatingSystemKeys=[Array]("Windows 10 (64-bit)");
                    Files= [Array]( $latestVersionDriver | ForEach-Object { 
                        if($_.productSoftwareFileList){    
                            [PSCustomObject]@{
						        IsSelected=$false;
                                ID=$latestVersionDriver.productSoftwareFileList.fileName.Split('.')[0];
                                Name=$latestVersionDriver.title;
                                Size=$latestVersionDriver.fileSize;
                                Type=$latestVersionDriver.productSoftwareFileList.fileType;
                                Version=$latestVersionDriver.Version;
                                URL=$latestVersionDriver.productSoftwareFileList.fileUrl;
                                Priority=$latestVersionDriver.severityFlag;
                                Date=$latestVersionDriver.releaseDateString
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
               "Docks-Firmware And Driver"      			{$cat = "Docks"; break}
               "Driver-Audio"                  				{$cat = "Audio"; break}
               "Driver-Chipset"             				{$cat = "Chipset"; break}
               "Driver-Graphics"       						{$cat = "Video"; break}
               "Driver-Keyboard, Mouse And Input Devices"   {$cat = "Input"; break}
               "Driver-Network"   							{$cat = "Network"; break}
               "Driver-Storage"   							{$cat = "Storage"; break}
               "Operating System-Enhancements and QFEs"   	{$cat = "OS-Enhance"; break}
               default                            			{$cat = $category.Name ; break}
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



