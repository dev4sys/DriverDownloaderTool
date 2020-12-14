#########################################################################
# Author:  Kevin RAHETILAHY                                             #
# E-mail: kevin.rhtl@gmail.com                                          #
# Blog: dev4sys.com                                                     #
#########################################################################


#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\ControlzEx.4.4.0\lib\net45\ControlzEx.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.2.3.4\lib\net46\MahApps.Metro.dll")      | out-null  
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.Material.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.Core.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\Microsoft.Xaml.Behaviors.Wpf.1.1.19\lib\net45\Microsoft.Xaml.Behaviors.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\Dev4Sys.Converter.1.0\Dev4Sys.Converter.dll") | out-null


#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= $PSScriptRoot

Function Load-Xaml{
    
	Param(
		$filename
	)
	
    $XamlLoader=[System.Xml.XmlDocument]::new()
    $XamlLoader.Load($filename)
	
	$reader = [System.Xml.XmlNodeReader]::new($XamlLoader)
	$objXaml = [Windows.Markup.XamlReader]::Load($reader)
	
    return $objXaml
}


$syncHash = [hashtable]::Synchronized(@{})
$syncHash.PathPanel = $PSScriptRoot




$viewFolder = $syncHash.PathPanel  +"\views"

$syncHash.Form = Load-Xaml($syncHash.PathPanel +"\form.xaml")


#########################################################################
#                          VIEWS                                        #
#########################################################################

#******************* Target View  *****************



$syncHash.MainView     = $syncHash.Form.FindName("MainContentControl") 


#******************* Load Other Views  *****************
$MainXaml	    = Load-Xaml($viewFolder+"\Main.xaml")


$DriversView   = $MainXaml.FindName("DriversView") 
$DownloadView  = $MainXaml.FindName("DownloadView")
$ExtractView   = $MainXaml.FindName("ExtractView") 
$SettingsView  = $MainXaml.FindName("SettingsView") 



$DriversXaml	= Load-Xaml($viewFolder+"\Drivers.xaml")
$DownloadXaml 	= Load-Xaml($viewFolder+"\Download.xaml")
$ExtractXaml 	= Load-Xaml($viewFolder+"\Extract.xaml")
$SettingsXaml 	= Load-Xaml($viewFolder+"\Settings.xaml")



#$syncHash.MainView.AddChild($MainXaml) | Out-Null   

$DriversView.Children.Add($DriversXaml)    | Out-Null
$DownloadView.Children.Add($DownloadXaml)  | Out-Null    
$ExtractView.Children.Add($ExtractXaml)    | Out-Null      
$SettingsView.Children.Add($SettingsXaml)  | Out-Null




#########################################################################
#                        Load Control item                              #
#########################################################################

$syncHash.HamburgerMenuControl = $MainXaml.FindName("HamburgerMenuControl")

$syncHash.ResultSearchGrid = $MainXaml.FindName("ResultSearch")

$syncHash.Overlay = $syncHash.Form.FindName("Overlay")

$syncHash.SearchBarBtn     = $syncHash.Form.FindName("searchbarbtn")
$syncHash.modelInput       = $syncHash.Form.FindName("searchbar")
$syncHash.ProviderFlipView = $syncHash.Form.FindName("ProviderList") 

# Drivers Pane
$syncHash.Datagrid   = $DriversXaml.FindName("Datagrid")
$syncHash.OSComboBox = $DriversXaml.FindName("OSComboBox")


# Download Pane
$DonwloadBtn             = $DownloadXaml.FindName("DonwloadBtn")
$FolderDownloadBrowseBtn = $DownloadXaml.FindName("FolderDownloadBrowseBtn")

$ViewSelectedBtn         = $DownloadXaml.FindName("ViewSelectedBtn")
$syncHash.DonwloadProgress        = $DownloadXaml.FindName("DonwloadProgress")
$syncHash.DownloadOutput          = $DownloadXaml.FindName("DownloadOutput")
$syncHash.DriversSelectedDatagrid = $DownloadXaml.FindName("DriversSelectedDatagrid")

$syncHash.DownloadProjectPath     = $DownloadXaml.FindName("DownloadProjectPath")


