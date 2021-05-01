use Test;
use Usb2Snes;
use TestUsb2Snes;

my $usb2snes = Usb2Snes.new;
say "Start";
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
is-test-rom-running($usb2snes);
init-test-data();

say "Starting test";

is $usb2snes.get-address(0xF50000 + 50, 40), Buf.new([0 xx 40]), 'WRAM D50:40 = 0...';
is $usb2snes.get-address(0xF50000 + 50 + 80, 40), Buf.new([2 xx 40]), 'WRAM D80:40 = 1...';
is $usb2snes.get-address(0xF50000 + 50 + 40 * 5, 40), Buf.new([5 xx 40]), 'WRAM D40*5:40 = 5...';

if (NO_ROM_READ.Str ∉ $infos.flags) {
    is $usb2snes.get-address(0x8000, 200), $test-rom-data.subbuf(0x8000, 200), 'ROM $8000:200 = fsf data';
    is $usb2snes.get-address(0x8000 + 0x2500, 100), $test-rom-data.subbuf(0x8000 + 0x2500, 100), 'ROM $A500:200 = fsf data';

    is $usb2snes.get-address(0x57CA7 + 42, 200), $test-rom-data.subbuf(0x57CA7 + 42, 200), 'ROM $57CA7+42:200 = fsf alternate byte data';
    say $test-rom-data.subbuf(0xA794E + 450, 200);
    say $usb2snes.get-address(0xA794E + 450, 200);
    is $usb2snes.get-address(0xA794E + 450, 200), $test-rom-data.subbuf(0xA794E + 450, 200), 'ROM $A764E+450:200 = fsf add 5 data';

    is $usb2snes.get-address(0xF75F5 + 88, 200), $test-rom-data.subbuf(0xF75F5 + 88, 200), 'ROM $F75F5+88:200 = fsf xor 22 data';
} else {
    skip  "Device does not support ROM access", 5
}

is $usb2snes.get-address(0xE00000 + 48, 100), $test-sram-data.subbuf(48, 100), "SRAM 48:100 = fsf = fsf xor 42";
is $usb2snes.get-address(0xE00000 + 0x1000, 100), $test-sram-data.subbuf(0x1000, 100), 'SRAM $1000:100 = fsf xor 69';

# Getting the sram size
init-extra-sram($usb2snes.get-address(0x7FD8, 1)[0]);
say $test-sram-data.subbuf(0x2000, 30);

is $usb2snes.get-address(0xE00000 + 0x2000, 30), $test-sram-data.subbuf(0x2000, 30), 'SRAM $2000:30 = $180000 ^ 11';

is $usb2snes.get-address(0xF50000 + 50, 550), $test-wram-data.subbuf(50, 550), "WRAM D50:550, testing sd2snes blocksize handling";

done-testing;
