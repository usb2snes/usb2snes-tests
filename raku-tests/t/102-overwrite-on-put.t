use Test;
use Usb2Snes;

my $usb2snes = Usb2Snes.new();
$usb2snes.connect;
$usb2snes.set-name: "usb2snes test, overwrite put cmd";
my @devices = $usb2snes.list-devices;
$usb2snes.attach(@devices.first);

$usb2snes.send-command(Usb2Snes-Opcode::PutAddress, 'F50000', '3');
$usb2snes.write(Blob.new(<1 2 3>));
die-ok { $usb2snes.write(Blob.new(<1 2 3>)) }, "Writing more than the size should close the connection";

done-testing;