# Extract Pane 
$ExtractBtn               = $ExtractXaml.FindName("ExtractBtn")
$FolderExtractBrowseBtn   = $ExtractXaml.FindName("FolderExtractBrowseBtn")

$syncHash.ExtractPgBar      = $ExtractXaml.FindName("ExtractProgressBar")
$syncHash.ExtractOutput     = $ExtractXaml.FindName("ExtractOutput")
$syncHash.ExtractedDatagrid = $ExtractXaml.FindName("ExtractedDatagrid")

$syncHash.ExtractProjectPath  = $ExtractXaml.FindName("ExtractProjectPath")


#########################################################################
#                        LOAD VENDOR                                    #
#########################################################################

$syncHash.FirstInitialization = $true

."$($syncHash.PathPanel)\scripts\Vendor-Lenovo.ps1"
."$($syncHash.PathPanel)\scripts\Vendor-Dell.ps1"
."$($syncHash.PathPanel)\scripts\Vendor-HP.ps1"

# Contains All Datas for the current selected Model
$Script:VarAllDriversForModel = $null



#########################################################################
#                    Dialog Settings                                    #
#########################################################################

$script:okOnly  = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::Affirmative
$script:settings = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
$script:settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme

Function Show-WarningMessage{
    
    Param(
        $Message
    )
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($syncHash.Form,"Driver Downloader",$Message,$script:okOnly, $script:settings)

}

#########################################################################
#                        Event                                          #
#########################################################################



$syncHash.ProviderFlipView.Add_SelectionChanged({
    
    $syncHash.CurrentVendor = $syncHash.ProviderFlipView.SelectedItem.DataContext


})




$syncHash.ProgressRing = $syncHash.Form.FindName('ProgressRing')

 
 $navigationWindow = [MahApps.Metro.Controls.MetroNavigationWindow]::new()


if($syncHash.CurrentVendor -eq "Lenovo"){
    $syncHash.SelectedVendor = [Lenovo]::new()
}
elseif($syncHash.CurrentVendor -eq "Dell"){
    $syncHash.SelectedVendor = [Dell]::new()
}
elseif($syncHash.CurrentVendor -eq "HP"){
    $syncHash.SelectedVendor = [HP]::new()
}else{
  #  return
}

$syncHash.SelectedVendor = [Lenovo]::new()


$syncHash.SearchBarBtn.Add_Click({



    # Create a datacontext for the textbox and set it
    $DataContext = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
    $IsActive = $true
    $searchResult = $null
    $DataContext.Add($IsActive)
    $DataContext.Add($searchResult)
    $syncHash.Form.DataContext = $DataContext

    # Create and set a binding on the Progressring object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[0]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ProgressRing,[MahApps.Metro.Controls.ProgressRing]::IsActiveProperty, $Binding)

    # Create and set a binding on the ResultSearch Datagrid object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[1]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ResultSearchGrid,[System.Windows.Controls.DataGrid]::ItemsSourceProperty, $Binding)


    If($syncHash.modelInput.Text.Length -gt 2){
        
        $syncHash.UserInput = $syncHash.modelInput.Text   

        $syncHash.Overlay.Visibility = "Visible"
        $syncHash.ProgressRing.IsActive = $true

        $Runspace = [runspacefactory]::CreateRunspace() 
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
    
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncVar",$syncHash) 

        $PowerShell = [PowerShell]::Create()
        $PowerShell.Runspace = $Runspace


        #================================================
        #=         BEGIN runspace scriptblock           =
        #================================================

        $PowerShell.AddScript({
            
            Param (
                [System.Object]$Provider,
                [System.Collections.ObjectModel.ObservableCollection[Object]]$DataContext
            )

            #Wait-Debugger

            
            $DataContext[1] = $Provider.FindModel($syncVar.UserInput)
            $DataContext[0] = $false

        })

        $PowerShell.AddArgument([System.Object]$syncHash.SelectedVendor)
        $PowerShell.AddArgument([System.Collections.ObjectModel.ObservableCollection[Object]]$DataContext)

        #================================================
        #=           END runspace scriptblock           =
        #================================================

        #start runspace and save details about runspace for later use
	    $syncHash.PoshRunspace  = $PowerShell 
        $SyncHash.AsyncObject = $PowerShell.BeginInvoke()


        #================================================
        #=       Section Timer to Close runspace        =
        #================================================

	        		
	    $updateBlock = {

            If ($SyncHash.AsyncObject.isCompleted)
		    {
                $syncHash.timer.Stop()


                if($syncHash.FirstInitialization -eq $true){

                    $syncHash.ProviderFlipView.Visibility = "Collapsed"
                    $syncHash.Form.Content.Children[1].RowDefinitions[0].Height = 100
                    $syncHash.Form.Content.Children[1].RowDefinitions[1].Height = '*'
                    $syncHash.MainView.Content = $MainXaml
                    $syncHash.FirstInitialization = $false

                }
                $syncHash.Overlay.Visibility = "Collapsed"
			    $syncHash.PoshRunspace.EndInvoke($SyncHash.AsyncObject)
			    $syncHash.PoshRunspace.runspace.close()
			    $syncHash.PoshRunspace.runspace.dispose()
                
		    }
          
	    }

	    $syncHash.timer = [System.Windows.Threading.DispatcherTimer]::new()

	    # Which will fire every 500 millisecond        
	    $syncHash.timer.Interval = [TimeSpan]"0:0:0.5"

	    # And will invoke the $updateBlock method         
	    $syncHash.timer.Add_Tick($updateBlock)

	    # Now start the timer running        
	    $syncHash.timer.Start()


        #================================================
	    #End Timer Section
        #================================================
   
        # ************************************
        # TO DO Databing this
        #if($searchResult.Count -eq 0){
        #    Show-WarningMessage -Message "No result found for $($syncHash.modelInput.Text)."
        #}
        # *************************************

    }
    Else
    {
        Show-WarningMessage -Message "Please specify more than 2 characters."
    }



    
    


})



