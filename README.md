## Installation

### Mac OS X

```
brew install libusb-compat
ARCHFLAGS="-arch x86_64" bundle install
```

Sound effects:
```
brew install mpg123
```


Add to launch agent:

```
TODO
```


### Ubuntu

Install sounds:
```
sudo apt-get update
sudo apt-get install mpg123
```

Install 'gespeaker' (from Packages GUI)

Make sure the user is a member of the {{adm}} group

create file {{/etc/udev/rules.d/45-xaiox.rules}}

```
sudo vi /etc/udev/rules.d/45-xaiox.rules
```

Enter the following content in the file:

```
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0664", GROUP="adm"
```

Reboot

```
bundle install
```

Add to upstart:

```
TODO
```

