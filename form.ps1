#########################################################################
# Author:  Kevin RAHETILAHY                                             #
# Blog  : dev4sys.com                                                   #
#########################################################################


#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\ControlzEx.4.4.0\lib\net45\ControlzEx.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.2.3.4\lib\net46\MahApps.Metro.dll")      | out-null  
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.Material.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.IconPacks.4.8.0\lib\net46\MahApps.Metro.IconPacks.Core.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\Microsoft.Xaml.Behaviors.Wpf.1.1.19\lib\net45\Microsoft.Xaml.Behaviors.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\F23.StringSimilarity.3.1.0\lib\netstandard1.0\F23.StringSimilarity.dll") | out-null
[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\Dev4Sys.Converter.1.0\Dev4Sys.Converter.dll") | out-null


#########################################################################
#                        Load Main Panel                                #
#########################################################################


$syncHash = [hashtable]::Synchronized(@{})
$syncHash.PathPanel = $PSScriptRoot 

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



$viewFolder = $syncHash.PathPanel  +"\views"
$syncHash.Form = Load-Xaml($syncHash.PathPanel +"\form.xaml")


#########################################################################
#                          VIEWS                                        #
#########################################################################

#******************* Target View  *****************

$syncHash.MainView     = $syncHash.Form.FindName("MainContentControl") 


#******************* Load Other Views  *****************
$MainXaml	    = Load-Xaml($viewFolder+"\Main.xaml")
$ProviderXaml	= Load-Xaml($viewFolder+"\Provider.xaml")

$DriversView   = $MainXaml.FindName("DriversView") 
$DownloadView  = $MainXaml.FindName("DownloadView")
$CabinetView   = $MainXaml.FindName("CabinetView")
$SettingsView  = $MainXaml.FindName("SettingsView") 

$DriversXaml	= Load-Xaml($viewFolder+"\Drivers.xaml")
$DownloadXaml 	= Load-Xaml($viewFolder+"\Download.xaml")
$CabinetXaml 	= Load-Xaml($viewFolder+"\Cabinet.xaml")
$SettingsXaml 	= Load-Xaml($viewFolder+"\Settings.xaml")

$DriversView.Children.Add($DriversXaml)    | Out-Null
$DownloadView.Children.Add($DownloadXaml)  | Out-Null         
$CabinetView.Children.Add($CabinetXaml)    | Out-Null 
$SettingsView.Children.Add($SettingsXaml)  | Out-Null



#########################################################################
#                        Load Control item                              #
#########################################################################

$syncHash.Overlay      = $syncHash.Form.FindName("Overlay")
$syncHash.BottomFlyout = $syncHash.Form.FindName("BottomFlyout")
$syncHash.FlyoutMsg    = $syncHash.Form.FindName("FlyoutMsg")

$syncHash.HamburgerMenuControl = $MainXaml.FindName("HamburgerMenuControl")
$syncHash.ResultSearchGrid = $MainXaml.FindName("ResultSearch")
$syncHash.SearchBarBtn     = $MainXaml.FindName("searchbarbtn")
$syncHash.modelInput       = $MainXaml.FindName("searchbar")

$syncHash.ProviderFlipView = $ProviderXaml.FindName("ProviderList") 
$LoadProviderBtn           = $ProviderXaml.FindName("LoadProviderBtn")

# Drivers Pane
$syncHash.Datagrid   = $DriversXaml.FindName("Datagrid")
$syncHash.OSComboBox = $DriversXaml.FindName("OSComboBox")


# Download Pane
$DownloadBtn             = $DownloadXaml.FindName("DownloadBtn")
$ExtractBtn               = $DownloadXaml.FindName("ExtractBtn")
$FolderProjectBrowseBtn = $DownloadXaml.FindName("FolderProjectBrowseBtn")
$FolderProjectOpenBtn         	= $DownloadXaml.FindName("FolderProjectOpenBtn")

$ViewSelectedBtn         	= $DownloadXaml.FindName("ViewSelectedBtn")
$syncHash.ProgressIndicator        = $DownloadXaml.FindName("ProgressIndicator")
$syncHash.ProgressOutput          = $DownloadXaml.FindName("ProgressOutput")
$syncHash.DriversSelectedDatagrid = $DownloadXaml.FindName("DriversSelectedDatagrid")
$syncHash.OutputProjectPath     = $DownloadXaml.FindName("OutputProjectPath")


# Cabinet Pane
$ImportCABcontentBtn = $CabinetXaml.FindName("ImportCABcontentBtn")
$CompareCABdataBtn = $CabinetXaml.FindName("CompareCABdataBtn")
$CABComboBox = $CabinetXaml.FindName("CABComboBox")

$syncHash.CabinetContentDatagrid = $CabinetXaml.FindName("CabinetContentDatagrid")
$syncHash.ReleaseNoteURLTxtBox = $CabinetXaml.FindName("ReleaseNoteURLTxtBox")
$syncHash.CabinetCompareDatagrid = $CabinetXaml.FindName("CabinetCompareDatagrid")


$syncHash.MainView.Content = $ProviderXaml

#########################################################################
#                        LOAD VENDOR                                    #
#########################################################################

."$($syncHash.PathPanel)\scripts\Common.ps1"
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


Function Show-InfoMessage{
    
    Param(
        $Message
    )
    $syncHash.BottomFlyout.IsOpen = $true
    $syncHash.FlyoutMsg.Text = $Message

}


#########################################################################
#                        Event                                          #
#########################################################################

$syncHash.ProviderFlipView.Add_SelectionChanged({
    
    $syncHash.CurrentVendor = $syncHash.ProviderFlipView.SelectedItem.DataContext
    

})


$syncHash.ProgressRing = $syncHash.Form.FindName('ProgressRing')
$navigationWindow = [MahApps.Metro.Controls.MetroNavigationWindow]::new()


$FolderProjectOpenBtn.Add_Click({
    
    if(Test-Path $syncHash.ProjectPath ){
        Invoke-Item $syncHash.ProjectPath 
    }

})


$CABComboBox.Add_SelectionChanged({

     $syncHash.ReleaseNoteURLTxtBox.Text = $CABComboBox.SelectedItem.URL

})


$ImportCABcontentBtn.Add_Click({

    $releaseNote = $syncHash.ReleaseNoteURLTxtBox.Text
    $syncHash.CabResult = $syncHash.SelectedVendor.GetCabDriversContent($releaseNote)
    $syncHash.CabinetContentDatagrid.ItemsSource = $syncHash.CabResult

})


$CompareCABdataBtn.Add_Click({

    $driverCAb = $syncHash.CabResult 
    $dataInput = $($Script:VarAllDriversForModel.Files)

    $mirrorResult = @()
    foreach($driver in $driverCAb){
        #Write-Host "=========== $($driver.DeviceDescription)================="
        $possibleMatch =  Select-SimilarDriver -Search $driver.DeviceDescription -Data $dataInput

        if($possibleMatch){
            #Write-Host "$($driver.DeviceDescription) -->  $($possibleMatch[0]) "
            $mirrorResult  +=      [PScustomobject]@{
                ReleaseID         = $possibleMatch[0].Result.ID;
                DeviceDescription = $possibleMatch[0].Result.Name;
                VendorVersion     = $possibleMatch[0].Result.Version
            }
        }
        else{
            #Write-Host "$($driver.DeviceDescription) --> "
            $mirrorResult  +=      [PScustomobject]@{
                ReleaseID         = $null;
                DeviceDescription = $null;
                VendorVersion     = $null
            }
        }
    }

    $syncHash.CabinetCompareDatagrid.ItemsSource = $mirrorResult

})


#########################################################################
#                        Provider Selector                              #
#########################################################################

$LoadProviderBtn.Add_Click({
    
    Write-Host $syncHash.CurrentVendor

    if($syncHash.CurrentVendor -eq "Lenovo"){
        $syncHash.SelectedVendor = [Lenovo]::new()
    }
    elseif($syncHash.CurrentVendor -eq "Dell"){
        $syncHash.SelectedVendor = [Dell]::new()
    }
    elseif($syncHash.CurrentVendor -eq "HP"){
        $syncHash.SelectedVendor = [HP]::new()
    }else{
        return
    }

    $syncHash.Form.WindowState ="Maximized"
    $syncHash.MainView.Content = $MainXaml

})

 

#########################################################################
#                      Search Button Event                              #
#########################################################################


$syncHash.SearchBarBtn.Add_Click({


    # Create a datacontext
    $DataContext = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
    $IsActive = $true
    $searchResult = $null
    $DataContext.Add($IsActive)
    $DataContext.Add($searchResult)

    # Attach Datacontext to whole Form
    $syncHash.MainView.DataContext = $DataContext

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

        $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        $Runspace = [runspacefactory]::CreateRunspace($InitialSessionState) 
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

            # -----------------------------------------------------------
            # ThreadSafe problem, Exception: 'Stack Empty' while accessing 
            # Class Attributes in a loop so I instantiate it here for now 
            # I know this is awful ... :P
            # -----------------------------------------------------------
            
            if($syncVar.CurrentVendor -eq "Lenovo"){
                ."$($syncVar.PathPanel)\scripts\Vendor-Lenovo.ps1"
                $RunspaceScopeVendor = [Lenovo]::new()
            }
            elseif($syncVar.CurrentVendor -eq "Dell"){
                ."$($syncVar.PathPanel)\scripts\Vendor-Dell.ps1"
                $RunspaceScopeVendor = [Dell]::new()
            }
            elseif($syncVar.CurrentVendor -eq "HP"){
                ."$($syncVar.PathPanel)\scripts\Vendor-HP.ps1"
                $RunspaceScopeVendor = [HP]::new()
            }else{
                return
            }
             

            $DataContext[1] = $RunspaceScopeVendor.FindModel($syncVar.UserInput)
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
                $syncHash.Form.WindowState ="Maximized"

                $syncHash.Overlay.Visibility = "Collapsed"
			    $syncHash.PoshRunspace.EndInvoke($SyncHash.AsyncObject)
			    $syncHash.PoshRunspace.runspace.close()
			    $syncHash.PoshRunspace.runspace.dispose()

                # Pass the memory cleaner :D
                [System.GC]::Collect()
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
        Show-InfoMessage -Message "Please specify more than 2 characters."
    }


})



