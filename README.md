# blackvuedownloader

FILES
- download_blackvue_bash.sh - main script that performs all functions
- blackvue_downloader.cfg - config file

Required system utilites to run
- bash
- wget
- curl

Optional system utilities if planning to use locate camera on the network
- ip
- awk
- nmap

TO-DO
Add CLI options 
- config file location, if non-specified, check same directory as script
- output directory
- camera ip
- find camera on the network
- output levels
- store files in a per-day fashion instead of all in one directory
Email report on completion

Config File Options
- specified in BASH variable format
- OUTDIR='[DIRECTORY]' specifies where to download files
- CAMERAIP='192.168.0.143' specifies where the camera is located on the network.  Can be a FQDN instead of IP

If camera IP is not specified in the config file, the script will automatically try to locate the camera.  If either camera not specified / not found or output directory is not defined, the script will exit.


