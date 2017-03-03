# CIGRI devel virtual cluster

## Linux install

We will assume that you have a ``git`` directory into your home directory, where you store all your git repositories. If it is not yet the case, then:
```sh
mkdir ~/git
``` 

###1. Create a python virtualenv
You need "Python" and "Virtualenv".  Check with your distribution how to install it. With Debian, it's `` apt-get install python virtualenv`` 
Then create a new python environment:
```sh
cd ~
virtualenv oar-venv
```
Each time you need to work with oardocker, you load this environment into your current shell:
```sh
source ~/oar-venv/bin/activate
```
###2. Install oardocker
Be sure to be into your python environment (remember: ``source ~/oar-venv/bin/activate``)
```sh
cd ~/git
git clone https://github.com/oar-team/oar-docker.git
pip install ~/git/oar-docker
```
When upgrading, simply add the ``--upgrade`` to the ``pip`` command.

###3. Get OAR sources
```sh
cd ~/git
git clone https://github.com/oar-team/oar.git
```

###4. Create or refresh the Debian/Jessie base images for oardocker
```sh
mkdir ~/oar-jessie
cd ~/oar-jessie
oardocker init -e jessie
oardocker build
oardocker install ~/git/oar
```

###5. Create the Cigri docker images
```sh
mkdir ~/cigri-jessie
cd ~/cigri-jessie
oardocker init -e cigri
oardocker build
oardocker install ~/git/oar
```

###6. Start your OAR cluster with 3 nodes
```sh
cd ~/cigri-jessie
oardocker start -n 3
```

###7. Connect on the frontend and initiate and start the CIGRI server
```sh
oardocker connect frontend
sudo su -
/root/init_cigri.sh
/root/start_cigri.sh
```

###8. From another shell, launch a Cigri campaign
```sh
oardocker connect frontend
mkdir cigri-3/tmp
cp /root/cigri/tmp/test1.sh cigri-3/tmp
gridsub -f /root/cigri/tmp/test1.json
```