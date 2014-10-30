echo -e "Filename for recording: \c "
read filename
echo "Saving to ${filename}.mp4"
adb pull /sdcard/${filename}.mp4 ${filename}.mp4
echo "Done"
