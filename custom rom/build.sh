rm main.obj
rm dumb

echo '[objects]' > dumb 
echo 'main.obj' >> dumb

~/wla-dx-9.10/binaries/wla-65816 -o main.obj main_lorom.asm
~/wla-dx-9.10/binaries/wlalink -v dumb usb2snes-testlorom.sfc


## donwload https://www.gnu.org/music/free-software-song.ogg
if [ -f free-software-song.ogg ]; then
    echo "Already got the fsf song"
else
    wget https://www.gnu.org/music/free-software-song.ogg
fi

gcc fillrom.c -o fillrom && ./fillrom usb2snes-testlorom.sfc free-software-song.ogg
