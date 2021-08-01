use Test;
use Usb2Snes;

my $usb2snes = Usb2Snes.new;

ok $usb2snes.connect(), "Connecting";
$usb2snes.set-name: "usb2snes test connect";
diag "Testing a usb2snes server v" ~ $usb2snes.server-version;
my @devices = $usb2snes.list-devices;
ok @devices, "Listing device";
$usb2snes.attach: @devices.first;
my $infos = $usb2snes.device-infos;
diag "Device name : " ~ $infos.name;
ok $infos.name, "Getting the device name";

done-testing;
