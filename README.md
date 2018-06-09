Bios and Word script for Dell 5440
version 1.14

Mind that the description of the scripts is outdated, still gives an understanding of what is going on.

These batch scripts will:

"Dell5440_bios_update.bat"
* Move newfile.bat to start folder
* Update the BIOS version and reboot

"newfile.bat"
* Update the time server settings and resync
* Force Office 2010-2016 to activate licens
* Open Word, so the user can see that it is working
* Ask the user if it's time to shutdown PC, if so: Reactivate UAC, delete BIOS Update file from desktop, prepare shutdown and delete the script

How to install:
* Make sure this folder is unzipped.
* Run install.bat
PC is now ready for production.

or do it manually:

* You need to make sure that UAC is disabled. This is best done by running "UAC_disable.bat" inside this folder. 
* Place "newfile.bat" and "E544018.exe" on desktop.
* Place "Dell5440_bios_update.bat" in the start folder. Can be accessed by opening windows explorer and putting this in the directory: %userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

Changelog:
* 1.00: First release
* 1.11: Updated Standard script to 1.02b
* 1.12: Updated install.bat with bcdedit /timeout 0, so we are on Standard Script 1.03b
* 1.13: Started using variables and added check if BIOS is already greater than update.
	  Updated activation script to current (1.07)
* 1.13_2: Fixed the deletion of BIOS after update.
* 1.14: Fixed reboot problem. Changed interaction with BiosUpdate. Added logic to run Activation if Bios is up to date. Cleaned up some small errors. 

For people looking to update the Bios update:
http://www.dell.com/support/home/dk/da/dkbsdt1/product-support/servicetag/6yrzg12/drivers

