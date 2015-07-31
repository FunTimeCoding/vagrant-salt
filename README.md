# Salt Development Environment

## Usage

Start the local `salt-master`.

```sh
salt-master -l info
```

Create a minion using `vagrant-salt` using the template `wheezy` with the new hostname and minion ID `gitlab`.

```sh
cd ~/Code/vagrant-salt
./create-minion.sh -t wheezy -i gitlab
```

Add a minion to the top.sls

```yaml
local:
  'gitlab*':
    - gitlab
```


## Setup

### Master

Install `salt-master` on OS X.

```sh
brew install saltstack
```

Install `salt-master` on Debian.

```sh
sudo apt-get install salt-master
```

Configure the master appropriately. This is an example of `/etc/salt/master.d/osx.conf`.

```
# Required on OS X according to Salt documentation.
max_open_files: 8192

# Master should not run as root.
user: shiin

# Use a directory where the user has write permissions.
# Note: /var/run is a bad idea since it gets wiped on reboot and users cannot create directories in there.
pidfile: /Users/shiin/var/run/salt/salt-master.pid
sock_dir: /Users/shiin/var/run/salt/master

# Allow salt usage without root.
client_acl:
  shiin:
    - .*

# Local environment for developing all the things.
state_top: top.sls
file_roots:
  local:
    - /Users/shiin/srv/salt/state
pillar_roots:
  local:
    - /Users/shiin/srv/salt/pillar/local
    - /Users/shiin/srv/salt/pillar/secure-pillar-local

# Be less verbose for dealing with many states.
state_verbose: False
```

Clone the repository of your Salt states to `~/srv/salt`.


### Vagrant

Install Vagrant from [here](https://www.vagrantup.com).

Clone the `vagrant-salt` repository.

```sh
git clone https://github.com/FunTimeCoding/vagrant-salt
```

Add a Vagrant base box.

```sh
vagrant box add squeeze http://funtimecoding.org/wheezy.box
```


## Optional: Salt development

This section explains how to configure a development clone of Salt ([Source](http://docs.saltstack.com/en/latest/topics/development/hacking.html)).

OS X specific prerequisites.

```sh
brew install python
brew install swig
pip2 install virtualenv
```

Clone the development repository.

```sh
git clone https://github.com/saltstack/salt
```

Common OS X and Debian configuration.

```sh
virtualenv .venv
source .venv/bin/activate
pip install -U pyzmq PyYAML pycrypto msgpack-python jinja2 psutil
```

Install M2Crypto on OS X.

```sh
pip install -U M2Crypto
```

Install M2Crypto on Debian.

```sh
apt-get install python-m2crypto
```

Install the salt clone in development mode into the current virtual environment.

```sh
pip install -e .
```

Run the master from a development clone.

```sh
source .venv/bin/activate
salt-master -l info
```


## Optional: PyCharm

This section explains how to get PyCharm.

Download the Community Edition from [here](https://www.jetbrains.com/pycharm/download).
There is no YAML support in the community edition. The [Ansible plugin](https://github.com/vermut/intellij-ansible) does not seem like a viable option yet.


## Optional: Veewee

You can use Veewee to generate Vagrant base boxes. Base boxes are clean slate images used by `vagrant-salt` to create minions.

```sh
git clone https://github.com/jedi4ever/veewee
```

Create a Squeeze base box.

```sh
bundle exec veewee vbox define squeeze Debian-6.0.10-amd64-netboot
bundle exec veewee vbox build squeeze
bundle exec veewee vbox export squeeze
```
