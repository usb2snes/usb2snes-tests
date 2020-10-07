use Test;
use Usb2Snes;
use TestUsb2Snes;

init-test-data;

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
$usb2snes.rm($test-dir ~ '/test2') if 'test2' ∈ @files;
@files = $usb2snes.ls($test-dir, :timeout(1000));
ok 'test1' ∉ @files, "No test1 file, can write it";

my $file1 = Blob.new(<1 2 3>);
$usb2snes.send-file($test-dir ~ "/test1", $file1);
@files = $usb2snes.ls($test-dir, :timeout(2000)); # Creating file is slow
ok 'test1' ∈ @files, "test1 created successfully";
my Blob $upfile1 = $usb2snes.get-file($test-dir ~ "/test1");
is $file1, $upfile1, "test1 file data match";

my $file2 = $test-sram-data;
$usb2snes.send-file($test-dir ~ "/test2", $file2);
@files = $usb2snes.ls($test-dir, :timeout(2000)); # Creating file is slow
ok 'test2' ∈ @files, "test2 created successfully with testrom sram data";
my Blob $upfile2 = $usb2snes.get-file($test-dir ~ "/test2");
is $file2, $upfile2, "test2 file match sram data";

my @random-files = ('jdksjdksjdksdjsk', 'dsjkl jsdsk jdsi jsd', 'lmlmsfmfemofsmfeomofsmeofmsfo', 'dmsorfsemseomfoseomfsdmosmfmosdmofsomfmos', 'popospfospofpsofspfospfs');
my @random-dir = ('szszszszszzsz', 'abvavaavavavaavav', 'nbnbnnb  nb nb nbnbnbn');
my @expect-files;
my $subdir = $test-dir ~ '/testdir';
if 'testdir' ∈ @files {
    my @subfiles = $usb2snes.ls($subdir);
    for @subfiles {
        $usb2snes.rm($subdir ~ '/' ~ $_.name) unless $_.name eq '.' | '..';
    }
} else {
    $usb2snes.mkdir($subdir);
}
for @random-dir -> $dir {
    for 1..5 {
        sleep(0.1);
        $usb2snes.mkdir($subdir ~ '/' ~ $dir ~ $_);
        @expect-files.push($dir ~ $_);
    }
}
for @random-files -> $file {
    for 1..5 {
        sleep(0.1);
        $usb2snes.send-file($subdir ~ '/' ~ $file ~ $_, Buf.new(<1 2 3>));
        @expect-files.push($file ~ $_);
    }
}
my @subfiles = $usb2snes.ls($subdir);
@expect-files.push('.'); @expect-files.push('..');
is @expect-files.sort, (for @subfiles {$_.name}).sort, "Subdir with random files match";
$usb2snes.rm($test-dir ~ '/test1');
$usb2snes.rm($test-dir ~ '/test2');
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
