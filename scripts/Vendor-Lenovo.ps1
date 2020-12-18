####################################################################
# THIS CLASS IMPLEMENTS ALL METHODS THAT A DEVICE
# CONSTRUCTOR SHOULD HAVE
#################################################################### 


[System.Reflection.Assembly]::LoadFrom("$($PSScriptRoot)\..\assembly\lz4net.1.0.15.93\lib\net4-client\LZ4.dll") | Out-Null

$Script:InnoExtractExe = (Get-Item "$($PSScriptRoot)\..\resources\innoextract-1.9-windows\innoextract.exe").FullName

###################################################################
# -------------------------------------------------------
# *** DEPENDENCY ***
# -------------------------------------------------------
#
# This scripts requires: 
#
# --> Lz4Net Assembly to be imported (used to Decode LZ4) 
#     More info here: https://lz4.github.io/lz4/
# --> InnoExtract.exe used to extract Lenovo executable drivers
#     More info here: https://constexpr.org/innoextract
# --> 7z.exe used to decompress all other extractable archive type
#       
# 
###################################################################


Function Decode-WithLZ4 ($Content,$originalLength)
{
    #=====================================================================
    # Decompress 
    #/!\ It was a nightmare to find this ...
    #=====================================================================
  
    $Bytes =[Convert]::FromBase64String($Content)
    $OutArray = [LZ4.LZ4Codec]::Decode($Bytes,0, $Bytes.Length,$originalLength)
    $rawString  = [System.Text.Encoding]::UTF8.GetString($OutArray)

    return $rawString

}


###################################################################
# -------------------------------------------------------
# *** CLASS ***
# -------------------------------------------------------
###################################################################


