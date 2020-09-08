use Test;
use Usb2Snes;
use TestUsb2Snes;

my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test get command extras");
my @devices = $usb2snes.list-devices;
if @devices ~~ Empty {
    diag "No device available, please start one";
    done-testing;
    exit 1;
}
$usb2snes.attach: @devices.first;
my $infos = $usb2snes.device-infos;
is-test-rom-running($usb2snes);


init-test-data;

# These tests are intended for emu device, reading in bank boundaries
# or overlapping memory read

ok $usb2snes.get-address(0xFFFF, 200) eq $test-rom-data.subbuf(0xFFFF, 200), 'ROM $FFFF:200, end of bank $00';

#just before the wram
my $data = $usb2snes.get-address(0xF50000 - 2, 200);
is-deeply $data.subbuf(52, 20), $test-wram-data.subbuf(50, 20), "Just before the wram then the wram";

# the whole sram, can be divided on multiple banks on hirom?

ok $usb2snes.get-address(0xE00000, 0x2000) eq $test-sram-data, "Whole SRAM";

done-testing;
