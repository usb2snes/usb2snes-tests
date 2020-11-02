use Test;
use TestUsb2Snes;
use Usb2Snes;

my Bool $test-ok = True;

my $usb2snes = Usb2Snes.new;
$usb2snes.connect;
$usb2snes.set-name("usb2snes get stress test");
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

sub test-wram($nb-iteration) {
    for ^$nb-iteration {
        my $wram-loc = 0x50 + (^0x1000).pick;
        my $size = (^500).pick + 4;
        my $value = $usb2snes.get-address(WRAM-START + $wram-loc, $size);
        unless $value eq $test-wram-data.subbuf($wram-loc, $size) {
            $test-ok = False;
            last;
        }
    }
}

sub pick-addr-test {
    my $domain = (^3).pick;
    my $offset = (^0x1000).pick;
    my $size = (^500).pick + 2;
    given $domain {
        when 0 {
            my $start-loc = WRAM-START + 50 + $offset;
            return ($start-loc, $size, $test-wram-data.subbuf($offset + 50, $size))
        }
        when 1 {
            my $start-loc = SRAM-START + $offset;
            return ($start-loc, $size, $test-sram-data.subbuf($offset, $size))
        }
        when 2 {
            my $start-loc = ROM-START + 0x8000 + $offset;
            return ($start-loc, $size, $test-rom-data.subbuf($start-loc, $size))
        }
    }
}

test-wram 1000;
ok $test-ok, "Running 1000 random get command in WRAM";

$test-ok = True;
for ^10_000 {
    my ($start-loc, $size, $expected-data) = pick-addr-test;
    my $value = $usb2snes.get-address($start-loc, $size);
    unless $value eq $expected-data {
        $test-ok = False;
        last;
    }
}

ok $test-ok, "Running 10.000 random get in sram/wram/rom";
my atomicint $atomic-death = 0;
my atomicint $client-id = 0;
$test-ok = True;
my Promise @clients = (^10).map: {
    start {
        my $usb2snes-client = Usb2Snes.new;
        $usb2snes-client.connect;
        $usb2snes-client.set-name("usb2snes get stress client " ~ $client-id⚛++);
        $usb2snes-client.attach: @devices.first;
        for ^1000 {
            if $atomic-death > 0 {
                die;
            }
            my ($start-loc, $size, $expected-data) = pick-addr-test;
            my $value = $usb2snes-client.get-address($start-loc, $size);
            unless $value eq $expected-data {
                $atomic-death⚛++;
                die;
            }
            sleep(0.01);
        }
        $usb2snes-client.close;
        True;
    }
}

await @clients;
$test-ok = $atomic-death == 0;
ok $test-ok, "10 clients doing 1000 get resquest";

done-testing;