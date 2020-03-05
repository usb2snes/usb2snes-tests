use Test;
use Usb2Snes;

my constant $test-dir = "usb2snes-tests";
my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test file command");
my @devices = $usb2snes.list-devices;
if @devices ~~ Empty {
    diag "No device available, please start one";
    done-testing;
    exit 1;
}
$usb2snes.attach: @devices.first;
if (NO_FILE_CMD.Str ∈ $usb2snes.device-infos.flags) {
    diag "The device does not support file command, stoppping here";
    done-testing;
    exit 1;
}
my Usb2Snes::FileInfo @files = $usb2snes.ls;
say @files.elems;
say @files.perl;
say @files.of;
ok "sd2snes" ∈ @files, "Contains the sd2snes folder";

$usb2snes.mkdir($test-dir) unless $test-dir (elem) @files;
@files = $usb2snes.ls;
ok $test-dir ∈ @files, "$test-dir already here or created";

@files = $usb2snes.ls($test-dir);
$usb2snes.rm($test-dir ~ '/test1') if 'test1' ∈ @files;
@files = $usb2snes.ls($test-dir, :timeout(1000));
ok 'test1' ∉ @files, "No test1 file, can write it";
my $file1 = Blob.new(<1 2 3>);
$usb2snes.send-file($test-dir ~ "/test1", $file1);
@files = $usb2snes.ls($test-dir, :timeout(2000)); # Creating file is slow
ok 'test1' ∈ @files, "test1 created successfully";
my Blob $upfile1 = $usb2snes.get-file($test-dir ~ "/test1");
is $file1, $upfile1, "test1 file data match";
$usb2snes.rm($test-dir ~ '/test1');
@files = $usb2snes.ls($test-dir, :timeout(1000));
ok 'test1' ∉ @files, "test1 removed succesfully";
$usb2snes.rm($test-dir ~ '/piko') if 'piko' ∈ @files;
$usb2snes.mkdir($test-dir ~ '/piko');
@files = $usb2snes.ls($test-dir ~ '/piko', :timeout(2000));
ok '.' ∈ @files, "piko directory successfully created";
$usb2snes.rm($test-dir ~ '/piko');
@files = $usb2snes.ls($test-dir, :timeout(1000));
ok 'piko' ∉ @files, "piko directory removed succesfully";

if ('../custom rom/usb2snes-testlorom.sfc'.IO ~~ :e) {
    my Buf $test-rom = slurp '../custom rom/usb2snes-testlorom.sfc', :bin;
    @files = $usb2snes.ls: $test-dir;
    $usb2snes.rm($test-dir ~ '/test-lorom.sfc') if 'test-lorom.sfc' ∈ @files;
    $usb2snes.send-file($test-dir ~ '/test-lorom.sfc', $test-rom);
    my $test-rom-got = $usb2snes.get-file($test-dir ~ '/test-lorom.sfc');
    is $test-rom-got, $test-rom, "";
}

done-testing;
