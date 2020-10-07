use Test;
use TestUsb2Snes;
use Usb2Snes;

my Bool $test-ok = True;

my $usb2snes = Usb2Snes.new;
$usb2snes.connect;
$usb2snes.set-name("usb2snes get stress test");
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

for 0..1000 {
    my $wram-loc = 0x50 + (^0x1000).pick;
    my $size = (^500).pick + 4;
    my $value = $usb2snes.get-address(WRAM-START + $wram-loc, $size);
    unless $value eq $test-wram-data.subbuf($wram-loc, $size) {
        $test-ok = False;
        last;
    }
}

ok $test-ok, "Running 1000 random get command in WRAM";

done-testing;