[System.Windows.RoutedEventHandler]$EventonDataGrid = {
    

    # GET THE NAME OF EVENT SOURCE
    $button =  $_.OriginalSource.Name

    # CHOOSE THE CORRESPONDING ACTION
    If ( $button -match "loadModel" ){
         
        Write-Host $syncHash.ResultSearchGrid.CurrentItem.Name
        Write-Host $syncHash.ResultSearchGrid.CurrentItem.Guid
		
        $DownloadBtn.IsEnabled = $false
        $ExtractBtn.IsEnabled = $false

        $syncHash.CurrentModel = $syncHash.ResultSearchGrid.CurrentItem.Name

        $wbrsp 				= $syncHash.SelectedVendor.GetModelWebResponse($syncHash.ResultSearchGrid.CurrentItem.Guid)
        $OSCatalog 			= $syncHash.SelectedVendor.GetAllSupportedOS($wbrsp)
        $DriversModeldatas 	= $syncHash.SelectedVendor.LoadDriversFromWebResponse($wbrsp)


        if($DriversModeldatas){
            $Script:VarAllDriversForModel = $DriversModeldatas

            $syncHash.OSComboBox.ItemsSource = $OSCatalog

            # Get Windows 10 x64 Pattern
            $OSWin64Value = ($OSCatalog | ?{$_.Name -match 'Windows 10..64'})
            $syncHash.OSComboBox.SelectedValue = $OSWin64Value


            # Find all CAB associated
            $syncHash.AllCABObj = $syncHash.SelectedVendor.ExtractCabInfosOfModel($DriversModeldatas) 

            if($syncHash.AllCABObj){

                # Linq to select only appropriate file type
                $StringData =  @('html','cva','txt')
                $CABComboBox.ItemsSource = $syncHash.AllCABObj.Files | Where-Object {
                    $delegate =  [Func[string,bool]]{ $_.URL.toLower().EndsWith($args[0])}
                    [Linq.Enumerable]::Any([string[]]$StringData, $delegate)
                }

            }

        }else{
            Show-InfoMessage -Message "Not a know computer model (Maybe a printer :D ...)"
        }

    }

}
$syncHash.ResultSearchGrid.AddHandler([System.Windows.Controls.Button]::ClickEvent, $EventonDataGrid)



