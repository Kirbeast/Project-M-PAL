<#
.SYNOPSIS
   This is a PowerShell Script that relies on GSAR (General Search And Replace) to batch replace hex strings (can make X different replacements, of Y occurrences, in Z different files).
   
.DESCRIPTION
   This script helps you by coordinating multiple calls to GSAR (allowing the said X different replacements) and also by providing a convenient input format: it gets all the changes to be made from a file, a list written by you.
   GSAR is simple and fast, but inflexible. No wildcards or regular expressions are allowed in search string. Also you can't skip a digit when replacing (if nothing is written as a replacement, the digit is deleted). GSAR always replaces all occurrences of searched strings in each file (say Y ocurrences), it's not optional.
   GSAR can be found here: http://gnuwin32.sourceforge.net/packages/gsar.htm
   Setup: put gsar.exe in C:\WINDOWS, keep gsar-man.pdf somewhere accessible and setup VC6RedistSetup_deu.exe if you lack msvcrt.dll and msvcp60.dll in your system folder (Windows\System or WINDOWS\system32). You can throw remaining files away.

.PARAMETER gsarImportPath
   First parameter (no need to write "-gsarImportPath") expects the path to a properly written txt file with a list of changes to be done ("C:\Path\GSARimport.txt"). This file is supposed to have each line in the following format (and is only a bunch of these lines):
   "NAME", "FIND", "REPLACE"
   Where:
   - NAME = A name/description for your convenience (so you remember what that line was about).
   - FIND = Hex String to search for.
   - REPLACE = Hex String to use as replacement.
   Example:
   "Yellow", "46 61 63 65 64 20 77 69 74 68 20", "65 6C 6C 6F 77 54 75 72 62 61 6E"
   Note: Follow this exact format, don't add/remove any quote, comma or blank space, if you do (add/remove) the line will be skipped and no change applied (or you'll get a gsar error report, but hardly worse than that).

.PARAMETER filesPath
   Second parameter (no need to write "-filesPath") expects the path to a folder containing the hex files to be changed ("C:\Path"). Note: Changes will apply to all files in the specified folder that match the extension given (see next parameter).

.PARAMETER ext
   Third parameter (no need to write "-ext") expects an extension, without the dot ("s11"). This helps filtering unwanted files a bit.

.PARAMETER noBackup
   Optional parameter (must write "-noBackup"), allows you to skip the auto backup.

.EXAMPLE
   ... Usage:
   1- Create a file with lines formated as stated above (1st parameter)
   2- Create a folder and put the files you want changed there (2nd parameter)
   3- All files must have same extension (3rd parameter)
   4- Call this script via powershell:
      a) Example with backup (put parameters in this order):
         .\ROTK_XI_gsar_v3.ps1 "C:\Path\GSAR Import.txt" "C:\Path\Test" "s11"
      b) Example without backup (put parameters in this order):
         .\ROTK_XI_gsar_v3.ps1 "C:\Path\GSAR Import.txt" "C:\Path\Test" "s11" -noBackup
   5- Check the generated gsarLog saved in the same folder of the input files (2nd parameter). That's important as it'll allow you to easily check whether or not everything was changed, or if something wasn't changed, or even if something that should not be changed was so. The log tells you the number of matches of change "Whatever" (the name you gave for the change in your file will be displayed) in each file (tells you nothing when no matches are found). Also tells you if a line could not be read and was skipped.
#>

# Definition of parameters taken as input by this script
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)] [string]$gsarImportPath,
   [Parameter(Mandatory=$True,Position=2)] [string]$filesPath,
   [Parameter(Mandatory=$True,Position=3)] [string]$ext,
   [Parameter(Mandatory=$FALSE)] [switch] $noBackup
)

#-----------------------------------------------------------------------------------------------

# Function equivalent to PAUSE from DOS (pauses execution until a key is pressed)
function WaitKey
{ 
    param( [String] $strPrompt = "Press any key to continue ... ") 
    Write-Host 
    Write-Host $strPrompt -NoNewline 
    $key = [Console]::ReadKey($true) 
    Write-Host 
} 

#-----------------------------------------------------------------------------------------------

# Function that backup files (only those that'll be changed)
function BackupFiles ($SourceFolder)
{
   # Create backup folder
   $date = (Get-Date).tostring("yyyy-MM-dd_HH-mm-ss")
   $DestinationFolder = "$SourceFolder\Backup_" + $date
   if(!(test-path "$DestinationFolder" -pathType container)) 
   { 
      New-Item -ItemType directory -Path $DestinationFolder
   } 
   
   # Copy-Rename Files
   $aux = $SourceFolder + "\" + "*.s11"
   $filenames = @(Get-ChildItem $aux)
   foreach ($file in $filenames)
   {
      $fileLeaf = Split-Path "$file" -Leaf
      $bakfile = $fileLeaf + ".bak"
        Copy-Item $file "$DestinationFolder"
      Rename-Item "$DestinationFolder\$fileLeaf" $bakfile
   }
}

#-----------------------------------------------------------------------------------------------

# GSAR requires the hex strings to be written in an specific format
# This function does the convertion
function ConvertToGsarInput ($gsar_input)
{
   $gsar_input = $gsar_input -replace ' ', ':x'
   return ("$gsar_input")
}

#-----------------------------------------------------------------------------------------------
# Main
#-----------------------------------------------------------------------------------------------

# Display error and exit script if 2nd parameter points inexistent folder path
if(!(test-path "$filesPath" -pathType container))
{ 
   Write-Host "Error: source folder does not exist!" -ForegroundColor "Red" 
   Write-Host "Exiting script" 
   WaitKey "Press any key to exit ... " 
   exit 
} 

# Actual backup
if (-not $noBackup)
{
   BackupFiles ($filesPath)
}

# Create LOG file
$enddate = (Get-Date).tostring("yyyy-MM-dd_HH-mm-ss")
#$filename = "FileName{0:yyyyMMdd-HHmm}" -f (Get-Date)
$logname = "gsarLog_"+$enddate+".txt"
Set-Content -path "$filesPath\$logname" -value "`r`n===============`r`n-GSAR LOG FILE-`r`n==============="

# For each change in the list txt call gsar (applying them to all hex files)
# And, for each call, register changes to LOG file
$lines = Get-Content ($gsarImportPath)
#$lines = (Get-Content ($gsarImportPath) | Measure-Object –Line ).Lines;
for ($i=0; $i -lt $lines.count; $i++)
{
   $ffile = (Get-Content "$gsarImportPath")[$i]
   if ($ffile -like "`"*`", `"*`", `"*`"")
   {
      $line = $ffile -split ", "
      $l1 = $line[0]
      $l2 = $line[1]
      $l3 = $line[2]
      Add-Content -path "$filesPath\$logname" -value "`r`n`r`n---$l1---"
      $a = ConvertToGsarInput (" $l2")
      $b = ConvertToGsarInput (" $l3")
      Push-Location $filesPath
      gsar "-s$a" "-r$b" "-o" "*.$ext" | Add-Content "$filesPath\$logname"
      Pop-Location
   } else
   {
      if ($ffile -eq "")
      {
         Add-Content -path "$filesPath\$logname" -value "`r`n`r`n---Incorrect input line skipped---`r`n<empty line>"
      }else
      {
         Add-Content -path "$filesPath\$logname" -value "`r`n`r`n---Incorrect input line skipped---`r`n$ffile"
      }
   }
}
Add-Content -path "$filesPath\$logname" -value "`r`n`r`n==============`r`n-GSAR LOG END-`r`n=============="

#-----------------------------------------------------------------------------------------------
# END