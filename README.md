# caption-script-pwsh
A couple of tools to manage folders of images with caption files.


Call all of these by going .\FileName.ps1.

## Running powershell Scripts
You need to change your execution policy to run powershell scripts.
```
set-executionpolicy unrestricted -scope process
```
This isn't recommended to keep on in general, unless you know what you are doing with scripts. Don't run scripts from places you don't trust.


## Set-CaptionSummary.ps1
```
[string]$Path    - The Base Directory you wish to summarize.
[Switch]$Recurse - Use this tag to search through all subfolders of your main folder.
[string]$OutFile - The export file location. If the file doesn't exist it will be created. [Alias("OutPath","Out")]
[Switch]$Force   - If this flag is set, Folders will be created if the output directory doesn't exist.
[Switch]$Overwrite - If this flag is set, the out file will be cleared out before being written to.
[string]$Indent="`t" - Change the description tag indent. Defaults to a tab.
[string]$Default="Other" - If a Header Tag does not match the category map, it will be placed here. [Alias("NoMatch")]
[hashtable]$CategoryList - This is a hashtable in ([ordered]@{ Header1 = category1; Header2 = category2; ... }) Format. [Alias("CategoryMap","Map","List","HeaderList","HeaderMap")]
[string]$MainDelimiter=';' - The main delimiter to break the categories down by. Defaults to ";". [Alias("Main")]
[string]$SubDelimiter=',' - [Parameter(HelpMessage="The sub delimiter to break the categories down by. Defaults to ",". [Alias("Sub")]
[Switch]$Count - Adds a count of the number of times a description was applied to a given header.
[Switch]$Echo - Write Progress Updates to console.
```
This script will search through your caption **path** directory, and generate a file in the **outfile** location that summarizes your prompt tags. The script assumes that you are searching through *.txt* files, and that every text file has an associated *.png*. If it doesn't, the *.txt* file is skipped.

You can call the script from powershell by using the following call:
```
.\Set-CaptionSummary.ps1 "E:\Temp\FEH" -Recurse "E:\Temp\FEH\CaptionList.txt" -Force -Overwrite -indent " >> " -Map ([ordered]@{ "Model"="Description"; "Color"="Description"; "Weapon"="Description"; "Backdrop"="Location";"Map"="Location" }) -NoMatch "Char" -Count
```
And you will get the following output (my Fire Emblem Heroes Dataset is used as the example)
```
----- Description -----

Color
 >> Blue - 26
 >> Green - 26
 >> Purple - 12
 >> Red - 26

Model
 >> Angry - 51
 >> Attack - 3012
 >> Closeup - 2991
 >> Cool - 58
 >> Damaged - 1952
 >> Full Body - 4197
 >> Neutral - 2224
 >> Pain - 62
 >> Smile - 56
 >> Special - 969
 >> White Background - 7188

Weapon
 >> Axe - 299
 >> Bow - 339
 >> Lance - 393
 >> Rod - 254
 >> Stone - 63
 >> Sword - 652
 >> Tome - 491

----- Location -----

Backdrop
 >> 1boy - 3
 >> 1girl - 6
 >> 6+girls - 3
 >> ambiguous gender - 1
 >> arch - 20
 >> architecture - 22
 ...
```

the "-Map" field might take some explaining. You are assigning Header Tags to Tag Categories. You could think of the list like this:
```
[ordered]@{
    "Model"="Description";
    "Color"="Description"; 
    "Weapon"="Description"; 
    "Backdrop"="Location";
    "Map"="Location"
}
```
This means that if you have a caption that looks like "Ike, Sword, Blue, Red Cape; Model, Attack, Smiling; Weapon, Sword; Backdrop, Castle", the system will break that down into:
**Ike**, Sword, Blue, Red Cape
**Model**, Attack, Smiling
**Weapon**, Sword
**Backdrop**, Castle

**Model** and **Weapon** will be assigned to the "Description" category. **Backdrop** will be assigned to the "Location" category. **Ike** isn't matched to anything in the list, so it will be assigned to the value of the **Default** tag, which defaults to "Other"

All said, this Map will break down Ike's caption like this:
```
---- Description -----
Model
    Attack
    Smiling
Weapon
    Sword

----- Location -----
Backdrop
    Castle

----- Other -----
Ike
    Sword
    Blue
    Red Cape

```


## Remove-InvalidTokens
```
[string]$Path - The Base Directory you wish to summarize.")][Alias("LiteralPath")]
[Switch]$Recurse - Use this tag to search through all subfolders of your main folder.
[Switch]$SkipEmoticons - Don't attempt to remove emoticons ( ;) :d :D ... ). By default emoticons are removed first.
[Switch]$SkipParenthesis - Don't attempt to remove Parenthesis ( or ).
```

Call this command using the following code, and you will attempt to clean up all the emoticons that can be added via automatic tagging.
```
.\Remove-InvalidTokens "E:\Temp\FEH" -Recurse
```

Here is the emoticon list:
```
';)',':d',':D',';d',';D','xd','XD','d:','D:',':3',';3','x3','3:','uwu',':p',';p',':q',':9',';q','>:)','>:(',':t',':i',': エ',':/',':|',':x',':c','c:',':<',';<',':<>',':>',':>=',':o',';o','o3o','(-3-)','>3<','o_o','0_0','|_|','._.','^_^','^o^','\(^o^)/','^q^','^p^','>_<','xd','XD','x3','>o<','@_@','>_@','+_+','+_-','=_=','=^=','=v=','<o>_<o>','<|>_<|>'
```