#########################################################################
#                        DRIVERS VIEW EVENTS                            #
#########################################################################


$syncHash.OSComboBox.Add_SelectionChanged({

    $OSType = $syncHash.OSComboBox.SelectedItem.Value

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



#########################################################################
#                        DOWNLOAD VIEW EVENTS                           #
#########################################################################

# -----------------------------------------------------------------------
# View list of selected driver
# -----------------------------------------------------------------------
$ViewSelectedBtn.Add_Click({
    
    $ToBeDownLoadedRaw = $Script:VarAllDriversForModel | ?{$_.Files.IsSelected -eq $true}
    $syncHash.ToBeDownLoaded = $syncHash.SelectedVendor.PrepareDriversGroupDownload($ToBeDownLoadedRaw)
    $syncHash.DriversSelectedDatagrid.ItemsSource = $syncHash.ToBeDownLoaded

    if($syncHash.ToBeDownLoaded){
        # enable download and extract button 
        $DownloadBtn.IsEnabled = $true
        $ExtractBtn.IsEnabled = $true
    }else{
        # disable
        $DownloadBtn.IsEnabled = $false
        $ExtractBtn.IsEnabled = $false
    }

})


# -----------------------------------------------------------------------
# Project Folder Borwser 										
# -----------------------------------------------------------------------
$FolderProjectBrowseBtn.Add_Click({
	
	$inputUserFolder = Get-FolderDialog("Select Project folder")
    $syncHash.OutputProjectPath.Text = $inputUserFolder
	
	# Check if not empty 
    if(!$syncHash.OutputProjectPath.Text){
        Show-InfoMessage -Message "Please select an output folder!"
        return
    }

    # check if valid Path
    if(!(Test-Path $syncHash.OutputProjectPath.Text)){
        Show-InfoMessage -Message "Please select valid folder!"
        return
    }
	
	# Set Global Var
	$ModelFolder = $syncHash.CurrentModel.Replace('/','-')
    $syncHash.ProjectPath  = "$($syncHash.OutputProjectPath.Text)\$ModelFolder"
	Write-Host $syncHash.ProjectPath
	
	
})



########################################
# Create a datacontext For PseudoConsole
########################################

$syncHash.DwnDataContext = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()
$TextContent = ""
$IsIndeterminate = $false
$syncHash.DwnDataContext.Add($TextContent)
$syncHash.DwnDataContext.Add($IsIndeterminate)


# -----------------------------------------------------------------------
# Download Drivers
# -----------------------------------------------------------------------
$DownloadBtn.Add_Click({
    

    if(!($syncHash.ProjectPath)){ 
        Show-InfoMessage -Message "Please Select Working directory!"
        return
    }

    $syncHash.DownloadPath = "$($syncHash.ProjectPath)\Download"

    # Attach Datacontext to The progressBar
    $syncHash.ProgressOutput.DataContext = $syncHash.DwnDataContext
    $syncHash.ProgressIndicator.DataContext = $syncHash.DwnDataContext

    # Create and set a binding on the ResultSearch Datagrid object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[0]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ProgressOutput,[System.Windows.Controls.TextBox]::TextProperty, $Binding)

    # Create and set a binding on the ResultSearch Datagrid object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[1]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ProgressIndicator,[System.Windows.Controls.ProgressBar]::IsIndeterminateProperty, $Binding)


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
            [System.Collections.ObjectModel.ObservableCollection[Object]]$DwnDataContext
        )

        $DwnDataContext[1] = $true
        $DwnDataContext[0] += "`n============================================= `n Opening Runspace ... `n============================================= `n `n"

        # Start a timer
        $Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $Stopwatch.Start()

        foreach ($driver in $syncVar.ToBeDownLoaded){
            
            $folderPathGroup    = "$($syncVar.DownloadPath)\$($driver.DownloadGroup)"
            $driverTargetFolder = "$folderPathGroup\$($driver.DownLoadID)"

            # Create category folder if not exist
            if(!(Test-Path $folderPathGroup)){
                New-Item -ItemType Directory -Path "$folderPathGroup" | Out-Null
            }

            # Create Folder ID if not exist
            New-Item -ItemType Directory -Path "$driverTargetFolder" | Out-Null
            $DwnDataContext[0] += "Downloading: $($driver.DownloadURL) `n " 

            $result = $Provider.DownloadDriver($driver.DownloadURL , $driverTargetFolder )
            $DwnDataContext[0] += "=> Status: $result `n " 
        }

        # Stop progressbar IsIndeterminate
        $DwnDataContext[1] = $false

        $Stopwatch.Stop()
        $DwnDataContext[0] += "Completed in $($Stopwatch.Elapsed.Minutes) minutes and $($Stopwatch.Elapsed.Seconds) seconds. `n" 
        $DwnDataContext[0] += "`n=============================================`n Closing Runspace `n============================================= `n"

    })
    
         
    $PowerShell.AddArgument([System.Object]$syncHash.SelectedVendor)
    $PowerShell.AddArgument([System.Collections.ObjectModel.ObservableCollection[Object]]$syncHash.DwnDataContext)

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


# -----------------------------------------------------------------------
# Extract Drivers
# -----------------------------------------------------------------------
$ExtractBtn.Add_Click({
    

    if(!($syncHash.ProjectPath)){ 
        Show-InfoMessage -Message "Please Select Working directory!"
        return
    }

    $syncHash.ExtractPath  = "$($syncHash.ProjectPath)\Extract" 


    # Attach Datacontext to The progressBar
    $syncHash.ProgressOutput.DataContext = $syncHash.DwnDataContext
    $syncHash.ProgressIndicator.DataContext = $syncHash.DwnDataContext

    # Create and set a binding on the ResultSearch Datagrid object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[0]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ProgressOutput,[System.Windows.Controls.TextBox]::TextProperty, $Binding)

    # Create and set a binding on the ResultSearch Datagrid object
    $Binding = [System.Windows.Data.Binding]::new()
    $Binding.Path = "[1]"
    $Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
    [System.Windows.Data.BindingOperations]::SetBinding($syncHash.ProgressIndicator,[System.Windows.Controls.ProgressBar]::IsIndeterminateProperty, $Binding)


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

    New-Item -ItemType Directory $syncHash.ExtractPath

    $PowerShell.AddScript({

        Param (
            [System.Object]$Provider,
            [System.Collections.ObjectModel.ObservableCollection[Object]]$DwnDataContext
        )

        $DwnDataContext[1] = $true
        $DwnDataContext[0] += "`n============================================= `n Opening Runspace ... `n============================================= `n `n"

        # Start a timer
        $Stopwatch = [System.Diagnostics.Stopwatch]::new()
        $Stopwatch.Start()

        # get All item from donwload folder
        $downloadFolder = Get-ChildItem $syncVar.DownloadPath

	    foreach ($catFolder in $downloadFolder )
	    {

            # create the structure in destination folder
            $categoryFolder = "$($syncVar.ExtractPath)\$($catFolder.Name)" 
            New-Item -ItemType Directory -Path $categoryFolder | Out-Null

		    $driverIDFolders = [Array](Get-ChildItem $catFolder.FullName)
		    $driverIDFolders | ForEach-Object {
			
                # Get the file inside Category\ID folder [There should be only one file inside each ID folder !!]
                $file = Get-ChildItem $_.FullName
                $DwnDataContext[0] += "Extracting file: $($file.FullName)  `n  "

                $targetIDFolder = "$categoryFolder\$($_.Name)" 
                New-Item -ItemType Directory -Path $targetIDFolder | Out-Null

                $result = $Provider.ExtractDriver( $file.FullName , $targetIDFolder )
                $DwnDataContext[0] += "=> Status: $result `n "

		    }
		
	    }
	
        # Stop progressbar IsIndeterminate
        $DwnDataContext[1] = $false

        $Stopwatch.Stop()
        $DwnDataContext[0] += "Completed in $($Stopwatch.Elapsed.Minutes) minutes and $($Stopwatch.Elapsed.Seconds) seconds. `n" 
        $DwnDataContext[0] += "`n=============================================`n Closing Runspace `n============================================= `n"

    })
                 
    $PowerShell.AddArgument([System.Object]$syncHash.SelectedVendor)
    $PowerShell.AddArgument([System.Collections.ObjectModel.ObservableCollection[Object]]$syncHash.DwnDataContext)


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
$syncHash.Error = $Error





