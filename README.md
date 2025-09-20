# Monit DockerOps


## Help and business engagements

For any requirements you can contact me at savvas@radevic.com for business engagements.

## Contents

* [Contents](#contents)
* [Monit client for Rundeck webhook](#monit-client-for-rundeck-webhook)
* [Required local setup](#required-local-setup)
* [Secret files](#secret-files)
* [NOTE about encrypting files - ansible vault](#note-about-encrypting-files---ansible-vault)
* [HOWTO](#howto)

## Monit client for Rundeck webhook

This docker-compose project contains the following services:

* Monit client

For semi-automated rollout, [Ansible](https://docs.ansible.com/ansible_community.html) is used.

### What is Monit

Monit is a free, open-source utility designed for managing and monitoring processes, programs, files, directories, and filesystems on Unix and Linux systems. It performs automatic maintenance and repair, executing predefined actions in response to specific conditions, such as restarting a process if it fails or stopping it if it consumes too many resources. Monit can also monitor network services and protocols, providing alerts and logging through a web interface or command line123.

### Configuring monit

You can configure monit editing the `monitrc` file.

Manual: [Monit manual](https://mmonit.com/monit/documentation/monit.html)

<a name="required-local-setup"></a>

## Required local setup

Your mileage may vary since there are different distros and operating systems.
The general idea is to have:

1. Python
2. Ansible
3. Git
4. An editor, such as VS Code with Extensions such as WSL, Ansible, Python, Pylance, YAML
5. pyenv to allow you to run other versions of python and ansible
6. ansible-lint and other packages using the pyenv command

Notes: For python and ansible, in order to run the playbook, it's important to have
a compatible version of python and ansible with the version on the server.
Sometimes the newer versions of python and ansible won't allow you to run playbooks on the server and will spit out errors.

### Cygwin

Ansible has to be installed locally in order to run the playbook. One way to do so on Windows is to use it via cygwin.
Install the "ansible" package in your cygwin installation.

### WSL Linux

Another way is to request WSL Linux in your Windows environment. This will allow you to install Ubuntu or any other linux environment with a linux/bash terminal you might feel more comfortable.

#### General recommendations with WSL Linux and Ansible

With WSL Linux I would recommend installing:

* VS Code: <https://code.visualstudio.com/>
* In WSL Linux terminal install pipx, python3, and git (your mileage may vary if you choose different distro othen than Debian/Ubuntu): `sudo apt install git git-lfs git-all python3 pipx` -- Source: <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pipx-install>
* `pipx install --include-deps ansible ansible-lint`
* Add in your ~/.bashrc:

```bash
export ANSIBLE_CONFIG=./ansible.cfg
export PATH="$HOME/.local/bin:$PATH"
```

You can then install ansible, python, docker and other extensions in VS Code to enable code checks / lint etc.

### Before running the playbook - prepare the environment

Working with ansible and older python (3.6.8) has its downsides. You should install compatible versios for ansible, ansible-base, ansible-lint to make everything work as expected. This goes beyong the scope of this README file, but you must prepare your environment to match the environment of the server (i.e. same python version). Otherwise, expect issues while running the ansible playbook.

#### Prepare WSL Linux for ansible playbook

Install the following in your WSL Linux:

```bash
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
sudo apt install clang -y
curl https://pyenv.run | bash
pyenv update
pip install --upgrade pip
pyenv rehash
CC=clang pyenv install 3.6.8
```

#### Prepare your ~/.bashrc

Prepare your `~/.bashrc` file:

```bash
export ANSIBLE_CONFIG=./ansible.cfg
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_PYTHON_BUILD_CACHE_PATH="$HOME/.pyenv_cache"
export PYENV_ROOT="$HOME/.pyenv"
#[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(~/.pyenv/bin/pyenv init -)"
```

#### Configure pyenv to install compatible python version

Configure your local system to install compatible python version.
In our case we needed to match python version 3.6.8, so we found the compatible package versions of ansible and dependencies that match that version of python:

```bash
pyenv virtualenv 3.6.8 py368
pyenv virtualenvs
pyenv rehash
pyenv activate py368

CC=clang pip install --upgrade pip
pyenv rehash
CC=clang pip install wheel
pyenv rehash
CC=clang pip install cryptography==3.4.8
pyenv rehash
CC=clang pip install ansible-base==2.10.1
pyenv rehash
CC=clang pip install ansible==2.10.0
pyenv rehash
CC=clang pip install ansible-lint==4.3.7
```

That should be it.

Test using:

```bash
python --version
ansible --version
```

<a name="secret-files"></a>

## Secret files

Secret files cannot be part of the image, as the docker image gets pushed to the docker registry.
Moreover, different files might be needed across the stages (DEV, QA, PRD).
Thus, all secret files get mounted as a separate volume from the ./secrets folder.
The same is valid for SSL certificates and ssl keystores.

<a name="note-about-encrypting-files---ansible-vault"></a>

## NOTE about encrypting files - ansible vault

Each file in the secrets/ and certs/ subfolder needs to be encrypted with ansible-vault prior to committing to git.

Ansible vault also requires a password to encrypt/decrypt prior deploying.

### Protect against unintended commits

To avoid unintended commits of these files, **you have to configure your git to look for hooks in the `hooks` folder** of a project.

Execute locally the following command in the root of the project:

`git config core.hooksPath hooks`

so that a pre-commit hook defined there checks all your files located in any `secrets` and `certs` subfolder. If they are not encrypted, the commit will fail.

<a name="howto"></a>

## HOWTO

### Run the playbook

```bash
ansible-playbook -i inventory/dev.yaml site.yaml -u <YOURUSERHERE> --ask-pass --vault-password-file .ansible/vault-pw
```

The parameters `-u <YOURUSERHERE> --ask-pass` can be omitted when you have created your user with ssh key and passwordless sudo enabled.

If you want to login with a specific ssh key (example path to private key file is `~/.ssh/id_ed25519`):

```bash
ansible-playbook -i inventory/dev.yaml site.yaml -u <YOURUSERHERE> --vault-password-file .ansible/vault-pw --private-key ~/.ssh/id_ed25519
```

If you want to check the playbook before actually running it use the `--check` argument:

```bash
ansible-playbook --check -i inventory/dev.yaml site.yaml -u <YOURUSERHERE> --vault-password-file .ansible/vault-pw --private-key ~/.ssh/id_ed25519
```

### Run on dev servers

Currently we're testing only on bitbucket dev server. There's no need to complicate with more servers.

### Run on production servers

Similar as above, but it pushes to all 4 production servers simultaneously.

```bash
ansible-playbook -i inventory/prod.yaml site.yaml -u <YOURUSERHERE> --vault-password-file .ansible/vault-pw --private-key ~/.ssh/id_ed25519
```

### Restart the monit service

Monit is set to notify only once for high memory usage so it doesn't overflow the notification system with messages.
You can restart the monit service by using the `restart-monit.yaml` file.

```bash
ansible-playbook -i inventory/prod.yaml restart-monit.yaml --vault-password-file .ansible/vault-pw --private-key ~/.ssh/id_ed25519
```

### Working with Ansible Vault

See also [Ansible Vault documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

First of all place the file containing the encryption password to your home directory. This will be the referred in the following commands as `--vault-password-file` parameter.

#### Encrypt a file

```bash
ansible-vault encrypt --vault-password-file .ansible/vault-pw encrypted.yml
```

#### Encrypt all files in folders

```bash
for i in $(find ./docker/secrets -type f); do ansible-vault encrypt --vault-password-file .ansible/vault-pw $i && echo $i; done
```

#### Decrypt a file with ansible-vault

```bash
ansible-vault decrypt --vault-password-file .ansible/vault-pw encrypted.yml
```
