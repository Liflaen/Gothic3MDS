# declare variables
$inFile = ".\in\stringtableMod.ini"
$outFile = ".\out\stringtableMod.ini"
$targetLanguage = “en”
$countOfLines = 1

# delete output file in case it exists
if (Test-Path .\out\stringtableMod.ini) { Remove-Item -path .\out\stringtableMod.ini -recurse }

Write-Host "Processing start"
# read file line by line
$totalCountOfLines = (Get-Content $inFile).Length
foreach($Line in Get-Content $inFile) {
    Write-Host "Processing line: $countOfLines/$totalCountOfLines"
    if($Line -imatch '=\[ANG\];;' -or $Line -imatch '=\[ENG\];;' -or $Line -imatch '=ang;;' -or $Line -imatch '=eng;;' -or $Line -imatch '=en;;' -or $Line -imatch '=an;;' -or $line -imatch '=;;'){
        # get russian line of txt - 16 is Russian text after split , you can change the nbr for different language input
        $RussianTxt = $Line.Split(";;")[16]


        # get english txt from google translate using RestMethod
        $Uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($targetLanguage)&dt=t&q=$RussianTxt”
        $Response = Invoke-RestMethod -Uri $Uri -Method Get
        $EnglishTxt = $Response[0].SyncRoot | foreach { $_[0] }
        
        
        # replace different english placeholders or missing placeholders and save it into file
        $Line | ForEach-Object {
            $_ -ireplace '=\[ANG\];;', "=$EnglishTxt;;" `
               -ireplace '=\[ENG\];;', "=$EnglishTxt;;" `
               -ireplace '=ang;;', "=$EnglishTxt;;" `
               -ireplace '=eng;;', "=$EnglishTxt;;" `
               -ireplace '=en;;', "=$EnglishTxt;;" `
               -ireplace '=an;;', "=$EnglishTxt;;" `
               -ireplace '=;;', "=$EnglishTxt;;"
        } | Add-Content -Encoding Unicode  $outFile
    }
    # if there is empty line or commentary or so copy paste the line
    else { $Line | Add-Content -Encoding Unicode $outFile }
    $countOfLines++
}
write-host "Processing end"