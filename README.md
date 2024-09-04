# vnostr - V module that providing Nostr types and functions

![V Language](https://img.shields.io/badge/language-V-blue.svg)

This module depends on [ismyhc.vsecp256k1](https://github.com/ismyhc/vsecp256k1) and [ismyhc.vbech32](https://github.com/ismyhc/vbech32) modules.

#### You'll need to install the following libraries:
- automake
- libtool

### MacOS
`brew install automake libtool`

### Ubuntu
`sudo apt-get install automake libtool`

### Fedora
`sudo dnf install automake libtool`

### CentOS
`sudo yum install automake libtool`

### Windows (Not tested)
- Download and install [MSYS2](https://www.msys2.org/)
- Open MSYS2 terminal and run the following command:
`pacman -S automake libtool`

### How to compile the C requirements:
- Make sure you have automake and libtool installed
- Navigate to where the module was installed
- Run the following command assuming you .vmodules locations is like bellow:
`v run ~/.vmodules/ismyhc/vsecp256k1/build.vsh`

This should compile the C code and generate the necessary files for the V module. You should only have to do this once.

### How to use the module:
`import ismyhc.vnostr`

 - TODO: Add examples
 - TODO: Add documentation
 - TODO: Add tests