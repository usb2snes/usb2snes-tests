
This is a repository holding files used to test the usb2snes protocol

## Building the Roms

To build the test roms you need to check the custom rom Readme file

## Running the test

Test are written in Raku [https://www.raku.org/](https://www.raku.org/)

It's recommanded to use your distribution method to install raku or you can follow the instructions on raku website.
You need to install the `zef` utility that is used to install Raku modules.

To run the test you need to install the Cro::WebSocket module `zef install Cro::Websocket`.

Once everything is installed enter the raku-test directory and run a test like this :

```shell
skarsnik@DESKTOP-UIA12T1:usb2snes-tests/raku-tests$ raku -I lib -I t/lib t/00-sanity.t
```

All tests are in the t folders.
