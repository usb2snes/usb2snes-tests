unit module TestUsb2Snes;
use Test;

our constant $test-dir is export = "usb2snes-tests";
our $test-rom-data is export;
our $test-sram-data is export;
our $test-wram-data is export;

my constant $fsf-song-path = '../custom rom/free-software-song.ogg';

sub is-test-rom-running($usb2snes) is export {
    my $infos = $usb2snes.device-infos;
    unless $infos.rom-running eq '/usb2snes-tests/test-lorom.sfc' | '/usb2snes-tests/test-hirom.sfc' | '/usb2snes-tests/test-exhirom.sfc'
            | 'USB2SNES Test LoROM  ' | 'USB2SNES Test HiROM  ' | 'USB2SNES Test ExHiROM'  || $infos.rom-running ~~ /"usb2snes-testlorom.sfc"/ {
        diag "Not running one of the test rom";
        done-testing;
        exit 1;
    }
    True
}

#Copy of free-software-song.ogg starting at $8000
#Copy alternating bytes of free-software-song.ogg at $57CA7
#Copy free-software-song.ogg byte +5 at $A794E
#Copy free-software-song.ogg XOR 22 at $F75F5

#WRAM is set to 0 up to 50 then it's 40 bytes of 0, 40 bytes of 1, ect...

#SRAM $0-$1000 is xor 42 (decimal) of the second bank ($01) $1000-$2000 is xor 69 (decimal)


sub init-test-data is export {
    my $fsf-song = $fsf-song-path.IO.slurp(:bin);

    my $fsf-alt = Buf.new($fsf-song.bytes);
    loop (my $i = 0; $i < $fsf-song.bytes - 1; $i += 2) {
        $fsf-alt[$i] = $fsf-song[$i + 1];
        $fsf-alt[$i + 1] = $fsf-song[$i];
    }
    $fsf-alt[$i] = $fsf-song[$i];
    my $fsf-add5 = Buf.new($fsf-song.bytes);
    loop ($i = 0; $i < $fsf-song.bytes; $i++) {
        $fsf-add5[$i] = $fsf-song[$i] + 5;
    }
    my $fsf-xor22 = Buf.new($fsf-song.bytes);
    loop ($i = 0; $i < $fsf-song.bytes; $i++) {
        $fsf-xor22[$i] = $fsf-song[$i] +^ 22;
    }

    my $sram = Buf.new(0x2000);
    loop ($i = 0; $i < 0x1000; $i++) {
        $sram[$i] = $fsf-song[$i] +^ 42;
    }
    loop ($i = 0x1000; $i < 0x2000; $i++) {
        $sram[$i] = $fsf-song[$i - 0x1000] +^ 69;
    }
    $test-sram-data = $sram;
    $test-rom-data = Buf.new;
    $test-rom-data.append(Buf.new([0 xx 0x8000]));
    $test-rom-data.append($fsf-song);
    $test-rom-data.append($fsf-alt);
    $test-rom-data.append($fsf-add5);
    $test-rom-data.append($fsf-xor22);
    my $fsf-offset = 0;
    loop ($i = $test-rom-data.bytes; $i < 0x20_0000; $i++) {
        if ($fsf-offset == $fsf-song.bytes)
        {
            $fsf-offset = 0;
        }
        $test-rom-data[$i] = $fsf-song[$fsf-offset];
        $fsf-offset++
    }

    $test-wram-data = Buf.new;
    $test-wram-data.append(Buf.new([0 xx 50]));
    my $cpt = 0;
    loop ($i = 49; $i < 0x2000; $i++) {
        $test-wram-data[$i] = $cpt;
        $cpt++ if (($i != 49) && (($i - 49) % 40 == 0));
    }
}

sub init-extra-sram(Int $size is copy) is export {
    #say "size", $size;
    if ($size < 10) {
        $size = 0x400 +< $size
    }
    return unless ($size > 0x2000);
    #say "size : $size";
    $size -= 0x2000;
    my $start-xor = 11;
    my $sram = Buf.new(0x1000);
    my $i;
    for ^($size / 0x1000) {
        loop ($i = 0; $i < 0x1000; $i++) {
            $sram[$i] = $test-rom-data[0x180000 + $i] +^ $start-xor;
        }
        $test-sram-data.append($sram);
        $start-xor++;
    }
}