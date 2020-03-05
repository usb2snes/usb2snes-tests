use Test;
use Usb2Snes;

# Request stall after receiving a device error with sd2snes
# Sometimes?

my $usb2snes = Usb2Snes.new();
$usb2snes.connect('test-stalling-after-error');
my @devices = $usb2snes.list-devices;
$usb2snes.attach(@devices.first);
if (NO_FILE_CMD.Str ∈ $usb2snes.device-infos.flags) {
    diag "The device does not support file command, stoppping here";
    done-testing;
}
my @files = $usb2snes.ls;
$usb2snes.mkdir('ilfaitbeaudir') if 'ilfaitbeaudir' ∉ @files;
$usb2snes.mkdir('ilfaitbeaudir'); # This will fail as the directory exists
sleep(1);
$usb2snes.connect('test-stalling-after-error');
my @devices = $usb2snes.list-devices;
$usb2snes.attach(@devices.first);
ok $usb2snes.device-infos ~~ Nil;

done-testing;
