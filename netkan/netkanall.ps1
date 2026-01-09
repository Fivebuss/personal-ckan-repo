# Makes everything into a ckan file
# Grab the .netkan files only
# Obviously needs the netkan.exe, of course I wont redistribute it needlessly
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
        # Grab the path
        if ($outputText -match "Transformation written to\s+([^\r\n]+)") {
            $ckanPath = $Matches[1].Trim()
            $ckanFileName = Split-Path $ckanPath -Leaf

            Write-Host "Generated: $ckanFileName" -ForegroundColor Green

            # Fix textures because SC put 2 copies of readme and settings
            if ($ckanFileName -match "(?i)textures") {
                Write-Host "Fixing .ckan file" -ForegroundColor Yellow

                try {
                    $json = Get-Content $ckanPath -Raw | ConvertFrom-Json

                    if ($json.install -and $json.install.Count -eq 1) {
                        $installObj = $json.install[0]

                        # Do it
                        if (-not $installObj.PSObject.Properties.Name.Contains("filter")) {
                            # Add the filter array
                            $installObj | Add-Member -MemberType NoteProperty -Name "filter" -Value @(
                                "KSS2_License.md"
                                "KSS2Settings.cfg"
                            )

                            # Put it in (wait)
                            $JsonButReadable = $json | ConvertTo-Json -Depth 10
                            Set-Content -Path $ckanPath -Value $JsonButReadable

                            Write-Host "Fixed" -ForegroundColor Green
                        } else {
                            Write-Host "Somehow already fixed" -ForegroundColor DarkGray
                        }
                    } else {
                        Write-Host "Aaaandddd it didnt work fixing" -ForegroundColor DarkYellow
                    }
                } catch {
                    Write-Host "RIP: $_" -ForegroundColor Red
                }
            }
        }

        Write-Host "It worked: '$($file.Name)'" -ForegroundColor Green
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
    }
    else { # Fail
        Write-Host "Didnt work: '$($file.Name)' did not complete successfully." -ForegroundColor Red
        exit 1
    }
}
Write-Host "All .netkan files finished" -ForegroundColor Green