[System.Windows.RoutedEventHandler]$EventonDataGrid = {
    

    # GET THE NAME OF EVENT SOURCE
    $button =  $_.OriginalSource.Name

    # CHOOSE THE CORRESPONDING ACTION
    If ( $button -match "loadModel" ){
         
        Write-Host $syncHash.ResultSearchGrid.CurrentItem.Name
        Write-Host $syncHash.ResultSearchGrid.CurrentItem.Guid
		
        $syncHash.CurrentModel = $syncHash.ResultSearchGrid.CurrentItem.Name

        $wbrsp =  $syncHash.SelectedVendor.GetModelWebResponse($syncHash.ResultSearchGrid.CurrentItem.Guid)
        $OSCatalog = $syncHash.SelectedVendor.GetAllSupportedOS($wbrsp)
        $DriversModeldatas = $syncHash.SelectedVendor.LoadDriversFromWebResponse($wbrsp)


        if($DriversModeldatas){
            
             $Script:VarAllDriversForModel = $DriversModeldatas

        }else{
            
            Show-WarningMessage -Message "Not a know computer model (Maybe a printer :D ...)"

        }

        $syncHash.OSComboBox.ItemsSource = $OSCatalog

      # Get Windows 10 Pattern
       $OSWin64Value = ($OSCatalog | ?{$_.Name -match 'Windows 10..64'})
       $syncHash.OSComboBox.SelectedValue = $OSWin64Value

    }

}
$syncHash.ResultSearchGrid.AddHandler([System.Windows.Controls.Button]::ClickEvent, $EventonDataGrid)



#########################################################################
#                        DRIVERS VIEW EVENTS                            #
#########################################################################


$syncHash.OSComboBox.Add_SelectionChanged({

    $OSType = $syncHash.OSComboBox.SelectedItem.Value
     

    # For all Operating System
    # $collectionViewSource = [System.Windows.Data.CollectionViewSource]::GetDefaultView($DriversModeldatas)
    # $DriversModelDatasForOsType = $DriversModelDatas | Where-Object {($_.OperatingSystemKeys -contains "WT64A") -or ($_.OperatingSystemKeys -contains "BIOSA") } 


    $DriversModelDatasForOsType = [Array]($Script:VarAllDriversForModel | Where-Object {($_.OperatingSystemKeys -contains $OSType )} )
    
    if($DriversModelDatasForOsType){

        $PropertyGroupDescription = [System.Windows.Data.PropertyGroupDescription]::new()
        $PropertyGroupDescription.PropertyName = "Category"

        $collectionViewSource = [System.Windows.Data.CollectionViewSource]::GetDefaultView($DriversModelDatasForOsType)
        $collectionViewSource.GroupDescriptions.Add($PropertyGroupDescription)
        
        $syncHash.Datagrid.DataContext = $collectionViewSource


    }else{
    
        $syncHash.Datagrid.DataContext = $null
    
    }


})


