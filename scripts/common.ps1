# #########################################################
# Common Function 
# #########################################################



# --------------------------------------------------------
# Taken from https://github.com/feature23/StringSimilarity.NET
# Looks like with JaroWinkler algorithm I get better result than 
# Normalized Levenshtein
# --------------------------------------------------------

$JaroWinkler = [F23.StringSimilarity.JaroWinkler]::new()


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


    $var= $null

    # criteria to have decent result
    $tempScore = 0.6

    foreach ($DriverFile in $Data) {
        
        if($DriverFile.Name){
            
            $string = $DriverFile.Name.Trim()

            # Get score of match
            $score = $JaroWinkler.Similarity($string,$search)

            if($score -ge $tempScore){
                
                $tempScore = $score
                $var = [PSCustomObject] @{
                    Score = $score;
                    Search = $Input;
                    Result = $DriverFile
                }
                
            }


        }
    }

    return $var

}





