use Test;
use Usb2Snes;

my constant $test-dir = "usb2snes-tests";
my $usb2snes = Usb2Snes.new;
$usb2snes.connect;
$usb2snes.set-name: "usb2snes test control command";
my @devices =  $usb2snes.list-devices;
$usb2snes.attach: @devices.first;
my $infos = $usb2snes.device-infos;
if (NO_CONTROL_CMD.Str ∈ $infos.flags) {
    diag "The device does not support control commands, stoppping here";
    done-testing;
    exit 1;
}
unless $infos.rom-running eq '/sd2snes/menu.bin' | '/sd2snes/m3nu.bin'{
    diag "Please get the sd2snes on the menu";
    done-testing;
    exit 1;
}

my Usb2Snes::FileInfo @files = $usb2snes.ls;
$usb2snes.mkdir:$test-dir unless $test-dir ∈ @files;
my Buf $test-rom = slurp '../custom rom/usb2snes-testlorom.sfc', :bin;
@files = $usb2snes.ls: $test-dir;
$usb2snes.rm($test-dir ~ '/test-lorom.sfc') if 'test-lorom.sfc' ∈ @files;
$usb2snes.send-file($test-dir ~ '/test-lorom.sfc', $test-rom);
# there is no real way to know when a file is sent
$usb2snes.device-infos(3000);
$usb2snes.boot($test-dir ~ '/test-lorom.sfc');
sleep 2;
$infos = $usb2snes.device-infos;
is $infos.rom-running, $test-dir ~ '/test-lorom.sfc', "Started a test rom";
$usb2snes.menu;
sleep 2;
$infos = $usb2snes.device-infos;
is $infos.rom-running, '/sd2snes/menu.bin', "Getting back to menu";
$usb2snes.boot($test-dir ~ '/test-lorom.sfc');
sleep 3;
$usb2snes.reset;
sleep 3;
$infos = $usb2snes.device-infos;
is $infos.rom-running, $test-dir ~ '/test-lorom.sfc';
$usb2snes.menu;
done-testing;