# #################################################
# View list of selected driver
$ViewSelectedBtn.Add_Click({
    
    $ToBeDownLoadedRaw = $Script:VarAllDriversForModel | ?{$_.Files.IsSelected -eq $true}
    $syncHash.ToBeDownLoaded = $syncHash.SelectedVendor.PrepareDriversGroupDownload($ToBeDownLoadedRaw)
    $syncHash.DriversSelectedDatagrid.ItemsSource = $syncHash.ToBeDownLoaded

})



$DonwloadBtn.Add_Click({

	
	$syncHash.dwnPath = $syncHash.DownloadProjectPath.Text
	
    # Check if not empty 
    if(!$syncHash.DownloadProjectPath.Text){
        Show-WarningMessage -Message "Please select an output folder!"
        return
    }

    # check if valid Path
    if(!(Test-Path $syncHash.DownloadProjectPath.Text)){
        Show-WarningMessage -Message "Please select valid folder!"
        return
    }

	$syncHash.DonwloadProgress.IsIndeterminate = $true
    $syncHash.DownloadOutput.Text = [System.Environment]::NewLine
   

    $Runspace = [runspacefactory]::CreateRunspace()
    $Runspace.ApartmentState = "STA"
    $Runspace.ThreadOptions = "ReuseThread"
    
    $Runspace.Open()
    $Runspace.SessionStateProxy.SetVariable("syncVar",$syncHash) 


    $PowerShell = [PowerShell]::Create()
    $PowerShell.Runspace = $Runspace


    #================================================
    #=         BEGIN runspace scriptblock           =
    #================================================


    $PowerShell.AddScript({

            Param ([System.Object]$Provider)


            # Start a timer
            $Stopwatch = [System.Diagnostics.Stopwatch]::new()
            $Stopwatch.Start()


            foreach ($driver in $syncVar.ToBeDownLoaded){
            
                $folderPathGroup    = "$($syncVar.dwnPath)\$($driver.DownloadGroup)"
                $driverTargetFolder = "$folderPathGroup\$($driver.DownLoadID)"

                # Create category folder if not exist
                if(!(Test-Path $folderPathGroup)){
                    New-Item -ItemType Directory -Path "$folderPathGroup" | Out-Null
                }

                # Create Folder ID if not exist
                New-Item -ItemType Directory -Path "$driverTargetFolder" | Out-Null


                $syncVar.DownloadOutput.Dispatcher.Invoke([action]{
                    $syncVar.DownloadOutput.Text += "Downloading: $($driver.DownloadURL) `n " 
                })

           
                $result = $Provider.DownloadDriver($driver.DownloadURL , $driverTargetFolder )
            
                $syncVar.DownloadOutput.Dispatcher.Invoke([action]{
                    $syncVar.DownloadOutput.Text += "=> Status: $result `n " 
                })
        
            }

            # Wait-Debugger

            $syncVar.DonwloadProgress.Dispatcher.Invoke([action]{
			    $syncVar.DonwloadProgress.IsIndeterminate = $false
		    })


            $Stopwatch.Stop()

            $syncVar.DownloadOutput.Dispatcher.Invoke([action]{
                $syncVar.DownloadOutput.Text += "Completed in $($Stopwatch.Elapsed.Minutes) minutes and $($Stopwatch.Elapsed.Seconds) seconds. `n" 
            })

        

        })
    
         
    $PowerShell.AddArgument([System.Object]$syncHash.SelectedVendor)


    #================================================
    #=           END runspace scriptblock           =
    #================================================

	#start runspace and save details about runspace for later use
	$syncHash.PoshRunspace  = $PowerShell 
    $SyncHash.AsyncObject = $PowerShell.BeginInvoke()

    $syncHash.DownloadOutput.Text += "Opening Runspace for download operation ... `n"
    $syncHash.DownloadOutput.Text += "============================================= `n `n"

    #================================================
    #=       Section Timer to Close runspace        =
    #================================================

		
	$updateBlock = {

            If ($SyncHash.AsyncObject.isCompleted)
		    {
                $syncHash.timer.Stop()
                $syncHash.DownloadOutput.Text +="`n============================================= `n"
                $syncHash.DownloadOutput.Text += "Closing Runspace `n "
			    $syncHash.PoshRunspace.EndInvoke($SyncHash.AsyncObject)
			    $syncHash.PoshRunspace.runspace.close()
			    $syncHash.PoshRunspace.runspace.dispose()
                
		    }
          
	    }

	$syncHash.timer = [System.Windows.Threading.DispatcherTimer]::new()

	# Which will fire every second        
	$syncHash.timer.Interval = [TimeSpan]"0:0:1"

	# And will invoke the $updateBlock method         
	$syncHash.timer.Add_Tick($updateBlock)

	# Now start the timer running        
	$syncHash.timer.Start()

	if ($syncHash.timer.IsEnabled)
	{
		Write-Host 'Download timer started'
	}

    #================================================
	#End Timer Section
    #================================================
   

})



