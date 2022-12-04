# conf-nyx

## How to use

### Bootstrap

1. Install [Arch Linux](https://github.com/vinymeuh/nyx-meushi/blob/master/notes/INSTALL-ARCHLINUX.md)

2. Install **pyenv** using [pyenv installer](https://github.com/pyenv/pyenv-installer)

3. Create Python **virtualenv**:

```shell
pyenv virtualenv system conf-nyx
```

4. Install **conf-nyx**

```shell
cd $HOME
git clone https://github.com/vinymeuh/conf-nyx
cd conf-nyx
pyenv version  # must be conf-nyx, see .python-version
pip install -r requirements.txt
```

### Ansible playbooks

* **Base system** ```setup-root-base.yml```, run with become_user root
* **User application** ```setup-root-userapps.yml```, run with become_user root
* **User setup** ```setup-user.yml```, run as user

```shell
cd ~/conf-nyx
ansible-playbook setup-root-base.yml -K [--check] 
ansible-playbook setup-root-userapps.yml -K [--check]
ansible-playbook setup-user.yml [--check]
```

### AURs packages

AURs packages are manually managed using **aur_builder** user:

```shell
sudo su - aur_builder
git clone https://aur.archlinux.org/<package_name>.git
cd <package_name>
makepkg -si
```

AUR packages installed:

* https://aur.archlinux.org/art-rawconverter.git
* https://aur.archlinux.org/onlyoffice-bin.git
* https://aur.archlinux.org/timeshift.git 
* https://aur.archlinux.org/timeshift-autosnap.git 

## Notes & tips

### Pacman maintenance

Pacman package cache (```/var/cache/pacman/pkg```) is cleanup periodically using the systemd timer **paccache.timer**. Manually purge using ```paccache -r```

For Pacman logs: ```paclog```

List packages:

* explicitly installed: ```pacman -Qe```
* orphans: ```pacman -Qtdq```
* sorted by install date: ```expac --timefmt='%F %T' '%l %n' | sort -n```
* not in a repostory (AUR or no longer supported): ```pacman -Qm```

Detailed information about a package: ```pacinfo <pkg>```

To mark a package as explicitly installed: ```pacman -D --asexplicit <pkg>```

### Pyenv

```shell
pyenv update
```

```shell
pyenv virtualenvs
pyenv virtualenvs-delete xxx
```

```shell
pyenv versions
pyenv uninstall 3.x.y
```

### Ansible

```shell
ansible-playbook setup-user.yml --list-tags
ansible-playbook setup-user.yml -t dotfiles
```
