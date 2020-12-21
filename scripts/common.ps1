# #########################################################
# Common Function 
# #########################################################



function Select-SimilarDriver(){

    [CmdletBinding()]
    param (
        # The search query.
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Search,

        # The data you want to search through.
        [Parameter(Position = 1)]
        [Object] $Data
    )

    $Input = $Search

    # Remove spaces from the search string
    $search = $Search.Replace(' ','')
    # Add wildcard characters before and after each character in the search string
    $quickSearchFilter = '*'
    $search.ToCharArray().ForEach({
        $quickSearchFilter += $_ + '*'
    })

    $var= @()


    foreach ($DriverFile in $Data) {
        
        if($DriverFile.Name){
            
            $string = $DriverFile.Name.Trim()
            # Do a quick search using wildcards
            if ($string -like $quickSearchFilter) {
                # Get score of match
                $score = Get-FuzzyMatchScore -Search $Search -String $string
                $var += [PSCustomObject][Ordered] @{
                    Score = $score;
                    Search = $Input;
                    Result = $DriverFile
                }

            }
        }
    }

    return $var

}






















