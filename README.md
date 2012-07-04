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

Add to crontab:

# Chef Name: build light
* * * * * /bin/bash -c 'export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH; RBENV_VERSION=1.9.3-p125; /home/dev/build-light/bin/build-light >> /home/dev/build-light/log/build-light.log 2>&1'

#Standup song
30 9 * * 1,2,3,4,5 /bin/bash -c 'export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH; RBENV_VERSION=1.9.3-p125; /home/dev/build-light/bin/stand-up >> /home/dev/build-light/log/stand-up.log 2>&1'


```
TODO
```

