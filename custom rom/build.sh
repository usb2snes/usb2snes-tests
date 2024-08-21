
~/asar-1.81/src/asar/asar-standalone main_lorom.asm
cp main_lorom.sfc usb2snes-testlorom.sfc

~/asar-1.81/src/asar/asar-standalone main_hirom.asm
cp main_hirom.sfc usb2snes-testhirom.sfc

~/asar-1.81/src/asar/asar-standalone main_exhirom.asm
cp main_exhirom.sfc usb2snes-testexhirom.sfc


## donwload https://www.gnu.org/music/free-software-song.ogg
if [ -f free-software-song.ogg ]; then
    echo "Already got the fsf song"
else
    wget https://www.gnu.org/music/free-software-song.ogg
fi

gcc fillrom.c -o fillrom
./fillrom usb2snes-testlorom.sfc free-software-song.ogg LoROM 
./fillrom usb2snes-testhirom.sfc free-software-song.ogg HiROM
./fillrom usb2snes-testexhirom.sfc free-software-song.ogg ExHiROM

