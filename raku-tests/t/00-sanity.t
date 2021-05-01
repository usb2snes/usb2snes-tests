use Usb2Snes;
use Test;
use TestUsb2Snes;

init-test-data;

my $fsf-byte-count = 0x4FCA7;

is $test-rom-data.bytes, 0x20_0000,                 "Checking size of rom data";
is $test-rom-data.subbuf(0x8000, 4).decode, 'OggS', "Testing first fsf block rom data : OggS header.";
is $test-rom-data[0x57CA6], 0x92,                   "Testing end of initial fsf block";
is $test-rom-data.subbuf(0x57CA7, 4).decode, 'gOSg',"The alternate part start.";
is $test-rom-data[0xA794D], 0x92,                   "End of alternate";
is $test-rom-data[0xA794E], 0x54,                   "Start byte of fsf +5";
is $test-rom-data[0xF75F4], 0x97,                   "End of of fsf +5";
is $test-rom-data[0xF75F5], 0x59,                   "Start fsf xor 22";
is $test-rom-data[0x14729B], 0x84,                  "End of fsf xor 22";
is $test-rom-data.subbuf(0x14_729C, 4).decode,'OggS',"Start of fsf filler";
is $test-rom-data.subbuf(0x19_6F43, 4).decode,'OggS',"Another fsf filler";
is $test-rom-data.subbuf(0x1E_6BEA, 4).decode,'OggS',"Third fsf filler";
is $test-rom-data[0x1F_FFFF], 0x3D,                  "Last byte of data";

is $test-wram-data.subbuf(90, 5), Buf.new(1 xx 5), "WRAM data";

is $test-sram-data.subbuf(0, 4), Buf.new(0x65, 0x4D, 0x4D, 0x79), "1 sram block start";
is $test-sram-data.subbuf(0x1000, 4), Buf.new(0xA, 0x22, 0x22, 0x16), "2 sram block start";

init-extra-sram(4);

is $test-sram-data.subbuf(0x2000, 4),
        Buf.new($test-rom-data[0x18_0000] +^ 11, $test-rom-data[0x18_0001] +^ 11, $test-rom-data[0x18_0002] +^ 11, $test-rom-data[0x18_0003] +^ 11),
        "Extra sram start";
is $test-sram-data.subbuf(0x3000, 4),
        Buf.new($test-rom-data[0x18_0000] +^ 12, $test-rom-data[0x18_0001] +^ 12, $test-rom-data[0x18_0002] +^ 12, $test-rom-data[0x18_0003] +^ 12),
        "2 extra sram start";

done-testing;
