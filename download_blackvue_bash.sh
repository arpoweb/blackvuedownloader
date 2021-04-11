#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# try to get information from config file if it exists in the same directory as the script
if [ -f "$DIR/blackvue_downloader.cfg" ]; then 
	source "$DIR/blackvue_downloader.cfg" 
fi

#having output directory is mandatory so check for that
if [[ -z $OUTDIR ]]; then
	echo "Directory to store videos is not defined.  Exiting"
	exit
fi

#if camera IP is not given, find it on the network
if [[ -z $CAMERAIP ]]; then
	SUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
	echo "Will search $SUBNET subnet"
	for TESTIP in `nmap -n -sn $SUBNET -oG - | awk '/Up$/{print $2}'`;
	do
		TEST_RESPONSE=$(curl -m 2 -I http://$TESTIP/blackvue_vod.cgi 2>/dev/null | head -n 1 | cut -d " " -f 2)
		if [[ ! -z $TEST_RESPONSE ]]; then
			if [[ "$TEST_RESPONSE" == "200" ]];
			then
				echo "Found blackvue camera at $TESTIP"
				CAMERAIP=$TESTIP
				break
			fi
		fi
	done
fi

CAMERA_RESPONSE=$(curl -m 2 -I http://$CAMERAIP/blackvue_vod.cgi 2>/dev/null | head -n 1 | cut -d " " -f 2)

if [[ -z $CAMERA_RESPONSE ]]; then
	echo "No response from camera.  Exiting."
	exit
fi

if [[ "$CAMERA_RESPONSE" != "200" ]];
then
	echo "Bad HTTP Code received from camera. Code received: $CAMERA_RESPONSE. Exiting"
	exit;
fi

echo "Proceeding to download videos from $CAMERAIP to $OUTDIR"

for file in `curl http://$CAMERAIP/blackvue_vod.cgi | sed 's/^n:\/Record\///'`; 
do
	IFS="," read -ra my_array  <<< $file
	FILENAME=${my_array[0]}
	if [ -s "$OUTDIR$FILENAME" ]; 
	then
		echo "Exists $FILENAME"
	else 
		echo "will download $FILENAME"
		wget -c "http://$CAMERAIP/Record/$FILENAME" -O $OUTDIR$FILENAME
	fi
	
done
