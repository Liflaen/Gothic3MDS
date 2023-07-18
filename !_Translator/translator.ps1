# declare variables
$mainMDSFolder = "g:\SteamLibrary\steamapps\common\Gothic 3\MDS\FanMods\"
$nameOfIniFile = "stringtableMod.ini"
$nameOfReadMe = "readme.rtf"
$inFolder = ".\in\"
$outFolder = ".\out\"
$inFile = "$inFolder$nameOfIniFile"
$outFile = "$outFolder$nameOfIniFile"
$outFileTmp = ".\out\stringtableModTmp.ini"
$targetLanguage = “en”
$countOfLines = 1
$totalCountOfLines = (Get-Content $inFile).Length

# cleare working dirs
#if (test-path $inFolder) { remove-item $inFolder -recurse }
if (test-path $outFolder) { remove-item $outFolder -recurse }
#
# create working dirs
#new-item -path $inFolder -itemtype directory
new-item -path $outFolder -itemtype directory
#
# load folders and files - TBD
#$folderForParse = get-childitem $mainMDSFolder -Recurse | where {
#    !(test-path (join-path $_.fullname $nameOfIniFile))
#}
#foreach ($file in $folderForParse) {
#    # create specific folder if not exists then create
#    $fileDir = $file.Directory.Name
#    if (-not(test-path "$inFolder$fileDir")) { new-item "$inFolder$fileDir" -itemtype directory }
#    
#    if ($file.Name -eq $nameOfIniFile -or $file.Name -eq $nameOfReadMe) { 
#        copy-item -path $file.fullname -destination "$inFolder$fileDir"
#    }
#}

write-host "Processing start"
write-host "Translate"

# translate russian text to english equivalent
foreach($line in get-content $inFile) {
    write-host "Processing line: $countOfLines/$totalCountOfLines"
    if($line -imatch '=\[ANG\];;' -or $line -imatch '=\[ENG\];;' -or $line -imatch '=\[EN\];;' -or $line -imatch '=ang;;' -or $line -imatch '=eng;;' -or $line -imatch '=en;;' -or $line -imatch '=an;;' -or $line -imatch '=;;'){
		# get russian line of txt - 16 is Russian text after split , you can change the nbr for different language input
        $russianText = $line.Split(";;")[16]


        # get english txt from google translate using RestMethod
        $uri = “https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$($targetLanguage)&dt=t&q=$russianText”
        $response = invoke-restmethod -Uri $uri -Method get
        $englishText = $response[0].SyncRoot | foreach { $_[0] }
        
		# set first letter always to upper
		$firstLetter = $englishText.Substring(0,1).ToUpper()
        $restOfTheString = $englishText.Substring(1)
        $englishText = $firstLetter + $restOfTheString
        
        # replace different english placeholders or missing placeholders and save it into file
        $line | ForEach-Object {
            $_ -ireplace '=\[ANG\];;', "=$englishText;;" `
               -ireplace '=\[ENG\];;', "=$englishText;;" `
               -ireplace '=\[EN\];;', "=$englishText;;" `
               -ireplace '=ang;;', "=$englishText;;" `
               -ireplace '=eng;;', "=$englishText;;" `
               -ireplace '=en;;', "=$englishText;;" `
               -ireplace '=an;;', "=$englishText;;" `
               -ireplace '=;;', "=$englishText;;"
        } | Add-Content -Encoding Unicode  $outFile
    }
    # if there is empty line or commentary or so copy paste the line
    else { $line | Add-Content -Encoding Unicode $outFile }
    $countOfLines++
}

# reset the variable
$countOfLines = 1

Write-Host "Corrections"
# correct all first letters to Upper case (the existing one) + double space correction
foreach($line in Get-Content $outFile) {
    Write-Host "Processing line: $countOfLines/$totalCountOfLines"

    # ignore blank lines and start of file
    if ($line -imatch  '^[[:blank:]]*$' -or $line -eq '[LocAdmin_Strings]') { $line | Add-Content -Encoding Unicode $outFileTmp }
    else {
        # get english comment
        $englishTextOrig = ($line.Split("=")[1]).Split(";;")[0]

        # first letter to upper
        $firstLetter = $englishTextOrig.Substring(0,1).ToUpper()
        $restOfTheString = $englishTextOrig.Substring(1)
        $englishTextNew = $firstLetter + $restOfTheString

        # remove double spaces
        $englishTextNew = $englishTextNew.Replace('  ', ' ')

        # paste into file
        $line.Replace($englishTextOrig, $englishTextNew) | Add-Content -Encoding Unicode $outFileTmp
    }
    $countOfLines++
}

# removing temp outFile
Remove-Item $outFile
Rename-Item $outFileTmp -NewName $nameOfIniFile

write-host "Processing end"