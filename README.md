# Vagrant Salt

Tools for Vagrant and Salt to develop Salt states.


## Usage

Start the local salt-master.

```sh
salt-master
```

Create a box from the default template `jessie` with the hostname and minion name `gitlab`.

```sh
./create-box.sh gitlab
```

Create a box and specify a template and network device.

```sh
./create-box.sh --template wheezy --device eth1 gitlab
```

Add a minion to the top.sls

```yaml
local:
  'gitlab*':
    - gitlab
```

Start a box.

```sh
./up-box.sh gitlab
```

Provision a box.

```sh
salt gitlab state.highstate
```

Clean up a box to start over.

```sh
./destroy-box.sh gitlab
```


## Setup

### Master

Install salt-master on OS X.

```sh
brew install saltstack
```

Install salt-master on Debian.

```sh
sudo apt-get install salt-master
```

Configure salt-master. This example configuration may be saved in `/etc/salt/master.d/salt.conf`.

```yml
file_roots:
  local:
    - /Users/example_user/srv/salt/state

pillar_roots:
  local:
    - /Users/example_user/srv/salt/pillar/local
    - /Users/example_user/srv/salt/pillar/secure-pillar-local

# Required on OS X.
max_open_files: 8192

# Run salt-master as unprivileged user.
user: example_user

# Store all master generated files in the home directory.
root_dir: /Users/example_user

# Allow an unprivileged user to connect to salt-master.
client_acl:
  example_user:
    - .*
```

Clone the repository of your Salt states to `~/srv/salt`.


### Vagrant

Install [Vagrant](https://www.vagrantup.com).

Clone `vagrant-salt`.

```sh
git clone https://github.com/FunTimeCoding/vagrant-salt
```

Add Vagrant base boxes.

```sh
vagrant box add jessie http://funtimecoding.org/jessie.box
vagrant box add wheezy http://funtimecoding.org/wheezy.box
vagrant box add squeeze http://funtimecoding.org/squeeze.box
```


### Optional: Salt development

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
pip install --upgrade pyzmq PyYAML pycrypto msgpack-python jinja2 psutil
```

Install M2Crypto on OS X.

```sh
pip install --upgrade M2Crypto
```

Install M2Crypto on Debian.

```sh
apt-get install python-m2crypto
```

Install the development clone in edit mode.

```sh
pip install -e .
```

Run salt-master from the development clone.

```sh
source .venv/bin/activate
salt-master
```


### Optional: Veewee

You can use [Veewee](https://github.com/jedi4ever/veewee) to generate Vagrant base boxes. A base box is a clean slate installation of a particular operating system version.

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
bundle exec veewee vbox define jessie Debian-8.4-amd64-netboot
cd definitions/jessie
sed -i '/^  - "chef\.sh"/s/- /#- /' definition.yml
sed -i '/^  - "puppet\.sh"/s/- /#- /' definition.yml
sed -i '/^  - "ruby\.sh"/s/- /#- /' definition.yml
cd ../..
bundle exec veewee vbox build jessie
bundle exec veewee vbox halt jessie
bundle exec veewee vbox export jessie
vagrant box add jessie jessie.box
bundle exec veewee vbox destroy jessie
rm jessie.box
```

Create a Wheezy base box.

```sh
cd veewee
bundle exec veewee vbox define wheezy Debian-7.10-amd64-netboot
cd definitions/wheezy
sed -i '/  "chef\.sh"/s/    /    #/' definition.rb
sed -i '/  "puppet\.sh"/s/    /    #/' definition.rb
sed -i '/  "ruby\.sh"/s/    /    #/' definition.rb
cd ../..
bundle exec veewee vbox build wheezy
bundle exec veewee vbox halt wheezy
bundle exec veewee vbox export wheezy
vagrant box add wheezy wheezy.box
bundle exec veewee vbox destroy wheezy
rm wheezy.box
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
bundle exec veewee vbox halt squeeze
bundle exec veewee vbox export squeeze
vagrant box add squeeze squeeze.box
bundle exec veewee vbox destroy squeeze
rm squeeze.box
```

Repackage Vagrant boxes in case the `.box` file was deleted.

```sh
vagrant box repackage jessie virtualbox 0
mv package.box jessie.box
vagrant box repackage wheezy virtualbox 0
mv package.box wheezy.box
vagrant box repackage squeeze virtualbox 0
mv package.box squeeze.box
```
