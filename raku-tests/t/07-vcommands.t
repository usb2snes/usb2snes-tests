use Test;
use Usb2Snes;
use TestUsb2Snes;

my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test VCommands");
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

is $usb2snes.get-address((0xF50050, 10), (0xF50070, 10)), $test-wram-data.subbuf(0x50, 10) ~ $test-wram-data.subbuf(0x70, 10), "Basic VGET";
$usb2snes.put-address((0xF50050, 4), (0xF50054, 2), Buf.new(<1 2 3 4>), Buf.new(<5 6>));

is $usb2snes.get-address(0xF500050, 6), Buf.new(<1 2 3 4 5 6>), "2 args VPUT";

$usb2snes.close();

done-testing;
