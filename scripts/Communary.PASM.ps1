<#
    2016// Øyvind Kallstad (@okallstad)
#>


function Get-FuzzyMatchScore {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Search,

        [Parameter(Position = 1)]
        [string] $String
    )

    $score = 100

    # Use approximate string matching to get some values needed to calculate the score of the result
    $longestCommonSubstring = Get-LongestCommonSubstring -String1 $String -String2 $Search
    $levenshteinDistance = Get-LevenshteinDistance -String1 $String -String2 $Search
    $commonPrefix = Get-CommonPrefix -String1 $String -String2 $Search

    # By running the result through this regex pattern we get the length of the match as well as the
    # the index of where the match starts. The shorter the match length and the index, the more
    # score will be added for the match.
    $regexMatchFilter = $Search.ToCharArray() -join '.*?'
    $match = Select-String -InputObject $String -Pattern $regexMatchFilter -AllMatches
    $matchLength = ($match.Matches | Sort-Object Length | Select-Object -First 1).Value.Length
    $matchIndex = ($match.Matches | Sort-Object Length | Select-Object -First 1).Index

    # Calculate score
    $score = $score - $levenshteinDistance
    $score = $score * $longestCommonSubstring.Length
    $score = $score - $matchLength
    $score = $score - $matchIndex

    if ($commonPrefix) {
        $score =  $score + $commonPrefix.Length
    }

    Write-Output $score
}


function Get-LongestCommonSubstring {
    <#
        .SYNOPSIS
            Get the longest common substring of two strings.
        .DESCRIPTION
            Get the longest common substring of two strings.
        .EXAMPLE
            Get-LongestCommonSubstring 'Karolin' 'kathrin' -CaseSensitive
        .LINK
            https://fuzzystring.codeplex.com/
            http://en.wikipedia.org/wiki/Longest_common_substring_problem
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.PASM
        .NOTES
            Adapted to PowerShell from code by Kevin Jones (https://fuzzystring.codeplex.com/)
            Author: Øyvind Kallstad
            Date: 03.11.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $String1,

        [Parameter(Position = 1)]
        [string] $String2,

        [Parameter()]
        [switch] $CaseSensitive
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $array = New-Object 'Object[,]' $String1.Length, $String2.Length
    $stringBuilder = New-Object System.Text.StringBuilder
    $maxLength = 0
    $lastSubsBegin = 0

    for ($i = 0; $i -lt $String1.Length; $i++) {
        for ($j = 0; $j -lt $String2.Length; $j++) {
            if ($String1[$i] -cne $String2[$j]) {
                $array[$i,$j] = 0
            }
            else {
                if (($i -eq 0) -or ($j -eq 0)) {
                    $array[$i,$j] = 1
                }
                else {
                    $array[$i,$j] = 1 + $array[($i - 1),($j - 1)]
                }
                if ($array[$i,$j] -gt $maxLength) {
                    $maxLength = $array[$i,$j]
                    $thisSubsBegin = $i - $array[$i,$j] + 1
                    if($lastSubsBegin -eq $thisSubsBegin) {
                        [void]$stringBuilder.Append($String1[$i])
                    }
                    else {
                        $lastSubsBegin = $thisSubsBegin
                        $stringBuilder.Length = 0
                        [void]$stringBuilder.Append($String1.Substring($lastSubsBegin, (($i + 1) - $lastSubsBegin)))
                    }
                }
            }
        }
    }

    Write-Output $stringBuilder.ToString()
}

function Get-CommonPrefix {
    <#
        .SYNOPSIS
            Find the common prefix of two strings.
        .DESCRIPTION
            This function will get the common prefix of two strings; that is, all
            the letters that they share, starting from the beginning of the strings.
        .EXAMPLE
            Get-CommonPrefix 'Card' 'Cartoon'
            Will get the common prefix of both string. Should output 'car'.
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.PASM
        .INPUTS
            System.String
        .OUTPUTS
            System.String
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.11.2014
            Version 1.1
            Dependencies: none
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$String1,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$String2,

        # Maximum length of the returned prefix.
        [Parameter()]
        [int]$MaxPrefixLength,

        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $outputString = New-Object 'System.Text.StringBuilder'
    $shortestStringLength = [Math]::Min($String1.Length,$String2.Length)

    # Let the maximum prefix length be the same as the length of the shortest of
    # the two input strings, unless defined by the MaxPrefixLength parameter.
    if (($shortestStringLength -lt $MaxPrefixLength) -or ($MaxPrefixLength -eq 0)) {
        $MaxPrefixLength = $shortestStringLength
    }

    # Loop from the start and add any characters found that are equal
    for ($i = 0; $i -lt $MaxPrefixLength; $i++) {
        if ($String1[$i] -ceq $String2[$i]) {
            [void]$outputString.Append($String1[$i])
        }
        else { break }
    }

    Write-Output $outputString.ToString()
}

function Get-LevenshteinDistance {
    <#
        .SYNOPSIS
            Get the Levenshtein distance between two strings.
        .DESCRIPTION
            The Levenshtein Distance is a way of quantifying how dissimilar two strings (e.g., words) are to one another by counting the minimum number of operations required to transform one string into the other.
        .EXAMPLE
            Get-LevenshteinDistance 'kitten' 'sitting'
        .LINK
            http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#C.23
            http://en.wikipedia.org/wiki/Edit_distance
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.PASM
        .NOTES
            Author: Øyvind Kallstad
            Date: 07.11.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$String1,

        [Parameter(Position = 1)]
        [string]$String2,

        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive,

        # A normalized output will fall in the range 0 (perfect match) to 1 (no match).
        [Parameter()]
        [switch] $NormalizeOutput
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $d = New-Object 'Int[,]' ($String1.Length + 1), ($String2.Length + 1)

    try {
        for ($i = 0; $i -le $d.GetUpperBound(0); $i++) {
            $d[$i,0] = $i
        }

        for ($i = 0; $i -le $d.GetUpperBound(1); $i++) {
            $d[0,$i] = $i
        }

        for ($i = 1; $i -le $d.GetUpperBound(0); $i++) {
            for ($j = 1; $j -le $d.GetUpperBound(1); $j++) {
                $cost = [Convert]::ToInt32((-not($String1[$i-1] -ceq $String2[$j-1])))
                $min1 = $d[($i-1),$j] + 1
                $min2 = $d[$i,($j-1)] + 1
                $min3 = $d[($i-1),($j-1)] + $cost
                $d[$i,$j] = [Math]::Min([Math]::Min($min1,$min2),$min3)
            }
        }

        $distance = ($d[$d.GetUpperBound(0),$d.GetUpperBound(1)])

        if ($NormalizeOutput) {
            Write-Output (1 - ($distance) / ([Math]::Max($String1.Length,$String2.Length)))
        }

        else {
            Write-Output $distance
        }
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}