$ExtractBtn.Add_Click({

	
	$syncHash.dwnPath = $syncHash.DownloadProjectPath.Text
	$syncHash.ExtractDestinationPath = $syncHash.ExtractProjectPath.Text
	
    
    # Check if there is a source
    if(!$syncHash.dwnPath){
        Show-WarningMessage -Message "Ooopps!! Looks like there is no Download folder to extract.`n Please Provide one in Download pane."
        return
    }

    # Check if not empty 
    if(!$syncHash.ExtractProjectPath.Text){
        Show-WarningMessage -Message "Please select an output folder!"
        return
    }

    # check if valid Path
    if(!(Test-Path $syncHash.ExtractProjectPath.Text)){
        Show-WarningMessage -Message "Please select valid folder!"
        return
    }



    $syncHash.ExtractPgBar.IsIndeterminate = $true
    $syncHash.ExtractOutput.Text = [System.Environment]::NewLine
   

    $Runspace = [runspacefactory]::CreateRunspace()
    $Runspace.ApartmentState = "STA"
    $Runspace.ThreadOptions = "ReuseThread"
    
    $Runspace.Open()
    $Runspace.SessionStateProxy.SetVariable("syncVar",$syncHash) 


    $PowerShell = [PowerShell]::Create()
    $PowerShell.Runspace = $Runspace


    #================================================
    #=         BEGIN runspace scriptblock           =
    #================================================

    
    $syncHash.CurrentExtractPath = "$($syncHash.ExtractDestinationPath)\$($syncHash.CurrentModel)" 
    New-Item -ItemType Directory $syncHash.CurrentExtractPath


    $PowerShell.AddScript({

        Param ([System.Object]$Provider)


        # Start a timer
        $Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $Stopwatch.Start()


        # get All item from donwload folder
        $downloadFolder = Get-ChildItem $syncVar.dwnPath

	    foreach ($catFolder in $downloadFolder )
	    {

            # create the structure in destination folder
            $categoryFolder = "$($syncVar.CurrentExtractPath)\$($catFolder.Name)" 
            New-Item -ItemType Directory -Path $categoryFolder | Out-Null

            Write-Host $categoryFolder

		    $driverIDFolders = [Array](Get-ChildItem $catFolder.FullName)
		    
		    $driverIDFolders | ForEach-Object {
			
                # Get the file inside Category\ID folder [There should be only one file inside each ID folder !!]
                $file = Get-ChildItem $_.FullName

                $syncVar.ExtractOutput.Dispatcher.Invoke([action]{
                    $syncVar.ExtractOutput.Text += "Extracting file: $($file.FullName)  `n  "
                })

                $targetIDFolder = "$categoryFolder\$($_.Name)" 
                New-Item -ItemType Directory -Path $targetIDFolder | Out-Null

			    #$result = $Provider.ExtractDriver( $file.FullName , $_.FullName )
                $result = $Provider.ExtractDriver( $file.FullName , $targetIDFolder )
			
                $syncVar.ExtractOutput.Dispatcher.Invoke([action]{
                    $syncVar.ExtractOutput.Text += "=> Status: $result `n "
                })

		    }
		
	    }
	
        # Wait-Debugger

        $syncVar.ExtractPgBar.Dispatcher.Invoke([action]{
			$syncVar.ExtractPgBar.IsIndeterminate = $false
		})


        $Stopwatch.Stop()

        $syncVar.ExtractOutput.Dispatcher.Invoke([action]{
            $syncVar.ExtractOutput.Text += "Completed in $($Stopwatch.Elapsed.Minutes) minutes and $($Stopwatch.Elapsed.Seconds) seconds." + [System.Environment]::NewLine
        })

        

    })
                 
    $PowerShell.AddArgument([System.Object]$syncHash.SelectedVendor)


    #================================================
    #=           END runspace scriptblock           =
    #================================================

	#start runspace and save details about runspace for later use
	$syncHash.PoshRunspace  = $PowerShell 
    $SyncHash.AsyncObject = $PowerShell.BeginInvoke()

    $syncHash.ExtractOutput.Text += "Opening Runspace for Extract operation ... `n"
    $syncHash.ExtractOutput.Text += "============================================= `n `n"

    #================================================
    #=       Section Timer to Close runspace        =
    #================================================

		
	$updateBlock = {

        If ($SyncHash.AsyncObject.isCompleted)
		{
            $syncHash.timer.Stop()
            $syncHash.ExtractOutput.Text +="`n============================================= `n"
            $syncHash.ExtractOutput.Text += "Closing Runspace `n "
			$syncHash.PoshRunspace.EndInvoke($SyncHash.AsyncObject)
			$syncHash.PoshRunspace.runspace.close()
			$syncHash.PoshRunspace.runspace.dispose()
                
		}
          
	}

	$syncHash.timer = [System.Windows.Threading.DispatcherTimer]::new()

	# Which will fire every second        
	$syncHash.timer.Interval = [TimeSpan]"0:0:1"

	# And will invoke the $updateBlock method         
	$syncHash.timer.Add_Tick($updateBlock)

	# Now start the timer running        
	$syncHash.timer.Start()

	if ($syncHash.timer.IsEnabled)
	{
		Write-Host 'Extract timer started'
	}

    #================================================
	#End Timer Section
    #================================================
   


    # Enter ISE Host
    #Get-PSHostProcessInfo | Where-Object {$_.ProcessName -eq 'powershell_ise'} | Enter-PSHostProcess

    #Enter the runspace which is waiting for a debugger
    #Get-Runspace | Where-Object {$_.Debugger.InBreakpoint -eq $true} | Debug-Runspace

    #Get-Runspace | Where-Object { $_.Id -ne 1 } | ForEach-Object { $_.closeasync() }
    #Get-Runspace | Where-Object { $_.State -eq 'Closed' } | ForEach-Object { $_.dispose() }



})




