#
# ShuvFile.ps1
#
# Define source and destination paths
$sourcePath = "E:\FilesToTransfer"
$destinationPath = "F:\DestinationFolder"

# Define the path to the log file
$logFilePath = "C:\Logs\ShuvFile.log"

# Define the path to the metadata CSV file
$metadataFilePath = "C:\Metadata\ShuvFileMetadata.csv"

# Define whether files should be moved or copied
$moveFiles = $false

# Define whether metadata should be saved to a CSV file
$saveMetadata = $true

# Get all files in the source directory
$files = Get-ChildItem $sourcePath -Recurse

# Loop through each file and transfer it to the destination directory
foreach ($file in $files) {
    # Determine the destination path for the file
    $destinationFile = Join-Path $destinationPath $file.Name
    
    # Check if the file already exists in the destination directory
    if (Test-Path $destinationFile) {
        # If the file already exists, compare its content with the source file
        $sourceContent = Get-Content $file.FullName -Raw
        $destinationContent = Get-Content $destinationFile -Raw
        if ($sourceContent -eq $destinationContent) {
            # If the content is the same, skip the file
            Write-Host "Skipping duplicate file: $($file.FullName)"
            continue
        }
    }
    
    # If the file does not exist in the destination directory or the content is different, transfer the file
    if ($moveFiles) {
        Move-Item $file.FullName $destinationPath -Force
    } else {
        Copy-Item $file.FullName $destinationPath -Force
    }
    
    # Log the transfer in the log file
    $logMessage = "Transferred file: $($file.FullName) to $($destinationFile)"
    Add-Content $logFilePath $logMessage
    
    # Generate metadata for the file and save it to the CSV file
    $metadata = [PSCustomObject]@{
        Name = $file.Name
        Size = $file.Length
        CreationDate = $file.CreationTime
        ModificationDate = $file.LastWriteTime
    }
    if ($saveMetadata) {
        if (Test-Path $metadataFilePath) {
            $metadata | Export-Csv $metadataFilePath -Append -NoTypeInformation
        } else {
            $metadata | Export-Csv $metadataFilePath -NoTypeInformation
        }
    }
}
