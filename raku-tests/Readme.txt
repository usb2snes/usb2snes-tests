To run the tests you need :
Install the raku language toolchain see https://rakudo.org/downloads
Zef : https://github.com/ugexe/zef
install Cro::WebSocket::Client with zef install Cro::WebSocket::Client

To run a test :
make sure a usb2snes server is running and :
raku -I lib -I t/lib t/testyouwanttorun.t


