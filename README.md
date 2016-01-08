# Vagrant Salt

Bridge between Vagrant and Salt for easier creation and handling of Salt minions using Vagrant.


## Usage

Start the local `salt-master`.

```sh
salt-master -l info
```

Create a minion using `vagrant-salt` using the template `wheezy` with the new hostname and minion ID `gitlab`.

```sh
./create-minion.sh gitlab
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

Add Vagrant base boxes.

```sh
vagrant box add squeeze http://funtimecoding.org/squeeze.box
vagrant box add wheezy http://funtimecoding.org/wheezy.box
vagrant box add jessie http://funtimecoding.org/jessie.box
```


## Optional: Salt development

This section explains how to configure a development clone of Salt ([Source](http://docs.saltstack.com/en/latest/topics/development/hacking.html)).

OS X specific prerequisites.

```sh
brew install python swig
pip2 install virtualenv
```

Clone the development repository.

```sh
git clone https://github.com/saltstack/salt
```

Common OS X and Debian configuration.

```sh
cd salt
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

Install the salt clone in edit mode into the current virtual environment.

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

You can use [Veewee](https://github.com/jedi4ever/veewee) to generate Vagrant base boxes. Base boxes are clean slate images used by `vagrant-salt` to create minions.

```sh
git clone https://github.com/jedi4ever/veewee
```

Install dependencies.

```sh
gem install bundler
cd veewee
bundle install
```

Create a Jessie base box.

```sh
cd veewee
bundle exec veewee vbox define jessie Debian-8.2-amd64-netboot
cd definitions/jessie
sed -i '/^  - "chef\.sh"/s/- /#- /' definition.yml
sed -i '/^  - "puppet\.sh"/s/- /#- /' definition.yml
sed -i '/^  - "ruby\.sh"/s/- /#- /' definition.yml
cd ../..
bundle exec veewee vbox build jessie
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7222 -l vagrant 127.0.0.1
sudo passwd
exit
bundle exec veewee vbox halt jessie
bundle exec veewee vbox export jessie
vagrant box add jessie "${HOME}/Code/Foreign/veewee/jessie.box"
```

Create a Wheezy base box.

```sh
cd veewee
bundle exec veewee vbox define wheezy Debian-7.9-amd64-netboot
cd definitions/wheezy
sed -i '/  "chef\.sh"/s/    /    #/' definition.rb
sed -i '/  "puppet\.sh"/s/    /    #/' definition.rb
sed -i '/  "ruby\.sh"/s/    /    #/' definition.rb
cd ../..
bundle exec veewee vbox build wheezy
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7222 -l vagrant 127.0.0.1
sudo passwd
exit
bundle exec veewee vbox halt wheezy
bundle exec veewee vbox export wheezy
vagrant box add wheezy "${HOME}/Code/Foreign/veewee/wheezy.box"
```

Create a Squeeze base box.

```sh
cd veewee
bundle exec veewee vbox define squeeze Debian-6.0.10-amd64-netboot
cd definitions/squeeze
sed -i '/  "chef\.sh"/s/    /    #/' definition.rb
sed -i '/  "puppet\.sh"/s/    /    #/' definition.rb
sed -i '/  "ruby\.sh"/s/    /    #/' definition.rb
cd ../..
bundle exec veewee vbox build squeeze
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7222 -l vagrant 127.0.0.1
sudo passwd
exit
bundle exec veewee vbox halt squeeze
bundle exec veewee vbox export squeeze
vagrant box add squeeze "${HOME}/Code/Foreign/veewee/squeeze.box"
```