Class Lenovo{


    Static hidden [String]$_vendorName = "Lenovo"
    hidden [Object[]] $_deviceCatalog
    hidden [Object[]] $_deviceImgCatalog  
	
	# Contructor
    Lenovo()
    {
        $this._deviceCatalog = [Lenovo]::GetDevicesCatalog()
        $this._deviceImgCatalog = $null
    }


    #########################################################################
    # Get all Data from Lenovo (Compressed)
    #########################################################################

    Static hidden [Object[]] GetDevicesCatalog()
    {
    

        # --------------------------------------------------------------------------------------------------------
        # return a list of object of type: 
        # Id          : LAPTOPS-AND-NETBOOKS/THINKPAD-X-SERIES-LAPTOPS/THINKPAD-X1-CARBON-8TH-GEN-TYPE-20U9-20UA/20UA
        # Brand       : TPG
        # Name        : X1 Carbon 8th Gen - (Type 20U9, 20UA) Laptop (ThinkPad) - Type 20UA
        # Image       : https://download.lenovo.com/images/ProdImageLaptops/x1carbon_g8.jpg
        # ProductGuid : EA49D52A-3FEA-4EF9-8F51-F45B3C2DDC8B
        # Type        : Product.MachineType
        # ParentID    : A88DE321-6C19-48EC-8FA0-122086945393
        # Popularity  : 0 
        # --------------------------------------------------------------------------------------------------------


        $result = Invoke-WebRequest -Uri "https://pcsupport.lenovo.com/us/en/api/v4/mse/getAllProducts?productId=" -Headers @{
        "Accept"="application/json, text/javascript, */*; q=0.01"
          "Referer"="https://pcsupport.lenovo.com/us/en/"
          "X-CSRF-Token"="2yukcKMb1CvgPuIK9t04C6"
          "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"
          "X-Requested-With"="XMLHttpRequest"
        }


        $JSON = ($result.Content | ConvertFrom-Json)
        $rawString = Decode-WithLZ4 -Content $JSON.content -originalLength $JSON.originLength 
        $jsonObject = ($rawString | ConvertFrom-Json)


        return $jsonObject

    }



    #########################################################################
    # Find Model Based on User input
    #########################################################################

    [Object[]]FindModel($userInputModel)
    {

        # --------------------------------------------------------------------------------------------------------
        # return an Array of object of type: 
		# Name                                      Guid                                 Path                                                                         Image                                                                
		# ----                                      ----                                 ----                                                                         -----                                                                
		# T480 (Type 20L5, 20L6) Laptop (ThinkPad)  41E433D7-D614-4607-BE53-F6FEC53A081B LAPTOPS-AND-NETBOOKS/THINKPAD-T-SERIES-LAPTOPS/THINKPAD-T480-TYPE-20L5-20L6  https://download.lenovo.com/images/ProdImageLaptops/thinkpad_t480.jpg
		# T480s (type 20L7, 20L8) Laptop (ThinkPad) 3F0D5186-DF09-471C-85C5-4FEC08004447 LAPTOPS-AND-NETBOOKS/THINKPAD-T-SERIES-LAPTOPS/THINKPAD-T480S-TYPE-20L7-20L8 https://download.lenovo.com/images/ProdImageLaptops/t460s.jpg        
        # --------------------------------------------------------------------------------------------------------

        $SearchResultFormatted = @()

		$userSearchResult = $this._deviceCatalog.Where({($_.Name -match $userInputModel) -and ($_.Type -eq "Product.SubSeries")})
	
		foreach($obj in $userSearchResult){
            $SearchResultFormatted += [PSCustomObject]@{
                Name=$obj.Name;
                Guid=$obj.ProductGuid;
                Path=$obj.Id;
                Image=$obj.Image
            } 
        }

        return $SearchResultFormatted




    }


    #########################################################################
    # Get Product URL
    #########################################################################

    Static hidden [string] GetModelHomepageURL($devicePath)
    {

        $Homepage = "https://pcsupport.lenovo.com/us/en/products/$($devicePath)"
        return $Homepage

    }



    #########################################################################
    # Get Json Data for a Lenovo Device form its GUID
    #########################################################################

    hidden [Object[]] GetModelWebResponse($modelGUID)
    {
    
        # return all drivers for a device model

        #  ==== For Download  =======
        $DownloadURL = "https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=$($modelGUID)"
        Write-Host $DownloadURL

        $SelectedModelwebReq = Invoke-WebRequest -Uri $DownloadURL -Headers @{
        "method"="GET"
          "authority"="pcsupport.lenovo.com"
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
          "if-none-match"="W/`"22be7-AUC0+yofTeyKmLtgRgLV1N2HppE`""
        }


        $SelectedModelWebResponse = ($SelectedModelwebReq.Content | ConvertFrom-Json)
    
        return $SelectedModelWebResponse

    }

	
	#########################################################################
    # Get All Supported OS
    #########################################################################

    hidden [Object[]]GetAllSupportedOS($webresponse)
    {
		
		$AllOSKeys = [Array]$webresponse.body.AllOperatingSystems
        # Duplicating to have format Name, Value
        $operatingSystemObj= $AllOSKeys | Foreach { [PSCustomObject]@{ Name = $_; Value = $_}}
		return $operatingSystemObj
	}
	

    #########################################################################
    # Load All Drivers to exploitable format
    #########################################################################

    hidden [Object[]]LoadDriversFromWebResponse($webresponse)
    {

        # --------------------------------------------------------------------------------------------------------
        # return a List of PsObject of type:
        # Title               : Integrated Camera Device Firmware (Lite-on/7SF102N2) for Windows 10 (64-bit) - ThinkPad
        # Category            : Camera and Card Reader
        # Class               : dl-category-camerareader
        # OperatingSystemKeys : {Windows 10 (64-bit)}
        # Files               : {@{IsSelected=False; ID=n2jlc04w; Name=Integrated Camera Device Firmware for Lite-on/7SF102N2; Size=2.1 MB; Type=EXE; Version=0025; 
        #                      URL=https://download.lenovo.com/pccbbs/mobiles/n2jlc04w.exe; Priority=Recommended; Date=21 avril 2020}}
        # --------------------------------------------------------------------------------------------------------

        $DownloadItemsRaw = ($webresponse.body.DownloadItems | Select-Object -Property Title,Date,Category,Files,OperatingSystemKeys)
        $DownloadItemsObj = [Collections.ArrayList]@()

        ForEach ($item in $DownloadItemsRaw){

            # Get the exe,zip only and the Title branch, no need of the readme
            [Array]$ExeFiles = $item.Files | Where-Object {($_.TypeString -notmatch "TXT")  }  
        
            $current = [PSCustomObject]@{
                Title=$item.Title;
                Category=$item.Category.Name;
                Class=$item.Category.Classify;
                OperatingSystemKeys=$item.OperatingSystemKeys;
                Files= [Array]($ExeFiles |  ForEach-Object {  
                    if($_){
                        [PSCustomObject]@{
						    IsSelected=$false;
                            ID=$_.Url.Split('/')[-1].Split('.')[0];
                            Name=$_.Name;
                            Size=$_.Size;
                            Type=$_.TypeString;
                            Version=$_.Version
                            URL=$_.URL;
                            Priority=$_.Priority;
                            Date=[DateTimeOffset]::FromUnixTimeMilliseconds($_.Date.Unix).ToString("dd MMMM yyyy")
                        }
                    }
                })
            }

            $DownloadItemsObj.Add($current) | Out-Null
        }

        return $DownloadItemsObj

    }

	
	#########################################################################
    # Prepare Drivers Download
    #########################################################################
	
    hidden [Object[]] PrepareDriversGroupDownload($selectedDrivers)
	{
        
        # 'Category' is like "Display and Video Graphic" so we take 'Class' instead which looks like 'dl-category-video'
        $GroupsByCategory = $selectedDrivers | Group-Object -Property Class
		$cat = $null

        $PreparedDownloadList = [Collections.ArrayList]@()

        foreach ($category in $GroupsByCategory){
        
            # Create category folder 
            $cat = ($category.Name).Split('-')[-1]
			
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
            $var = "Error:  $($_.Exception.Message) `n" 
        }
		Finally{
					
			$client.dispose()
		}
     
        return $var
    }
	

    #########################################################################
    # Extract All Lenovo Dirvers
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
		$pStartInfo.FileName = $Script:InnoExtractExe
		$pStartInfo.Arguments = """$file"" --extract --output-dir=""$folderPath"" --collisions=overwrite --progress=0 --silent --no-extract-unknown "
	
		$process = [System.Diagnostics.Process]::new()
		$process.StartInfo = $pStartInfo
		$process.Start() | Out-Null
		$process.WaitForExit()
		



		If($process.ExitCode -ne 0){
			$stderr = $process.StandardError.ReadToEnd()
			$output = "Exit code: $($process.ExitCode). Error: $stderr" 
		}
		Else{
			$output = "Extract Succesful." 

			try{

				# moving folder one level for path containing 'code$GetExtractPath$' with innoextract
				$TempGetExtractorFolder = "$($folderPath+'\code$GetExtractPath$')"
                Move-Item -Path "$TempGetExtractorFolder\*" -Destination $folderPath -ErrorAction Continue
                Remove-Item $TempGetExtractorFolder

			}
			Catch{
                Write-Host $($_.Exception.Message)
				$output = "Error:  $($_.Exception.Message)" 
			}

		}
		

        return $output

    }




    #########################################################################
    # Get CAB Content 
    #########################################################################

    [Object[]] GetCabDriversContent($urlCabReleaseNote){
        
        # --------------------------------------------------------------------------------------------------------
        # ReleaseID DeviceDescription                    VendorVersion 
        # --------- -----------------                    ------------- 
        # N10A902W  Realtek High Definition Audio Driver 6.0.1.7898    
        # GICR13WW  Realtek Integrated Camera Driver     6.2.9200.10252
        # GRLK02WW  Intel IO Driver                      1.1.253.0     
        # ...
        # --------------------------------------------------------------------------------------------------------
        

        #$urlCabReleaseNote = "https://download.lenovo.com/pccbbs/mobiles/tp_x1carbon_mt20a7-20a8_w1064_201611.txt"

        $cabReleaseNote = Invoke-WebRequest -Uri $urlCabReleaseNote -Headers @{
        "Pragma"="no-cache"
          "Cache-Control"="no-cache"
          "Upgrade-Insecure-Requests"="1"
          "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
          "Sec-Fetch-Site"="same-site"
          "Sec-Fetch-Mode"="navigate"
          "Sec-Fetch-User"="?1"
          "Sec-Fetch-Dest"="document"
          "Accept-Encoding"="gzip, deflate, br"
          "Accept-Language"="en-US,en;q=0.9"
          }


        $ReleaseNoteString = $cabReleaseNote.Content.Split("`n")

        $versionListRegion = $ReleaseNoteString.Where({$_ -match 'Version List'})
        $versionListIndex = $ReleaseNoteString.IndexOf($versionListRegion[0])
        $EndversionListRegion = $ReleaseNoteString.Where({$_ -match 'LIMITATIONS'})
        $EndversionListIndex = $ReleaseNoteString.IndexOf($EndversionListRegion[0])


        $TextOfInterest = $ReleaseNoteString[$versionListIndex..$($EndversionListIndex-2)]
        $BuildIDRegex = '\b(?=.*[0-9])(?=.*[A-Z])([A-Z0-9]){8}\b'

        $result = @()

        foreach ($elem in $TextOfInterest){
            $match = [regex]::Match($elem, $BuildIDRegex)
            if($match.Success){
                $result += [PScustomobject]@{
                    ReleaseID         = $match.Value;
                    DeviceDescription = $elem.Substring(0,$match.Index).Trim()
                    VendorVersion     = $elem.Substring($match.Index+8 ).Trim()
                }
            }
        }

        return $result
    
    }






}