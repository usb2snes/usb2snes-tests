
~/asar-1.81/src/asar/asar-standalone main_lorom.asm
cp main_lorom.sfc usb2snes-testlorom.sfc

## echo '[objects]' > dumb 
## echo 'main.obj' >> dumb

##~/wla-dx-9.10/binaries/wla-65816 -o main.obj main_hirom.asm
##~/wla-dx-9.10/binaries/wlalink dumb usb2snes-testhirom.sfc


## donwload https://www.gnu.org/music/free-software-song.ogg
if [ -f free-software-song.ogg ]; then
    echo "Already got the fsf song"
else
    wget https://www.gnu.org/music/free-software-song.ogg
fi

gcc fillrom.c -o fillrom && ./fillrom usb2snes-testlorom.sfc free-software-song.ogg LoROM
#./fillrom usb2snes-testhirom.sfc free-software-song.ogg HiROM
