Param (
    [Parameter(Mandatory=$true,HelpMessage="The Base Directory you wish to summarize.")][Alias("LiteralPath")][string]$Path,
    [Parameter(HelpMessage="Use this tag to search through all subfolders of your main folder.")][Switch]$Recurse,
    [Parameter(Mandatory=$true,HelpMessage="The export file location. If the file doesn't exist it will be created.")][Alias("OutPath","Out")][string]$OutFile,
    [Parameter(HelpMessage="If this flag is set, Folders will be created if the output directory doesn't exist.")][Switch]$Force,
    [Parameter(HelpMessage="If this flag is set, the out file will be cleared out before being written to.")][Switch]$Overwrite,
    [Parameter(HelpMessage="Change the description tag indent. Defaults to a tab.")][string]$Indent="`t",
    [Parameter(HelpMessage="If a Header Tag does not match the category map, it will be placed here.")][Alias("NoMatch")][string]$Default="Other",
    [Parameter(HelpMessage="This is a hashtable in [ordered]@{ Header1 = category1; Header2 = category2; ... } Format.")][Alias("CategoryMap","Map","List","HeaderList","HeaderMap")][hashtable]$CategoryList,
    [Parameter(HelpMessage="The main delimiter to break the categories down by. Defaults to "";"".")][Alias("Main")][string]$MainDelimiter=';',
    [Parameter(HelpMessage="The sub delimiter to break the categories down by. Defaults to "","".")][Alias("Sub")][string]$SubDelimiter=',',
    [Parameter(HelpMessage="Adds a count of the number of times a description was applied to a given header.")][Switch]$Count,
    [Parameter(HelpMessage="Write Progress Updates to console.")][Switch]$Echo
)
#Make the $Out hashtable categories
$Out = [ordered]@{}
$CategoryList.Values | ForEach-Object { if(!($Out.Contains($_))) { $Out.Add($_, @{}) > $null; } }
$Out.Add($Default, @{}) > null;
if($echo) { Write-Host $Out }
#Search Through All text files in the folder
Get-ChildItem -LiteralPath "$Path" -Recurse:$Recurse -Filter "*.txt" | ForEach-Object {

    #Check that the file has an associated .png, if it doesn't skip the text file.
    if((Test-Path $_.FullName.Replace(".txt",".png")))
    {

        #Get the current caption, and break it into it's main pieces, and build up the out object.
        $Rawtxt = Get-Content -LiteralPath $_.FullName
        $TxtArray = $Rawtxt -Split $MainDelimiter
        foreach ($Prompt in $TxtArray) {
            $PromptList = $Prompt -split $SubDelimiter
            $Head = $PromptList[0].Trim()
            $Category = ""
            if($CategoryList.Contains($Head)) 
            { 
                $Category = $CategoryList[$Head] 
            } else {
                $Category = $Default
            }
            $PromptDetailList = $PromptList[1..($PromptList.Count - 1)]
            foreach ($Description in $PromptDetailList) {
                $Desc = $Description.Trim()
                if($Out[$Category].Contains($Head)) {
                    if ($Out[$Category][$Head].ContainsKey($Desc)) {
                        $Out[$Category][$Head][$Desc] += 1
                    } else {
                        $Out[$Category][$Head].Add($Desc, 1)
                    }
                } else {
                    $Out[$Category].Add($Head, @{ $Desc = 1 })
                }
            }
            if ($Echo) { Write-Host "$Category - $Head"; }
        }
    }
}

#Prepare Outfile
if(!(test-path $OutFile)) { New-Item -Path $OutFile -Force:$Force; }
if($Overwrite) {Clear-Content -Path $OutFile; }

#Write to Output File
Foreach ($C in $Out.Keys) {
    if ($Echo) { Write-Host "`n----- $C -----"; }
    Add-Content -LiteralPath $OutFile -Value "`n----- $C -----" 
    Foreach ($H in $Out[$C].GetEnumerator() | Sort-Object Name) {
        if ($Echo) { Write-Host "`n$($H.Name)"; }
        Add-Content -LiteralPath $OutFile -Value "`n$($H.Name)"
        Foreach ($D in $Out[$C][$H.Name].GetEnumerator() | Sort-Object Name) {
            $Subline = ""
            if($Count)
            {
                $Subline = "$Indent$($D.Name) - $($D.Value)"
            } else {
                $Subline = "$Indent$($D.Name)"
            }
            if ($Echo) { Write-Host $Subline; }
            Add-Content -LiteralPath $OutFile -Value $Subline
        }
    }
}