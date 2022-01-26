# Ansible Collection for building cloud infrastructures

This repo hosts the [`jm1.cloudy`](https://galaxy.ansible.com/jm1/cloudy) Ansible Collection.

This repo hosts a variety of Ansible content, such as [inventories, playbooks and roles][ansible-basic-concepts],
that demonstrates how to setup a cloud infrastructure using [libvirt][libvirt] and/or [OpenStack][openstack]:

[ansible-basic-concepts]: https://docs.ansible.com/ansible/latest/user_guide/basic_concepts.html
[libvirt]: https://libvirt.org/
[openstack]: https://www.openstack.org/

* Hosts [`lvrt-lcl-session-srv-1-*` to `lvrt-lcl-session-srv-8-*`][inventory-example] showcase how to provision libvirt
  domains (QEMU/KVM based virtual machines) with [cloud-init][cloud-init-doc] and CentOS 7, CentOS 8,
  Debian 10 (Buster), Debian 11 (Bullseye), Ubuntu 18.04 LTS (Bionic Beaver) or Ubuntu 20.04 LTS (Focal Fossa)
* Hosts [`lvrt-lcl-session-srv-10-*` to `lvrt-lcl-session-srv-17-*`][inventory-example] showcase automatic system
  installation of [CentOS 8 with Kickstart, of Debian 11 (Bullseye) with Preseed and of Ubuntu 20.04 LTS (Focal Fossa)
  with Autoinstall][pxe-installer], each with [PXE][pxe-wiki] network boot on BIOS and UEFI systems
* Host [`lvrt-lcl-session-srv-20-*`][inventory-example] showcases how to ["quickly bring up a OpenStack environment
  based on the latest versions of everything from git master"][devstack] with [DevStack][devstack]
* Host [`lvrt-lcl-session-srv-21-*`][inventory-example] showcases how to
  [deploy TripleO standalone][tripleo-standalone-setup] on CentOS 8
* Host [`lvrt-lcl-session-srv-30-*`][inventory-example] showcases how to [fingerprint and report hardware specifications
  of systems][pxe-hwfp] which can be booted via [PXE][pxe-wiki]. Hosts `lvrt-lcl-session-srv-31-*` and
  `lvrt-lcl-session-srv-32-*` demonstrate how a poweron-fingerprint-report-poweroff cycle works in practice.

[cloud-init-doc]: https://cloudinit.readthedocs.io/
[devstack]: https://docs.openstack.org/devstack/latest/
[tripleo-standalone-setup]: https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/deployment/standalone.html
[pxe-hwfp]: https://github.com/JM1/ansible-collection-jm1-cloudy/tree/master/roles/pxe_hwfp/
[pxe-installer]: https://github.com/JM1/ansible-collection-jm1-cloudy/tree/master/roles/pxe_installer/
[pxe-wiki]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

This collection has been developed and tested for compatibility with:
* Debian 10 (Buster)
* Debian 11 (Bullseye)
* Red Hat Enterprise Linux (RHEL) 7 / CentOS 7
* Red Hat Enterprise Linux (RHEL) 8 / CentOS 8
* Ubuntu 18.04 LTS (Bionic Beaver)
* Ubuntu 20.04 LTS (Focal Fossa)

Goals for this collection are:

* [KISS][kiss]. No magic involved. Do not hide complexity (if complexity is unavoidable). Follow Ansible's principles:
  [Hosts, groups and group memberships][ansible-inventory] are defined in [`hosts.yml`][inventory-example],
  host- and group-specific configuration is stored in [`host_vars` and `group_vars`][inventory-example],
  [tasks and related content are grouped][ansible-roles] in [roles][cloudy-roles],
  [playbooks such as `site.yml`][playbook-site-yml] [assign roles to hosts and groups of hosts][ansible-playbooks].

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[ansible-playbooks]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html
[ansible-roles]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html
[cloudy-roles]: roles/
[kiss]: https://en.wikipedia.org/wiki/KISS_principle

* Generic and reusable code. Code is adaptable and extendable for various cloud use cases with minimal changes:
  Most roles offer choices of several modules to customize role behaviour, e.g. [role `cloudinit`][cloudinit-tasks-main]
  allows to use Ansible's [`blockinfile`][ansible-module-blockinfile], [`copy`][ansible-module-copy],
  [`file`][ansible-module-file], [`lineinfile`][ansible-module-lineinfile] and [`template`][ansible-module-template]
  modules in `host_vars` and `group_vars` to edit lines and blocks in files etc.

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-module-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[cloudinit-tasks-main]: roles/cloudinit/tasks/main.yml

* Users are experts. Users know what to do (once you give them the options). Users have to understand the code to
  reliable and securely operate systems. Users have to understand the code to debug it due to
  [leaky abstractions][leaky-abstraction].

[leaky-abstraction]: https://en.wikipedia.org/wiki/Leaky_abstraction

## Included content

Click on the name of an inventory, module, playbook or role to view that content's documentation:

- **Inventories**:
    * [`inventory/`](inventory/hosts.yml)
- **Playbooks**:
    * [`site.yml`](playbooks/site.yml)
- **Roles**:
    * [cloudinit](roles/cloudinit/README.md)
    * [debconf](roles/debconf/README.md)
    * [devstack](roles/devstack/README.md)
    * [dhcpd](roles/dhcpd/README.md)
    * [files](roles/files/README.md)
    * [groups](roles/groups/README.md)
    * [grub](roles/grub/README.md)
    * [httpd](roles/httpd/README.md)
    * [initrd](roles/initrd/README.md)
    * [ipmi](roles/ipmi/README.md)
    * [iptables](roles/iptables/README.md)
    * [libvirt_domain](roles/libvirt_domain/README.md)
    * [libvirt_domain_state](roles/libvirt_domain_state/README.md)
    * [libvirt_images](roles/libvirt_images/README.md)
    * [libvirt_networks](roles/libvirt_networks/README.md)
    * [libvirt_pools](roles/libvirt_pools/README.md)
    * [libvirt_volumes](roles/libvirt_volumes/README.md)
    * [meta_packages](roles/meta_packages/README.md)
    * [netplan](roles/netplan/README.md)
    * [networkmanager](roles/networkmanager/README.md)
    * [openstack_compute_flavors](roles/openstack_compute_flavors/README.md)
    * [openstack_images](roles/openstack_images/README.md)
    * [openstack_keypairs](roles/openstack_keypairs/README.md)
    * [openstack_networks](roles/openstack_networks/README.md)
    * [openstack_security_groups](roles/openstack_security_groups/README.md)
    * [openstack_server](roles/openstack_server/README.md)
    * [openstack_server_state](roles/openstack_server_state/README.md)
    * [openstack_volumes](roles/openstack_volumes/README.md)
    * [packages](roles/packages/README.md)
    * [pxe_hwfp](roles/pxe_hwfp/README.md)
    * [pxe_installer](roles/pxe_installer/README.md)
    * [selinux](roles/selinux/README.md)
    * [services](roles/services/README.md)
    * [ssh_authorized_keys](roles/ssh_authorized_keys/README.md)
    * [sshd](roles/sshd/README.md)
    * [storage](roles/storage/README.md)
    * [sudoers](roles/sudoers/README.md)
    * [sysctl](roles/sysctl/README.md)
    * [tftpd](roles/tftpd/README.md)
    * [tripleo_standalone](roles/tripleo_standalone/README.md)
    * [users](roles/users/README.md)

:warning: **WARNING:**
Some roles will inevitably fail while trying to download files. Especially cloud images and install images for CentOS,
Debian and Ubuntu are frequently updated, so download links change and become invalid. Broken links can easily be fixed
by changing variables of the respective Ansible roles. For example, use grep to find the role variable which defines the
broken download link and then redefine this variable with an updated link in your host inventory.
:warning:

## Requirements and Installation

### Installing necessary software

[Ansible Collections][ansible-collections] have been introduced in Ansible 2.9, hence for collection support a Ansible
release equal to version 2.9 or greater has to be installed. Ansible's [Installation Guide][ansible-installation-guide]
provides instructions on how to install Ansible on several operating systems and with `pip`.

[ansible-collections]: https://github.com/ansible-collections/overview/blob/main/README.rst
[ansible-installation-guide]: https://docs.ansible.com/ansible/latest/installation_guide/

#### Installing Ansible 2.9+ with `pip`

First, make sure that `pip` is available on your system.

| OS                                           | Install Instructions              |
| -------------------------------------------- | --------------------------------- |
| Debian 10 (Buster)                           | `apt install python3 python3-pip` |
| Debian 11 (Bullseye)                         | `apt install python3 python3-pip` |
| Red Hat Enterprise Linux (RHEL) 7 / CentOS 7 | `yum install python3 python3-pip` |
| Red Hat Enterprise Linux (RHEL) 8 / CentOS 8 | `yum install python3 python3-pip` |
| Ubuntu 18.04 LTS (Bionic Beaver)             | `apt install python3 python3-pip` |
| Ubuntu 20.04 LTS (Focal Fossa)               | `apt install python3 python3-pip` |

Run `pip3 install --user --upgrade pip` to upgrade `pip` to the latest version because an outdated `pip` version is the
single most common cause of installation problems. Before proceeding, please follow the hints and instructions given in
[`pip-requirements.txt`][pip-requirements-txt] because some Python modules have additional prerequisites. Next, install
Ansible and all required Python modules with `pip3 install --user --requirement pip-requirements.txt`.

You may want to use Python's [`virtualenv` tool][virtualenv] to create a self-contained Python environment for Ansible,
instead of installing all Python packages to your home directory with `pip3 install --user`.

[virtualenv]: https://virtualenv.pypa.io/en/latest/

#### Installing Ansible 2.9+ on specific operating systems

:warning: **NOTE:**
Using `pip` instead of OS package managers is preferred because distribution-provided packages are often outdated.
:warning:

To install Ansible 2.9 or later using OS package managers do:

| OS                                           | Install Instructions                                                |
| -------------------------------------------- | ------------------------------------------------------------------- |
| Debian 10 (Buster)                           | Enable [Backports](https://backports.debian.org/Instructions/). `apt install ansible ansible-doc make` |
| Debian 11 (Bullseye)                         | `apt install ansible ansible-doc make` |
| Red Hat Enterprise Linux (RHEL) 7 / CentOS 7 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible ansible-doc make` |
| Red Hat Enterprise Linux (RHEL) 8 / CentOS 8 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible ansible-doc make` |
| Ubuntu 18.04 LTS (Bionic Beaver)             | Enable [Launchpad PPA Ansible by Ansible, Inc.](https://launchpad.net/~ansible/+archive/ubuntu/ansible). `apt install ansible ansible-doc make` |
| Ubuntu 20.04 LTS (Focal Fossa)               | `apt install ansible ansible-doc make` |

Some Ansible modules used in this collection require additional tools and Python libraries which have to be installed 
manually. Refer to [`pip-requirements.txt`][pip-requirements-txt] for a complete list. Use a [package search][pkgs-org]
to find matching packages for your distribution.

[pkgs-org]: https://pkgs.org/

#### Installing Ansible 2.9+ with Docker and `Ansible Silo`

If Ansible 2.9 or later is not available for your OS, then you might give [Ansible Silo][ansible-silo] a try, which
provides Ansible in a self-contained environment via Docker. Some Ansible modules used in this collection require
additional tools and Python libraries which are not distributed with Ansible Silo. Refer to
[`pip-requirements.txt`][pip-requirements-txt] for a complete list. Ansible Silo's documentation has a section on
[installing custom software in Ansible Silo][ansible-silo-custom-software].

[ansible-silo]: https://groupon.github.io/ansible-silo/
[ansible-silo-custom-software]: https://groupon.github.io/ansible-silo/#installing-custom-software
[pip-requirements-txt]: pip-requirements.txt

#### Installing Ansible roles and collections

Content in this collection requires additional roles and collections, e.g. to collect operating system facts. You can
fetch them from Ansible Galaxy using the provided [`requirements.yml`](requirements.yml):

```sh
ansible-galaxy collection install --requirements-file requirements.yml
ansible-galaxy role install --role-file requirements.yml
# or
make install-requirements
```

#### Satisfying collections requirements

These collections require additional tools and libraries, e.g. to interact with package managers, libvirt and OpenStack.
You can use the following roles to install necessary software packages:

```sh
sudo -s

ansible-console localhost << EOF
gather_facts

include_role name=jm1.pkg.setup
# Ref.: https://github.com/JM1/ansible-collection-jm1-pkg/blob/master/roles/setup/README.md

include_role name=jm1.libvirt.setup
# Ref.: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/roles/setup/README.md

include_role name=jm1.openstack.setup
# Ref.: https://github.com/JM1/ansible-collection-jm1-openstack/blob/master/roles/setup/README.md
EOF
```

The exact requirements for every module and role are listed in the corresponding documentation.
See the module documentations for the minimal version supported for each module.

### Installing the Collection from Ansible Galaxy

Before using the `jm1.cloudy` collection, you need to install it with the Ansible Galaxy CLI:

```sh
ansible-galaxy collection install jm1.cloudy
```

You can also include it in a `requirements.yml` file and install it via
`ansible-galaxy collection install -r requirements.yml`, using the format:

```yaml
---
collections:
  - name: jm1.cloudy
    version: 2021.12.30
```

## Usage and Playbooks

### Starting off with your own cloud

To build your own cloud infrastructure based on this collection, copy directory [`inventory/`][inventory-example],
playbook [`playbooks/site.yml`][playbook-site-yml] and config [`ansible.cfg.example`][ansible-cfg-example] to a new
directory.

Edit `ansible.cfg` to match your environment, i.e. set paths where Ansible is going to install and search for
collections and roles etc:

```sh
mv -i ansible.cfg.example ansible.cfg
editor ansible.cfg
```

:warning: **WARNING:**
Run the following playbooks on disposable non-productive bare-metal machines only.
They will apply changes that might break your system.
:warning:


Ensure you have valid RSA keys for SSH logins, esp. a RSA public key at `$HOME/.ssh/id_rsa.pub`. If it does not exist,
generate a new RSA key pair with `ssh-keygen` or edit Ansible variable `ssh_authorized_keys` in
`inventory/group_vars/all.yml` to include your SSH public key:

```yaml

ssh_authorized_keys:
- comment: John Wayne (Megacorp)
  key: ssh-rsa ABC...XYZ user@host
  state: present
  user: '{{ ansible_user }}'

```

The [example inventory][inventory-example] assumes that your system has a bridge `br-lan` with ip network `10.0.*.*/16`
and gateway `10.0.0.1`. For example, suppose your system has a network interface with device name `eth0`, ip address
`10.0.0.2` has been assigned to `eth0` and `eth0` is connected to a router (and dns server) with ip address `10.0.0.1`.
To define bridge `br-lan` on Debian, change [`/etc/network/interfaces`][ifupdown-interfaces] to:

```
# Ref.: man interfaces

iface 10.0.0.2 inet static
    address 10.0.0.2/16
    gateway 10.0.0.1
    dns-nameservers 10.0.0.1

auto br-lan
iface br-lan inet manual
    bridge_ports eth0
    bridge_stp off
    bridge_waitport 3
    bridge_fd 0
    bridge_maxwait 5
    # (Optional) Allow forwarding all traffic across the bridge to virtual machines
    # Ref.:
    #  https://wiki.libvirt.org/page/Networking
    #  https://bugzilla.redhat.com/show_bug.cgi?id=512206#c0
    post-up iptables -I FORWARD -i br-lan -m physdev --physdev-is-bridged -j ACCEPT
    pre-down iptables -D FORWARD -i br-lan -m physdev --physdev-is-bridged -j ACCEPT

iface br-lan inet6 manual

auto br-lan:0
iface br-lan:0 inet static inherits 10.0.0.2
```

For `systemd-networkd` refer to [Arch's Wiki][arch-wiki-systemd-networkd] or [upstream's documentation][
systemd-network]. For Desktop distributions, refer to [GNOME's project page on NetworkManager][network-manager], esp.
its `See Also` section.

[arch-wiki-systemd-networkd]: https://wiki.archlinux.org/title/Systemd-networkd
[ifupdown-interfaces]: https://manpages.debian.org/unstable/ifupdown/interfaces.5.en.html
[network-manager]: https://wiki.gnome.org/Projects/NetworkManager
[systemd-network]: https://www.freedesktop.org/software/systemd/man/systemd.network.html

All other bridges and networks will be created executing the playbooks listed below for hosts `lvrt-lcl-system` and
`lvrt-lcl-session`.

Run playbook `playbooks/site.yml` for host `lvrt-lcl-system` to set up a libvirt environment on your system, e.g.
install packages for libvirt and QEMU, configure libvirt networks, prepare a default libvirt storage pool and preload OS
images.

```sh
# Cache user credentials so that Ansible can escalate privileges and execute tasks with root privileges
sudo true

ansible-playbook playbooks/site.yml --limit lvrt-lcl-system
```

Run playbook `playbooks/site.yml` for host `lvrt-lcl-session` to prepare the libvirt session of your local user, e.g.
prepare a default libvirt storage pool and preload OS images.

```sh
ansible-playbook playbooks/site.yml --limit lvrt-lcl-session
```

Run playbook `playbooks/site.yml` for all remaining hosts.

:warning: **WARNING:**
Running playbook `playbooks/site.yml` for all hosts in `build_level1` and `build_level2` will create dozens of virtual
machines. Ensure that your system has enough memory to run them in parallel. To lower memory requirements, you may want
to limit `playbooks/site.yml` to a few hosts or a single host instead. Refer to [`hosts.yml`][inventory-example] for a
complete list of hosts in `build_level1` and `build_level2`.
:warning:

```sh
# build_level0 contains lvrt-lcl-system and lvrt-lcl-session which have been prepared at previous steps
ansible-playbook playbooks/site.yml --limit build_level1
ansible-playbook playbooks/site.yml --limit build_level2
```

Dig into your inventory and playbooks and customize them as needed.

[ansible-cfg-example]: ansible.cfg.example
[inventory-example]: inventory/
[playbook-site-yml]: playbooks/site.yml

### Using content of this Collection

You can either call modules and roles by their Fully Qualified Collection Namespace (FQCN), like `jm1.cloudy.devstack`,
or you can call modules by their short name if you list the `jm1.cloudy` collection in the playbook's `collections`,
like so:

```yaml
---
- name: Using jm1.cloudy collection
  hosts: localhost

  collections:
    - jm1.cloudy

  roles:
    - name: Setup an OpenStack cluster with DevStack
      role: devstack
```

For documentation on how to use individual modules and other content included in this collection, please see the links
in the 'Included content' section earlier in this README.

See [Ansible Using collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html) for more
details.

## Contributing

There are many ways in which you can participate in the project, for example:

- Submit bugs and feature requests, and help us verify them
- Submit pull requests for new modules, roles and other content

We're following the general Ansible contributor guidelines;
see [Ansible Community Guide](https://docs.ansible.com/ansible/latest/community/index.html).

If you want to develop new content for this collection or improve what is already here, the easiest way to work on the
collection is to clone this repository (or a fork of it) into one of the configured [`ANSIBLE_COLLECTIONS_PATHS`](
https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths) and work on it there:
1. Create a directory `ansible_collections/jm1`;
2. In there, checkout this repository (or a fork) as `cloudy`;
3. Add the directory containing `ansible_collections` to your
   [`ANSIBLE_COLLECTIONS_PATHS`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths).

Helpful tools for developing collections are `ansible`, `ansible-doc`, `ansible-galaxy`, `ansible-lint`, `flake8`,
`make` and `yamllint`.

| OS                                           | Install Instructions                                                |
| -------------------------------------------- | ------------------------------------------------------------------- |
| Debian 10 (Buster)                           | Enable [Backports](https://backports.debian.org/Instructions/). `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |
| Debian 11 (Bullseye)                         | `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |
| Red Hat Enterprise Linux (RHEL) 7 / CentOS 7 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible ansible-lint ansible-doc  python-flake8 make yamllint` |
| Red Hat Enterprise Linux (RHEL) 8 / CentOS 8 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible              ansible-doc python3-flake8 make yamllint` |
| Ubuntu 18.04 LTS (Bionic Beaver)             | Enable [Launchpad PPA Ansible by Ansible, Inc.](https://launchpad.net/~ansible/+archive/ubuntu/ansible). `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |
| Ubuntu 20.04 LTS (Focal Fossa)               | `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |

Have a look at the included [`Makefile`](Makefile) for
several frequently used commands, to e.g. build and lint a collection.

## More Information

- [Ansible Collection Overview](https://github.com/ansible-collections/overview)
- [Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)
- [Ansible Developer Guide](https://docs.ansible.com/ansible/latest/dev_guide/index.html)
- [Ansible Community Code of Conduct](https://docs.ansible.com/ansible/latest/community/code_of_conduct.html)

## License

GNU General Public License v3.0 or later

See [LICENSE.md](LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
