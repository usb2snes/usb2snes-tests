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

$test-ok = True;
for ^1000 {
    my Buf $gen-data = Buf.new;
    my $wram-loc = WRAM-START + 0x50 + (^0x1000).pick;
    my $size = (^500).pick + 4;
    my $old-data = $usb2snes.get-address($wram-loc, $size);
    unless $old-data eq $test-wram-data.subbuf($wram-loc - WRAM-START, $size) {
        $test-ok = False;
        last
    }
    for 1..$size {
        $gen-data.append((^255).pick);
    }
    $usb2snes.put-address($wram-loc, $gen-data);
    unless $usb2snes.get-address($wram-loc, $size) eq $gen-data {
        $test-ok = False;
        last
    }
    $usb2snes.put-address($wram-loc, $old-data);
}

ok $test-ok, "1000 Put request (+2000 gets)";