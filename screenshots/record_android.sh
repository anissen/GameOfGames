echo -e "Filename for recording: \c "
read filename
echo "Recording screen..."
adb shell screenrecord --bit-rate 6000000 /sdcard/${filename}.mp4
