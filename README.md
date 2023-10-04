# IMA SDK Sample for ads on live streaming

## Requirements
- ffmpeg
- python3

## Usage

1. Prepare HLS server 
```
$ make -c server playlist
$ make -c server server
``` 

2. Modify URL of HLS server in ViewController and run the app