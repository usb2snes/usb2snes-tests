rm main.obj
rm dumb

echo '[objects]' > dumb 
echo 'main.obj' >> dumb

~/wla-dx-9.10/binaries/wla-65816 -o main.obj main.asm
~/wla-dx-9.10/binaries/wlalink -v dumb usb2snes-testlorom.sfc

## donwload https://www.gnu.org/music/free-software-song.ogg


gcc adddatatorom.c -o adddatatorom
./adddatatorom usb2snes-testlorom.sfc free-software-song.ogg
