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
is $usb2snes.get-address((0xF50050, 10), (0xE00000, 10)), $test-wram-data.subbuf(0x50, 10) ~ $test-sram-data.subbuf(0, 10), "VGET with wram & sram";

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

# This test vput splicing for qusb2snes when the device does not support it
$old-data = $usb2snes.get-address(0xF50100, 20);
# do a getaddress
$usb2snes.send-command(Usb2Snes::GetAddress, 'F50100', '50');
# this should put the next put addr request in queue;
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50100', '2', 'F50102', '4', 'F50106', '4');
$usb2snes.send-data(Buf.new(<0 1 2 3 4 5 6 7 8 9>));
# data from first getaddress
$usb2snes.get-data();

ok $usb2snes.get-address(0xF50100, 10) eq Buf.new(<0 1 2 3 4 5 6 7 8 9>), "Potential vput in queue";

$usb2snes.put-address(0xF50100, $old-data);

# testing the partial data case
$usb2snes.send-command(Usb2Snes::PutAddress, 'F50100', '5', 'F50105', '2');
$usb2snes.send-data(Buf.new(<0 1 2>));
$usb2snes.send-data(Buf.new(<3 4 5>));
$usb2snes.send-data(Buf.new(<6>));

is $usb2snes.get-address(0xF50100, 7), Buf.new(<0 1 2 3 4 5 6>), "VPUT data spliced";
$usb2snes.put-address(0xF50100, $old-data);

$old-data = $usb2snes.get-address((0xF50050, 4), (0xE00000, 4));
$usb2snes.put-address(0xF50050, Buf.new(<0 1 2 3>), 0xE00000, Buf.new(<4 5 6 7>));
is $usb2snes.get-address((0xF50050, 4), (0xE00000, 4)), Buf.new(<0 1 2 3 4 5 6 7>), "VPUT wram & sram";
$usb2snes.put-address(0xF50050, $old-data.subbuf(0, 4));
$usb2snes.put-address(0xE00000, $old-data.subbuf(4, 4));

# SD2Snes firmware support up to 8 address

my @multiple = ((0xF50050, 8), (0xF50058, 0x20), (0xF50078, 8), (0xF50080, 0x10),
                (0xF50090, 1), (0xF50091, 2), (0xF50093, 0x10), (0xF500A3, 100));
my $size = 0xF50107 - 0xF50050;
is $usb2snes.get-address(|@multiple), $test-wram-data.subbuf(0x50, $size), "VGET of 8 address";
@multiple.push((0xF50107, 2));
is $usb2snes.get-address(|@multiple), $test-wram-data.subbuf(0x50, $size + 2), "VGET of 9 address, this should be split for the sd2snes";

$usb2snes.close();

done-testing;
