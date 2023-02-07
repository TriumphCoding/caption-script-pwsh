Param (
    [Parameter(Mandatory=$true,HelpMessage="The Base Directory you wish to summarize.")][Alias("LiteralPath")][string]$Path,
    [Parameter(HelpMessage="Use this tag to search through all subfolders of your main folder.")][Switch]$Recurse,
    [Parameter(HelpMessage="Don't attempt to remove emoticons ( ;) :d :D ... ). By default emoticons are removed first.")][Switch]$SkipEmoticons,
    [Parameter(HelpMessage="Don't attempt to remove Parenthesis ( or )")][Switch]$SkipParenthesis
)

Write-Host "Removing Tokens"
Get-ChildItem -Path $Path -Recurse:$Recurse -Filter "*.txt" | ForEach-Object {
    if((Test-Path $_.FullName.Replace(".txt",".png")))
    {
        
        $starray = @(';)',':d',':D',';d',';D','xd','XD','d:','D:',':3',';3','x3','3:','uwu',':p',';p',':q',':9',';q','>:)','>:(',':t',':i',': エ',':/',':|',':x',':c','c:',':<',';<',':<>',':>',':>=',':o',';o','o3o','(-3-)','>3<','o_o','0_0','|_|','._.','^_^','^o^','\(^o^)/','^q^','^p^','>_<','xd','XD','x3','>o<','@_@','>_@','+_+','+_-','=_=','=^=','=v=','<o>_<o>','<|>_<|>')
        $Rawtxt = Get-Content -LiteralPath "$($_.FullName)"
        $Outtxt = $Rawtxt
        if (!$SkipEmoticons) {
            foreach ($fix in $starray) {
                $sfix = [regex]::escape($fix)
                $Outtxt = $Outtxt -Replace ", $($sfix)", ""
                if($Rawtxt -match $sfix) { $print = 1 }
            }
        }
        if (!$SkipParenthesis) {
            if($Rawtxt -match "\(|\)") { $print = 1 }
            $Outtxt = $Outtxt.Replace("(","").Replace(")","")
        }
        if ( $print -eq 1) 
        { 
            Write-Host "$($_.Name) || $Outtxt"
            Set-Content -LiteralPath "$($_.FullName)" -Value $Outtxt -NoNewline 
        }
    }
}
