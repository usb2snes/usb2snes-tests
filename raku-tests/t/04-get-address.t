use Test;
use Usb2Snes;
use TestUsb2Snes;

my $usb2snes = Usb2Snes.new;

$usb2snes.connect;
$usb2snes.set-name("usb2snes test get command");
my @devices = $usb2snes.list-devices;
if @devices ~~ Empty {
    diag "No device available, please start one";
    done-testing;
    exit 1;
}
$usb2snes.attach: @devices.first;
my $infos = $usb2snes.device-infos;
is-test-rom-running($usb2snes);
init-test-data();

#Copy of free-software-song.ogg starting at $8000
#Copy alternating bytes of free-software-song.ogg at $57CA7
#Copy free-software-song.ogg byte +5 at $A794E
#Copy free-software-song.ogg XOR 22 at $F75F5

#WRAM is set to 0 up to 50 then it's 40 bytes of 0, 40 bytes of 1, ect...

#SRAM $0-$1000 is xor 42 (decimal) of the second bank ($01) $1000-$2000 is xor 69 (decimal)

my $fsf-song = '../custom rom/free-software-song.ogg'.IO.slurp(:bin);

my $fsf-alt = Buf.new($fsf-song.bytes);
loop (my $i = 0; $i < $fsf-song.bytes - 1; $i += 2) {
    $fsf-alt[$i] = $fsf-song[$i + 1];
    $fsf-alt[$i + 1] = $fsf-song[$i];
}
my $fsf-add5 = Buf.new($fsf-song.bytes);
loop ($i = 0; $i < $fsf-song.bytes - 1; $i++) {
    $fsf-add5[$i] = $fsf-song[$i] + 5;
}
my $fsf-xor22 = Buf.new($fsf-song.bytes);
loop ($i = 0; $i < $fsf-song.bytes - 1; $i++) {
    $fsf-xor22[$i] = $fsf-song[$i] +^ 22;
}

my $sram = Buf.new(0x2000);
loop ($i = 0; $i < 0x1000; $i++) {
    $sram[$i] = $fsf-song[$i] +^ 42;
}
loop ($i = 0x1000; $i < 0x2000; $i++) {
    $sram[$i] = $fsf-song[$i - 0x1000] +^ 69;
}



ok $usb2snes.get-address(0xF50000 + 50, 40) eq Buf.new([0 xx 40]), 'WRAM D50:40 = 0...';
ok $usb2snes.get-address(0xF50000 + 50 + 80, 40) eq Buf.new([2 xx 40]), 'WRAM D80:40 = 1...';
ok $usb2snes.get-address(0xF50000 + 50 + 40 * 5, 40) eq Buf.new([5 xx 40]), 'WRAM D40*5:40 = 5...';

if (NO_ROM_READ.Str ∉ $infos.flags) {
    ok $usb2snes.get-address(0x8000, 200) eq $fsf-song.subbuf(0, 200), 'ROM $8000:200 = fsf data';
    ok $usb2snes.get-address(0x8000 + 0x2500, 100) eq $fsf-song.subbuf(0x2500, 100), 'ROM $A500:200 = fsf data';

    ok $usb2snes.get-address(0x57CA7 + 42, 200) eq $fsf-alt.subbuf(42, 200), 'ROM $57CA7+42:200 = fsf alternate byte data';

    ok $usb2snes.get-address(0xA794E + 450, 200) eq $fsf-add5.subbuf(450, 200), 'ROM $A764E+450:200 = fsf add 5 data';

    ok $usb2snes.get-address(0xF75F5 + 88, 200) eq $fsf-xor22.subbuf(88, 200), 'ROM $F75F5+88:200 = fsf xor 22 data';
} else {
    skip  "Device does not support ROM access", 5
}

ok $usb2snes.get-address(0xE00000 + 48, 100) eq $sram.subbuf(48, 100), "SRAM 48:100 = fsf = fsf xor 42";
ok $usb2snes.get-address(0xE00000 + 0x1000, 100) eq $sram.subbuf(0x1000, 100), 'SRAM $1000:100 = fsf xor 69';

ok $usb2snes.get-address(0xF50000 + 50, 550) eq $test-wram-data.subbuf(50, 550), "WRAM D50:550, testing sd2snes blocksize handling";

done-testing;
