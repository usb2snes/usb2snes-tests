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
is $usb2snes.get-address((0xF50050, 0x10), (0xF50060, 0x10), (0xF50070, 0x10), (0xF50080, 0x10)), $test-wram-data.subbuf(0x50, 0x40), "VGET with 4 args";

my $old-data = $usb2snes.get-address(0xF50050, 6);
$usb2snes.put-address(0xF50050, Buf.new(<1 2 3 4>), 0xF50054, Buf.new(<5 6>));
is $usb2snes.get-address(0xF50050, 6), Buf.new(<1 2 3 4 5 6>), "2 args VPUT";
$usb2snes.put-address(0xF50050, $old-data);

$usb2snes.put-address(0xF50050, Buf.new(<1 2>), 0xF50052, Buf.new(<3 4>) , 0xF50054, Buf.new(<5 6>));
is $usb2snes.get-address(0xF50050, 6), Buf.new(<1 2 3 4 5 6>), "3 args VPUT";
$usb2snes.put-address(0xF50050, $old-data);

# This is like the worse thing xD
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50051', '1');
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50050', '1', 'F50052', '1', 'F50054', '1');
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50053', '1');
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50055', '1');
$usb2snes.send-data(Buf.new(<2>));
$usb2snes.send-data(Buf.new(<1 3 5>));
$usb2snes.send-data(Buf.new(<4>));
$usb2snes.send-data(Buf.new(<6>));

is $usb2snes.get-address(0xF50050, 6), Buf.new(<1 2 3 4 5 6>), "1 Put, 1 VPUT(3), 1 Put, 1 Put";
$usb2snes.put-address(0xF50050, $old-data);

#Vcmd limit is 64 bytes
#$usb2snes.get-address((0xF50050, 56), (0xF50050, 20));
#ok $usb2snes.closed, "Invalid total lenght close the connection";

$usb2snes.close();

done-testing;
