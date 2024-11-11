# Folder path containing the CSV files
$inputFolder = "C:\Path\To\Your\Folder"
# Path for the combined output file
$outputFile = "C:\Path\To\Your\Folder\Combined.csv"

# Get all CSV files in the folder
$csvFiles = Get-ChildItem -Path $inputFolder -Filter *.csv

# Variable to track if the header has already been written
$headerWritten = $false

# Merge the CSV files
foreach ($file in $csvFiles) {
    # Read the CSV file
    $content = Import-Csv -Path $file.FullName

    # Write header and data for the first file only
    if (-not $headerWritten) {
        # Write header and data to the output file
        $content | Export-Csv -Path $outputFile -NoTypeInformation
        $headerWritten = $true
    } else {
        # Append only the data (without the header)
        $content | Export-Csv -Path $outputFile -NoTypeInformation -Append
    }
}

Write-Host "All CSV files have been merged into $outputFile"
