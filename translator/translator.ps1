$InFile = ".\in\stringtableMod.ini"
$OutFile = ".\out\stringtableMod.ini"
$TargetLanguage = “en”

if (Test-Path .\out\stringtableMod.ini) { Remove-Item -path .\out\stringtableMod.ini -recurse }

# read file line by line
foreach($Line in Get-Content $InFile) {
    if($Line -imatch '=\[ANG\];;' -or -or $Line -imatch '=\[ENG\];;' $Line -imatch '=ang;;' -or -or $Line -imatch '=eng;;' -or $Line -imatch '=en;;' -or $Line -imatch '=an;;'){
        $Line = "FO_It_Perk_SharpArrow=[ENG];;;;;;[DEU];;;;;;;;[POL];;Заточка стрел и болтов;;;"
        # get russian line of txt with double quotes
        $RussianTxt = $Line.Split(";;")[16]
        $Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($TargetLanguage)&dt=t&q=$RussianTxt”
        $Response = Invoke-RestMethod -Uri $Uri -Method Get
        $EnglishTxt = $Response[0].SyncRoot | foreach { $_[0] }
         # get english translated line of txt without double quotes
        $Line | ForEach-Object {
            $_ -ireplace '=\[ANG\];;', "=$EnglishTxt;;" `
               -ireplace '=\[ENG\];;', "=$EnglishTxt;;" `
               -ireplace '=ang;;', "=$EnglishTxt;;" `
               -ireplace '=eng;;', "=$EnglishTxt;;" `
               -ireplace '=en;;', "=$EnglishTxt;;" `
               -ireplace '=an;;', "=$EnglishTxt;;"
        } | Add-Content -Encoding Unicode  $outFile
    }
    else { $Line | Add-Content -Encoding Unicode $outFile }
}