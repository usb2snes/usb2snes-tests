use Test;
use TestUsb2Snes;
use Usb2Snes;

my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test puts command");
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
my $old-data = $usb2snes.get-address(0xF50000 + 200, 3);
$usb2snes.put-address(0xF50000 + 200, Buf.new(<1 2 3>));
ok $usb2snes.get-address(0xF50000 + 200, 3) eq Buf.new(<1 2 3>), "Writing into WRAM";
$usb2snes.put-address(0xF50000 + 200, $old-data);

$old-data = $usb2snes.get-address(0xE00000, 20);
$usb2snes.put-address(0xE00000, Buf.new([42 xx 20]));
ok $usb2snes.get-address(0xE00000, 20) eq Buf.new([42 xx 20]), "Writing into SRAM";
$usb2snes.put-address(0xE00000, $old-data);

if (NO_ROM_READ.Str ∉ $infos.flags && NO_ROM_WRITE.Str ∉ $infos.flags) {
    $old-data = $usb2snes.get-address(0x8000, 10);
    $usb2snes.put-address(0x8000, Buf.new([58 xx 10]));
    ok $usb2snes.get-address(0x8000, 10) eq Buf.new([58 xx 10]), "Writing into ROM";
    $usb2snes.put-address(0x8000, $old-data);

} else {
    skip "No ROM access", 1;
}

# Trying the queue system
$old-data = $usb2snes.get-address(0xF50100, 20);

$usb2snes.send-command(Usb2Snes::PutAddress, 'F50100', '3');
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50103', '3');
$usb2snes.send-data(Buf.new(<1 2 3>));
$usb2snes.send-data(Buf.new(<4 5 6>));

ok $usb2snes.get-address(0xF50100, 6) eq Buf.new(<1 2 3 4 5 6>), "2 putaddress request, then data";

$usb2snes.send-command(Usb2Snes::PutAddress, 'F50106', '3');
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50109', '3');
$usb2snes.send-data(Buf.new(<7 8 9>));
$usb2snes.send-command(Usb2Snes::PutAddress, 'F5010C', '3');
$usb2snes.send-data(Buf.new(<10 11 12>));
$usb2snes.send-data(Buf.new(<13 14 15>));

ok $usb2snes.get-address(0xF50106, 9) eq Buf.new(<7 8 9 10 11 12 13 14 15>), "2 putaddress request, 1 data, 1 put, 2 data";

$usb2snes.put-address(0xF50100, $old-data);

done-testing;
