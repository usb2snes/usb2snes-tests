use Test;
use Usb2Snes;
use TestUsb2Snes;

my Int $snes-sram-size = 0;
$snes-sram-size = @*ARGS[0].Int() if (@*ARGS.elems == 1);

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
    is $usb2snes.get-address($test-rom-data-start, 200), $test-rom-data.subbuf($test-rom-data-start, 200), "ROM {$test-rom-data-start.base(16)}:200 = fsf data";
    is $usb2snes.get-address($test-rom-data-start + 0x2500, 100), $test-rom-data.subbuf($test-rom-data-start + 0x2500, 100), "ROM {($test-rom-data-start + 0x2500).base(16)}200 = fsf data";

    is $usb2snes.get-address(0x5FCA7 + 42, 200), $test-rom-data.subbuf(0x5FCA7 + 42, 200), 'ROM $5FCA7+42:200 = fsf alternate byte data';
    is $usb2snes.get-address(0xAF94E + 450, 200), $test-rom-data.subbuf(0xAF94E + 450, 200), 'ROM $AF94E+450:200 = fsf add 5 data';

    is $usb2snes.get-address(0xFF5F5 + 88, 200), $test-rom-data.subbuf(0xFF5F5 + 88, 200), 'ROM $FF5F5+88:200 = fsf xor 22 data';
} else {
    skip  "Device does not support ROM access", 5
}

is $usb2snes.get-address(0xE00000 + 48, 100), $test-sram-data.subbuf(48, 100), "SRAM 48:100 = fsf = fsf xor 42";
is $usb2snes.get-address(0xE00000 + 0x1000, 100), $test-sram-data.subbuf(0x1000, 100), 'SRAM $1000:100 = fsf xor 69';

# Getting the sram size

#say "plop", $snes-sram-size;
if (NO_ROM_READ.Str ∉ $infos.flags || $snes-sram-size != 0) {
    $snes-sram-size = $usb2snes.get-address(0x7FD8, 1)[0] if NO_ROM_READ.Str ∉ $infos.flags;
    init-extra-sram($snes-sram-size);
    #say $test-sram-data.subbuf(0x2000, 30);
    my $plop = $usb2snes.get-address(0xE00000 + 0x2000, 30);
    #say $plop;
    is $usb2snes.get-address(0xE00000 + 0x2000, 30), $test-sram-data.subbuf(0x2000, 30), 'SRAM $2000:30 = $180000 ^ 11';
} else {
    skip "No ROM read available, can't know extra sram", 1;
}

is $usb2snes.get-address(0xF50000 + 50, 550), $test-wram-data.subbuf(50, 550), "WRAM D50:550, testing sd2snes blocksize handling";

done-testing;
