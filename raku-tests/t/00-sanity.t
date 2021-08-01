use Usb2Snes;
use Test;
use TestUsb2Snes;

init-test-data;

my $fsf-byte-count = 0x4FCA7;

is $test-rom-data.bytes, 0x20_0000,                 "Checking size of rom data";
is $test-rom-data.subbuf(0x10000, 4).decode, 'OggS', "Testing first fsf block rom data : OggS header.";
is $test-rom-data[0x5FCA6], 0x92,                   "Testing end of initial fsf block";
is $test-rom-data.subbuf(0x5FCA7, 4), 'gOSg'.encode,"The alternate part start.";
is $test-rom-data[0xAF94D], 0x92,                   "End of alternate";
is $test-rom-data[0xAF94E], 0x54,                   "Start byte of fsf +5";
is $test-rom-data[0xFF5F4], 0x97,                   "End of of fsf +5";
is $test-rom-data[0xFF5F5], 0x59,                   "Start fsf xor 22";
is $test-rom-data[0x14F29B], 0x84,                  "End of fsf xor 22";
is $test-rom-data.subbuf(0x14_F29C, 4).decode,'OggS',"Start of fsf filler";
is $test-rom-data.subbuf(0x19_EF43, 4).decode,'OggS',"Another fsf filler";
is $test-rom-data.subbuf(0x1E_EBEA, 4).decode,'OggS',"Third fsf filler";
is $test-rom-data[0x1F_FFFF], 0xAC,                  "Last byte of data";

is $test-wram-data.subbuf(90, 5), Buf.new(1 xx 5), "WRAM data";

is $test-sram-data.subbuf(0, 4), Buf.new(0x65, 0x4D, 0x4D, 0x79), "1 sram block start";
is $test-sram-data.subbuf(0x1000, 4), Buf.new(0xA, 0x22, 0x22, 0x16), "2 sram block start";

init-extra-sram(4);
#say $test-sram-data.subbuf(0x2000, 4);
is $test-sram-data.subbuf(0x2000, 4),
        Buf.new($test-rom-data[0x18_0000] +^ 11, $test-rom-data[0x18_0001] +^ 11, $test-rom-data[0x18_0002] +^ 11, $test-rom-data[0x18_0003] +^ 11),
        "Extra sram start";
is $test-sram-data.subbuf(0x3000, 4),
        Buf.new($test-rom-data[0x18_0000] +^ 12, $test-rom-data[0x18_0001] +^ 12, $test-rom-data[0x18_0002] +^ 12, $test-rom-data[0x18_0003] +^ 12),
        "2 extra sram start";

done-testing;
