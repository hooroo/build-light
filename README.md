# build-light

Plays build failure announcements and sets a build light's colour accordingly.

[![Build status](https://badge.buildkite.com/4b09bd7c99fd66c0947a232f2cfb233860cc6e0cb3ea4043a7.svg)](https://buildkite.com/hooroo/build-light-dot-gem)

## Installation

### Mac OS X

Sound effects:
```
brew install mpg123
```

### Ubuntu

Install sounds:

```
sudo apt-get update
sudo apt-get install mpg123
```

```
bundle install
```

Add to crontab:

# Chef Name: build light
* * * * * /bin/bash -c 'export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH; RBENV_VERSION=1.9.3-p125; /home/dev/build-light/bin/build-light >> /home/dev/build-light/log/build-light.log 2>&1'
