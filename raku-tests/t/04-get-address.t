use Test;

my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test get command");
my @devices = $usb2snes.list-devices;
if @devices ~~ Empty {
    diag "No device available, please start one";
    done-testing;
    exit 1;
}
$usb2snes.attach: @devices.first;
my $infos = $usb2snes.device-infos;
unless $infos.rom-running eq '/usb2snes-tests/test-lorom.sfc' | '/usb2snes-tests/test-hirom.sfc' | '/usb2snes-tests/test-exhirom.sfc'
        | 'USB2SNES Test LoROM  ' | 'USB2SNES Test HiROM  ' | 'USB2SNES Test ExHiROM' {
    diag "Not running one of the test rom";
    done-testing;
    exit 1;
}

my $fsf-song = '../../custom rom/free-software-song.ogg'.IO.slurp, :bin;

is $usb2snes.get-address(0xF50000 + 50, 40), Blob.new([0 xx 40]), 'WRAM D50:40 = 0...';
is $usb2snes.get-address(0xF50000 + 50 + 160), Blob.new([3 xx 40]), 'WRAM D160:40 = 3...';

is $usb2snes.get-address(0x8000, 200), $fsf-song.subbuf(0, 200), 'ROM $8000:200 = fsf data';
is $usb2snes.get-address(0x8000 + 0x2500, 100); $fsf-song.subbuf(0x2500, 100), 'ROM $A500:200 = fsf data';



done-testing;
