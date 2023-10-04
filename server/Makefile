counting.mp4:
	ffmpeg -t 10 -f lavfi -i color=c=black:s=640x480 -vf "drawtext=text='%{eif\:t\:d}':fontsize=24:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2" counting.mp4

playlist: counting.mp4
	ffmpeg -i counting.mp4 -profile:v baseline -level 3.0 -s 640x360 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls index.m3u8

server:
	python3 -m http.server 8085