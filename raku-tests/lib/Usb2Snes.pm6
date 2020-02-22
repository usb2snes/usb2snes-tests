use Cro::WebSocket::Client;

use JSON::Fast;

unit class Usb2Snes;

enum Usb2Snes-Opcode <
    DeviceList
    Attach
    AppVersion
    Name
    Info
    Boot
    Menu
    Reset
    Stream
    Fence
    GetAddress
    PutAddress
    PutIPS
    GetFile
    PutFile
    List
    Remove
    Rename
    MakeDir
>;

enum Usb2Snes-Flag is export <NO_FILE_CMD NO_CONTROL_CMD NO_ROM_WRITE NO_ROM_READ>;
enum file-type (DIR => 0, FILE => 1);

my class DeviceInfo is export {
    has Str $.name;
    has Str $.rom-running;
    has $.version;
    has @.flags;
}

our class FileInfo {
    has Str $.name;
    has file-type $.type;
}

multi sub infix:<(elem)>(Str $name , @list where @list ~~ Array[FileInfo]) returns Bool:D is export {
    for @list {
        return True if $_.name eq $name;
    }
    False;
}

multi sub infix:<∈>(Str $name , @list where @list ~~ Array[FileInfo] --> Bool:D) is export {
    $name (elem) @list;
}

multi sub infix:<∉>(Str $name , @list where @list ~~ Array[FileInfo] --> Bool:D) is export {
    !($name (elem) @list);
}

constant $usb2snes-url = "ws://localhost:8080";

has Cro::WebSocket::Client::Connection $!ws;

method connect {
    $!ws = await Cro::WebSocket::Client.connect: $usb2snes-url;
}

method asyncConnect {
    $!ws = Cro::WebSocket::Client.connect: $usb2snes-url;
}


#{
#    "Results" : ["data1", "data2"]
#}

# Server command

method set-name (Str $name) {
    self.send-command(Name, $name);
}

method list-devices {
    self.send-command(DeviceList);
    self!get-reply;
}

method attach (Str $device-name) {
    self.send-command(Attach, $device-name)
}

method server-version {
    self.send-command(AppVersion);
    return (self!get-reply)[0];
}

method device-infos {
    self.send-command(Info);
    my @reply = self!get-reply(500);
    return Nil if @reply ~~ Empty;
    DeviceInfo.new(version => @reply[0], name => @reply[1], rom-running => @reply[2], flags => @reply[3..^Inf]);
}

# File methods
method ls (Str $path = "/", :$timeout = 500) returns Array of FileInfo {
    self.send-command(List, $path);
    my @rep = self!get-reply($timeout);
    return Nil if @rep ~~ Empty;
    my FileInfo @files;
    for @rep.reverse.hash.kv -> $k, $v {
        @files.append(FileInfo.new(:name($k), :type(Usb2Snes::file-type($v))))
    }
    @files
}

method mkdir (Str $path) {
    self.send-command(MakeDir, $path)
}

method rm (Str $path) {
    self.send-command(Remove, $path)
}

method rename(Str $path1, Str $path2) {
    self.send-command(Rename, $path1, $path2)
}

method get-file(Str $path) {
    self.send-command(GetFile, $path);
    my $size = (self!get-reply)[0];
    my $message;
    my Buf $data = Buf.new;
    react {
        whenever $!ws.messages -> $msg {
            whenever $msg.body-blob -> $body {
                $data.append($body);
                done() if $data.bytes == $size
            }
        }
        whenever  Promise.in(500) {
            done();
        }
    }
    return $data;
}

method send-file(Str $path, Blob $data) {
    self.send-command(PutFile, $path, $data.bytes);
    $!ws.send($data);
}

method  !get-reply ($timeout = 200){
    my $message;
    react {
        whenever $!ws.messages -> $msg {
            whenever $msg.body -> $body {
                $message = $body;
                done();
            }
        }
        whenever  Promise.in($timeout / 1000) {
            say "Request time out after " ~ $timeout ~ " ms";
            done();
        }
    }
    return Empty unless $message;
    say $message;
    my %reply = from-json $message;
    @(%reply<Results>);
}

#{
#    "Opcode" : "Attach",
#    "Space" : "SNES",
#    "FLAGS" : ["FLAG1", "FLAGS2"],
#    "Operands" : ["SD2SNES COM3"]
#}

method send-command(Usb2Snes-Opcode $cmd, *@args, :$space = "SNES") {
    my %cmd;
    %cmd<Opcode> = $cmd.Str;
    %cmd<Space> = $space;
    %cmd<Operands> = @args;
    #say %cmd;
    #say "Sending" ~ to-json %cmd;
    $!ws.send(to-json %cmd)
}

#multi method send-command(Usb2Snes-Opcode $cmd, Str $arg)
#{
#    self.send-command($cmd, Array[Str].new($arg));
#}

#multi method send-command(Usb2Snes-Opcode $cmd)
#{
#    self.send-command($cmd, Array[Str].new());
#}