#########################################################################
# 		Extract Folder Browser 								²			#
$FolderExtractBrowseBtn.Add_Click({
	
	
	$inputUserFolder = Get-FolderDialog("Select Extract folder")
    $syncHash.ExtractProjectPath.Text = $inputUserFolder
    
	
})


#########################################################################
# 		Donwload Folder Borwser 										#
$FolderDownloadBrowseBtn.Add_Click({
	
	
	$inputUserFolder = Get-FolderDialog("Select Download folder")
    $syncHash.DownloadProjectPath.Text = $inputUserFolder
    
	
})







Function Get-FolderDialog($text)
{
	
	$folder = ""
	
    $foldername = [System.Windows.Forms.FolderBrowserDialog]::New()
    $foldername.Description = "$text"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder = $foldername.SelectedPath
    }
 
    return $folder

}


#########################################################################
#                        HAMBURGER EVENTS                               #
#########################################################################

# /************  equals to OnItemInvoked of MAhapps lib in C# *********/

$syncHash.HamburgerMenuControl.add_ItemInvoked({
    
   $syncHash.HamburgerMenuControl.Content = $_.InvokedItem
   $syncHash.HamburgerMenuControl.IsPaneOpen = $false

})











$syncHash.Form.ShowDialog() | Out-Null
  
