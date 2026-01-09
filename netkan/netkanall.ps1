# Makes everything into a ckan file

# Grab the .netkan files only
$netkanFiles = Get-ChildItem -Path . -Filter *.netkan | Sort-Object Name

if ($netkanFiles.Count -eq 0) {
    Write-Host "No .netkan files found in the current directory." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($netkanFiles.Count) .netkans, doing it" -ForegroundColor Green

foreach ($file in $netkanFiles) {
    Write-Host "$($file.Name)" -ForegroundColor Cyan
    
    # Run the thing
    $output = & .\netkan.exe -v --outputdir ..\ckan $file.FullName 2>&1
    
    # Combine lines
    $outputText = $output -join "`n"
    Write-Host $outputText
    
    # Did it work?
    if ($outputText -match "Transformation written to") {
        Write-Host "It worked: '$($file.Name)'" -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
    }
    else { # Fail
        Write-Host "Didnt work: '$($file.Name)' did not complete successfully." -ForegroundColor Red
        exit 1
    }
}

Write-Host "All .netkan files finished" -ForegroundColor Green