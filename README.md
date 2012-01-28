## Installation

### Mac OS X

```
brew install libusb-compat
ARCHFLAGS="-arch x86_64" bundle install
```

Add to launch agent:

```
TODO
```


### Ubuntu

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

