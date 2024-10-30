# Ansible Collection for building cloud infrastructures

This repo hosts the [`jm1.cloudy`](https://galaxy.ansible.com/jm1/cloudy) Ansible Collection.

This repo hosts a variety of Ansible content, such as [inventories, playbooks and roles][ansible-basic-concepts],
that demonstrates how to setup a cloud infrastructure using [libvirt][libvirt] and/or [OpenStack][openstack]:

[ansible-basic-concepts]: https://docs.ansible.com/ansible/latest/user_guide/basic_concepts.html
[libvirt]: https://libvirt.org/
[openstack]: https://www.openstack.org/

* Hosts [`lvrt-lcl-session-srv-0*`][inventory-example] showcase how to provision libvirt domains (QEMU/KVM based virtual
  machines) with [cloud-init][cloud-init-doc] and CentOS Linux 7, CentOS Stream 8, CentOS Stream 9, Debian 10 (Buster),
  Debian 11 (Bullseye), Debian 12 (Bookwork), Debian 13 (Trixie), Ubuntu 18.04 LTS (Bionic Beaver), Ubuntu 20.04 LTS
  (Focal Fossa), Ubuntu 22.04 LTS (Jammy Jellyfish) and Ubuntu 24.04 LTS (Noble Numbat).
* Hosts [`lvrt-lcl-session-srv-1*`][inventory-example] showcase [automatic system installation][pxe-installer] with
  [PXE][pxe-wiki] network boot on BIOS and UEFI systems for
  - CentOS Stream 8 and CentOS Stream 9 with Kickstart,
  - Debian 11 (Bullseye), Debian 12 (Bookworm) and Debian 13 (Trixie) with Preseed, and
  - Ubuntu 20.04 LTS (Focal Fossa), Ubuntu 22.04 LTS (Jammy Jellyfish) and Ubuntu 24.04 LTS (Noble Numbat) with
    Autoinstall.
* Host [`lvrt-lcl-session-srv-200-*`][inventory-example] showcases how to ["quickly bring up a OpenStack environment
  based on the latest versions of everything from git master"][devstack] with [DevStack][devstack].
* Host [`lvrt-lcl-session-srv-210-*`][inventory-example] showcases how to [deploy TripleO standalone][
  tripleo-standalone-setup] on CentOS Stream 8.
* Host [`lvrt-lcl-session-srv-3*`][inventory-example] showcases how to [fingerprint and report hardware specifications
  of systems][pxe-hwfp] which can be booted via [PXE][pxe-wiki]. Hosts `lvrt-lcl-session-srv-310-*` and
  `lvrt-lcl-session-srv-311-*` demonstrate how a poweron-fingerprint-report-poweroff cycle works in practice.
* Hosts [`lvrt-lcl-session-srv-4*`][inventory-example] showcase how to deploy an [installer-provisioned][okd-ipi]
  [OKD][okd] cluster on bare-metal servers and run [OpenShift's conformance test suite][ocp-tests]. This setup uses
  libvirt domains (QEMU/KVM based virtual machines) to simulate bare-metal servers and auxiliary resources.
  [sushy-emulator][sushy-emulator] provides a virtual Redfish BMC to power cycle servers and mount virtual media for
  hardware inspection and provisioning. Beware of high resource utilization, e.g. this cluster requires >96GB of RAM.
* Hosts [`lvrt-lcl-session-srv-5*`][inventory-example] showcase how to deploy an [OKD][okd] HA cluster on bare-metal
  servers with [agent-based installer][ocp-abi] and run [OpenShift's conformance test suite][ocp-tests]. This setup uses
  libvirt domains (QEMU/KVM based virtual machines) to simulate bare-metal servers and auxiliary resources.
  [sushy-emulator][sushy-emulator] provides a virtual Redfish BMC to power cycle servers and mount virtual media for
  hardware inspection and provisioning. Beware of high resource utilization, e.g. this cluster requires >96GB of RAM.
* Hosts [`lvrt-lcl-session-srv-6*`][inventory-example] showcase how to deploy an [installer-provisioned][okd-ipi]
  [OKD][okd] cluster on bare-metal servers and run [OpenShift's conformance test suite][ocp-tests]. This setup is
  similar to that of hosts [`lvrt-lcl-session-srv-4*`][inventory-example] except for a additional provisioning network
  to PXE boot servers and [VirtualBMC][virtualbmc], a virtual IPMI BMC, to power cycle servers. Beware of high resource
  utilization, e.g. this cluster requires >96GB of RAM.
* Hosts [`lvrt-lcl-session-srv-7*`][inventory-example] showcase how to deploy a [single-node][ocp-sno] [OKD][okd] (SNO)
  cluster on a bare-metal server and run [OpenShift's conformance test suite][ocp-tests]. This setup uses libvirt
  domains (QEMU/KVM based virtual machines) to simulate a bare-metal server and auxiliary resources. [sushy-emulator][
  sushy-emulator] provides a virtual Redfish BMC to power cycle the server and mount virtual media for provisioning.
  Beware that this setup requires 32GB of RAM.
* Hosts [`lvrt-lcl-session-srv-8*`][inventory-example] showcase how to deploy an OpenStack cloud with [Kolla Ansible][
  kolla-ansible]. Beware of high resource utilization, e.g. this cluster requires >=96GB of RAM.

[cloud-init-doc]: https://cloudinit.readthedocs.io/
[devstack]: https://docs.openstack.org/devstack/latest/
[tripleo-standalone-setup]: https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/deployment/standalone.html
[pxe-hwfp]: roles/pxe_hwfp/README.md
[pxe-installer]: roles/pxe_installer/README.md
[pxe-wiki]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
[okd]: https://www.okd.io/
[ocp-abi]: https://docs.openshift.com/container-platform/4.13/installing/installing_with_agent_based_installer/preparing-to-install-with-agent-based-installer.html
[okd-ipi]: https://docs.okd.io/latest/installing/installing_bare_metal_ipi/ipi-install-overview.html
[ocp-ipi]: https://docs.openshift.com/container-platform/4.13/installing/installing_bare_metal_ipi/ipi-install-overview.html
[ocp-sno]: https://docs.openshift.com/container-platform/4.13/installing/installing_sno/install-sno-preparing-to-install-sno.html
[ocp-tests]: https://github.com/openshift/origin
[sushy-emulator]: https://docs.openstack.org/sushy-tools/latest/user/dynamic-emulator.html
[virtualbmc]: https://docs.openstack.org/virtualbmc/latest/
[kolla-ansible]: https://docs.openstack.org/kolla-ansible/latest/

This collection has been developed and tested for compatibility with:
* Debian 10 (Buster)
* Debian 11 (Bullseye)
* Debian 12 (Bookworm)
* Debian 13 (Trixie)
* Fedora
* Red Hat Enterprise Linux (RHEL) 7 / CentOS Linux 7
* Red Hat Enterprise Linux (RHEL) 8 / CentOS Stream 8
* Red Hat Enterprise Linux (RHEL) 9 / CentOS Stream 9
* Ubuntu 18.04 LTS (Bionic Beaver)
* Ubuntu 20.04 LTS (Focal Fossa)
* Ubuntu 22.04 LTS (Jammy Jellyfish)
* Ubuntu 24.04 LTS (Noble Numbat)

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
  allows to use Ansible modules and action plugins such as [`lineinfile`][ansible-builtin-lineinfile] and [`copy`][
  ansible-builtin-copy] in `host_vars` and `group_vars` to edit lines in files, copy directories etc.

[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[cloudinit-tasks-main]: roles/cloudinit/tasks/main.yml

* Users are experts. Users know what to do (once you give them the options). Users have to understand the code to
  reliable and securely operate systems. Users have to understand the code to debug it due to
  [leaky abstractions][leaky-abstraction].

[leaky-abstraction]: https://en.wikipedia.org/wiki/Leaky_abstraction

## Quickstart

**NOTE:** This section lists a minimal set of commands to spin up the Ansible hosts, i.e. virtual machines, from the
[example inventory][inventory-example]. For a complete guide on how to use this collection and how to build your own
cloud infrastructure based on this collection, read the following sections.

Install `git` and [Podman](#installing-podman) on a bare-metal system with Debian 11 (Bullseye), CentOS Stream 8,
Ubuntu 22.04 LTS (Jammy Jellyfish) or newer. Ensure the system [has KVM nested virtualization enabled](
#enable-kvm-nested-virtualization), has enough storage to store disk images for the virtual machines and is **not**
connected to ip networks `192.168.152.0/24` up to `192.168.158.0/24` and does **not** have bridges `virbr-local-0` to
`virbr-local-7`. Then run:

```sh
git clone https://github.com/JM1/ansible-collection-jm1-cloudy.git
cd ansible-collection-jm1-cloudy/
cp -i ansible.cfg.example ansible.cfg

cd containers/
sudo DEBUG=yes DEBUG_SHELL=yes ./podman-compose.sh up
```

The last command will create various Podman volumes, a Podman container named `cloudy` with host networking, and attach
to it. Inside the container a Bash shell will be spawned for user `cloudy`. This user `cloudy` will be executing the
libvirt domains (QEMU/KVM based virtual machines) from the [example inventory][inventory-example]. For example, to
launch a virtual machine with Debian 12 (Bookworm) run the following commands from `cloudy`'s Bash shell:

```sh
ansible-playbook playbooks/site.yml --limit lvrt-lcl-session-srv-022-debian12
```

Once Ansible is done, launch another shell at the container host (the bare-metal system) and connect to the virtual
machine with:

```sh
sudo podman exec -ti -u cloudy cloudy ssh ansible@192.168.158.21
```

The ip address `192.168.158.21` is assigned to network interface `eth0` from the virtual machine
`lvrt-lcl-session-srv-022-debian12.home.arpa` and can be retrieved from the Ansible inventory, i.e. from file
[inventory/host_vars/lvrt-lcl-session-srv-022-debian12.yml](
inventory/host_vars/lvrt-lcl-session-srv-022-debian12.yml).

Back at `cloudy`'s Bash shell inside the container, remove the virtual machine for Ansible host
`lvrt-lcl-session-srv-022-debian12` with:

```sh
# Note the .home.arpa suffix
virsh destroy lvrt-lcl-session-srv-022-debian12.home.arpa
virsh undefine --remove-all-storage --nvram lvrt-lcl-session-srv-022-debian12.home.arpa
```

A few Ansible hosts from the [example inventory][inventory-example] have to be launched in a given order. These
dependencies are codified with Ansible groups `build_level0`, `build_level1` et cetera in [inventory/hosts.yml](
inventory/hosts.yml). Each Ansible host is member of exactly one `build_level*` group. For example, when deploying a
[installer-provisioned][okd-ipi] [OKD cluster][okd], the Ansible host `lvrt-lcl-session-srv-430-okd-ipi-provisioner` has
to be provisioned after all other `lvrt-lcl-session-srv-4*` hosts have been installed successfully:

:warning: **WARNING:** Beware of high resource utilization, e.g. this cluster requires >96GB of RAM. :warning:

```sh
ansible-playbook playbooks/site.yml --limit \
lvrt-lcl-session-srv-400-okd-ipi-router,\
lvrt-lcl-session-srv-401-okd-ipi-bmc,\
lvrt-lcl-session-srv-410-okd-ipi-cp0,\
lvrt-lcl-session-srv-411-okd-ipi-cp1,\
lvrt-lcl-session-srv-412-okd-ipi-cp2,\
lvrt-lcl-session-srv-420-okd-ipi-w0,\
lvrt-lcl-session-srv-421-okd-ipi-w1

ansible-playbook playbooks/site.yml --limit lvrt-lcl-session-srv-430-okd-ipi-provisioner
```

Removal does not impose any order:

```sh
for vm in \
  lvrt-lcl-session-srv-400-okd-ipi-router.home.arpa \
  lvrt-lcl-session-srv-401-okd-ipi-bmc.home.arpa \
  lvrt-lcl-session-srv-410-okd-ipi-cp0.home.arpa \
  lvrt-lcl-session-srv-411-okd-ipi-cp1.home.arpa \
  lvrt-lcl-session-srv-412-okd-ipi-cp2.home.arpa \
  lvrt-lcl-session-srv-420-okd-ipi-w0.home.arpa \
  lvrt-lcl-session-srv-421-okd-ipi-w1.home.arpa \
  lvrt-lcl-session-srv-430-okd-ipi-provisioner.home.arpa
do
    virsh destroy "$vm"
    virsh undefine --remove-all-storage --nvram "$vm"
done
```

Some setups such as the [OKD clusters][okd] build with Ansible hosts `lvrt-lcl-session-srv-{4,5,6}*` use internal DHCP
and DNS services which are not accessible from the container host. For example, to access the [OKD clusters][okd]
connect from `cloudy`'s Bash shell to the virtual machines which initiate the cluster installation, i.e. Ansible host
`lvrt-lcl-session-srv-430-okd-ipi-provisioner`:

```sh
ssh ansible@192.168.158.28
```

From `ansible`'s Bash shell the [OKD cluster][okd] can be accessed with:

```sh
export KUBECONFIG=/home/ansible/clusterconfigs/auth/kubeconfig
oc get nodes
oc debug node/cp0
```

Exit `cloudy`'s Bash shell to stop the container.

**NOTE:** Any virtual machines still running inside the container will be killed!

Finally, remove all Podman containers, networks and volumes related to this collection with:

```sh
sudo DEBUG=yes ./podman-compose.sh down
```

## Included content

Click on the name of an inventory, module, playbook or role to view that content's documentation:

- **Inventories**:
    * [inventory/](inventory/hosts.yml)
- **Playbooks**:
    * [setup.yml](playbooks/setup.yml)
    * [site.yml](playbooks/site.yml)
- **Roles**:
    * [apparmor](roles/apparmor/README.md)
    * [chrony](roles/chrony/README.md)
    * [cloudinit](roles/cloudinit/README.md)
    * [debconf](roles/debconf/README.md)
    * [devstack](roles/devstack/README.md)
    * [dhcpd](roles/dhcpd/README.md)
    * [dnsmasq](roles/dnsmasq/README.md)
    * [files](roles/files/README.md)
    * [groups](roles/groups/README.md)
    * [grub](roles/grub/README.md)
    * [httpd](roles/httpd/README.md)
    * [initrd](roles/initrd/README.md)
    * [ipmi](roles/ipmi/README.md)
    * [iptables](roles/iptables/README.md)
    * [kolla_ansible](roles/kolla_ansible/README.md)
    * [kubernetes_resources](roles/kubernetes_resources/README.md)
    * [libvirt_domain](roles/libvirt_domain/README.md)
    * [libvirt_domain_state](roles/libvirt_domain_state/README.md)
    * [libvirt_images](roles/libvirt_images/README.md)
    * [libvirt_networks](roles/libvirt_networks/README.md)
    * [libvirt_pools](roles/libvirt_pools/README.md)
    * [libvirt_volumes](roles/libvirt_volumes/README.md)
    * [meta_packages](roles/meta_packages/README.md)
    * [netplan](roles/netplan/README.md)
    * [networkmanager](roles/networkmanager/README.md)
    * [openshift_client](roles/openshift_client/README.md)
    * [openshift_abi](roles/openshift_abi/README.md)
    * [openshift_ipi](roles/openshift_ipi/README.md)
    * [openshift_sno](roles/openshift_sno/README.md)
    * [openshift_tests](roles/openshift_tests/README.md)
    * [openstack_server](roles/openstack_server/README.md)
    * [packages](roles/packages/README.md)
    * [podman](roles/podman/README.md)
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

For starting off with this collection, first [derive your own cloud infrastructure from the content of this collection
such as inventories, playbooks and roles and prepare your host environment](
#define-cloud-infrastructure-and-prepare-host-environment).

To deploy this customized cloud infrastructure, you can either [deploy a container with Docker Compose](
#containerized-setup-with-docker-compose), [deploy a container with Podman](#containerized-setup-with-podman) or
[utilize a bare-metal system](#bare-metal-setup). Both container-based approaches will start [libvirt][libvirt], bridged
networks and all QEMU/KVM based virtual machines in a single container. This is easier to get started with, is mostly
automated, requires less changes to the Ansible controller system and is less likely to break your host system.

### Define cloud infrastructure and prepare host environment

To build your own cloud infrastructure based on this collection, create a new git repository and copy both directories
[`inventory/`][inventory-example] and [`playbooks/`][playbooks-example] as well as file [`ansible.cfg.example`][
ansible-cfg-example] to it. For a containerized setup with [Docker](#containerized-setup-with-docker-compose) or
[Podman](#containerized-setup-with-podman) also copy directory [`containers/`][containers-example]. Instead of copying
[`containers/`][containers-example] and [`playbooks/`][playbooks-example] you could also add this collection as a
[git submodule][git-submodules] and refer directly to those directories inside the git submodule. Git submodules can be
difficult to use but allow to pin your code a specific commit of this collection, making it more resilient against
breaking changes. The following example shows how to use derive a new project utilizing containers and [git submodules][
git-submodules]:

```sh
git init new-project
cd new-project

git submodule add https://github.com/JM1/ansible-collection-jm1-cloudy.git vendor/cloudy

cp -ri vendor/cloudy/inventory/ .
ln -s vendor/cloudy/playbooks
cp -i vendor/cloudy/ansible.cfg.example ansible.cfg

git add inventory/ playbooks ansible.cfg # git submodule has been added already

git commit -m "Example inventory"
```

[ansible-cfg-example]: ansible.cfg.example
[containers-example]: containers/
[inventory-example]: inventory/
[playbooks-example]: playbooks/
[git-submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules

Host `lvrt-lcl-system` defines a libvirt environment to be set up on a bare-metal system or inside a container. For
example, this includes required packages for libvirt and QEMU, [libvirt virtual networks][libvirt-networking] such as
[NAT based networks as well as isolated networks][libvirt-format-network]) and a default libvirt storage pool.

Host `lvrt-lcl-session` defines the libvirt session of your local user on a bare-metal system or user `cloudy` inside
the container. For example, this includes a default libvirt storage pool and OS images for host provisioning.

All remaining Ansible hosts inside the [example inventory][inventory-example] define libvirt domains (QEMU/KVM based
virtual machines) which require both hosts `lvrt-lcl-system` and `lvrt-lcl-session` to be provisioned successfully.

[libvirt-networking]: https://wiki.libvirt.org/page/Networking
[libvirt-format-network]: https://libvirt.org/formatnetwork.html

Dig into the inventory and playbooks and customize them as needed.

Edit `ansible.cfg` to match your environment, i.e. set `inventory` path where Ansible will find your inventory:

```sh
cp -nv ansible.cfg.example ansible.cfg
editor ansible.cfg
```

Ensure you have valid SSH public keys for SSH logins, e.g. a RSA public key at `$HOME/.ssh/id_rsa.pub`. If no key exists
at `$HOME/.ssh/id_{dsa,ecdsa,ed25519,rsa}.pub` generate a new key pair with `ssh-keygen` or edit Ansible variable
`ssh_authorized_keys` in `inventory/group_vars/all.yml` to include your SSH public key:

```yaml
ssh_authorized_keys:
- comment: John Wayne (Megacorp)
  key: ssh-rsa ABC...XYZ user@host
  state: present
  user: '{{ ansible_user }}'
```

### Containerized setup with Docker Compose

To run playbooks and roles of this collection with Docker Compose,

* [Docker or Podman and Docker Compose have to be installed](#installing-docker-or-podman-and-docker-compose),
* [KVM nested virtualization has to be enabled](#enable-kvm-nested-virtualization),
* [a container has to be started with Docker Compose](#start-container-with-docker-compose).

#### Installing Docker or Podman and Docker Compose

Ensure Docker or [Podman][docker-to-podman-transition] is installed on your system.

| OS  | Install Instructions |
| --- | -------------------- |
| Debian 10 (Buster), 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `apt install docker.io docker-compose` or follow [Docker's official install guide][docker-install-debian] for Debian and [their install guide for Docker Compose][docker-compose-install] |
| Fedora | Follow Docker's official install guide for [Fedora][docker-install-fedora] and [their install guide for Docker Compose][docker-compose-install] or use [Podman][podman-install] with [Docker Compose][podman-docker-compose] |
| Red Hat Enterprise Linux (RHEL) 7, 8, 9 / CentOS Linux 7, CentOS Stream 8, 9 | Follow Docker's official install guide for [CentOS][docker-install-centos] and [RHEL][docker-install-rhel] and [their install guide for Docker Compose][docker-compose-install] or use [Podman][podman-install] with [Docker Compose][podman-docker-compose] |
| Ubuntu 18.04 LTS (Bionic Beaver), 20.04 LTS (Focal Fossa), 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat) | `apt install docker.io docker-compose` or follow [Docker's official install guide][docker-install-ubuntu] for Ubuntu and [their install guide for Docker Compose][docker-compose-install] |

[docker-compose-install]: https://docs.docker.com/compose/install/
[docker-install-centos]: https://docs.docker.com/engine/install/centos/
[docker-install-debian]: https://docs.docker.com/engine/install/debian/
[docker-install-fedora]: https://docs.docker.com/engine/install/fedora/
[docker-install-ubuntu]: https://docs.docker.com/engine/install/ubuntu/
[docker-install-rhel]: https://docs.docker.com/engine/install/rhel/
[docker-to-podman-transition]: https://developers.redhat.com/blog/2020/11/19/transitioning-from-docker-to-podman/
[podman-docker-compose]: https://www.redhat.com/sysadmin/podman-docker-compose
[podman-install]: https://podman.io/docs/installation

#### Enable KVM nested virtualization

Some libvirt domains (QEMU/KVM based virtual machines) like the [DevStack][devstack] and [TripleO standalone][
tripleo-standalone-setup] hosts require KVM nested virtualization to be enabled on the container host, the system
running Docker or Podman.

To enable KVM nested virtualization for Intel and AMD CPUs, run Ansible role [`jm1.kvm_nested_virtualization`][
galaxy-jm1-kvm-nested-virtualization] on your container host or execute the commands shown in its [`README.md`][
jm1-kvm-nested-virtualization-readme] manually.

[galaxy-jm1-kvm-nested-virtualization]: https://galaxy.ansible.com/jm1/kvm_nested_virtualization
[jm1-kvm-nested-virtualization-readme]: https://github.com/JM1/ansible-role-jm1-kvm-nested-virtualization/blob/master/README.md

#### Start container with Docker Compose

Docker Compose helps with managing Docker storage volumes, establishing network connectivity between host and container
as well as running our Ansible code and virtual machines inside containers.

**NOTE:** The Docker container shares the [host's networking namespace][docker-network-host], i.e. its network stack
will not be isolated from the Docker host. The [example inventory][inventory-example], i.e. Ansible variable
`libvirt_networks` in [inventory/host_vars/lvrt-lcl-system.yml](inventory/host_vars/lvrt-lcl-system.yml), defines
several libvirt networks whose bridges `virbr-local-0` to `virbr-local-7` and ip networks `192.168.152.0/24` up to
`192.168.158.0/24` will be created, visible and accessible on the Docker host. Ensure those bridges and ip networks are
not present at the Docker host before running `docker-compose`.

[docker-network-host]: https://docs.docker.com/network/host/

**NOTE:** The libvirt daemon running inside the container allows unprivileged access on TCP port 16509. It is exposed on
the network because the container shares the [host's networking namespace][docker-network-host]. The
[example inventory][inventory-example] creates [nftables][nftables]/[iptables][iptables] rules (in chains `INPUT` and
`INPUT_CLOUDY`) to only allow access for legit traffic from localhost and ip network `192.168.153.0/24`. Ensure to
update the ruleset when changing the inventory, in particular Ansible variable `iptables_config` in
[`inventory/host_vars/lvrt-lcl-system.yml`][inventory-lvrt-lcl-system].

**NOTE:** Bridges `virbr-local-0` to `virbr-local-7`, ip networks `192.168.152.0/24` up to `192.168.158.0/24`, and
[iptables][iptables]/[nftables][nftables] chains `INPUT`, `INPUT_CLOUDY`, `POSTROUTING` and `POSTROUTING_CLOUDY` in
table `nat` will not be deleted from the Docker host when the Docker container exits. They have to be deleted manually.

Open a `docker-compose.yml.*` in your copy of the [`containers/`][containers-example] directory which matches the
distribution of the container host. The following example assumes that the container host is running on
`Debian 11 (Bullseye)`. The matching Docker Compose file is named `docker-compose.yml.debian_11`. To start it, run these
commands on the container host:

```sh
# Change to Docker Compose directory inside your project directory
# containing your Ansible inventory, playbooks and ansible.cfg
cd containers/

# Start container in the background
DEBUG=yes DEBUG_SHELL=yes docker-compose -f docker-compose.yml.debian_11 -p cloudy up -d

# Monitor container activity
docker-compose -f docker-compose.yml.debian_11 -p cloudy logs --follow
```

Inside the container, script [`containers/entrypoint.sh`][containers-entrypoint-sh] will execute playbook
[`playbooks/site.yml`][playbook-site-yml] for hosts `lvrt-lcl-system` and `lvrt-lcl-session`, as [defined in the
inventory](#define-cloud-infrastructure-and-prepare-host-environment). When container execution fails, try to start the
container again.

[containers-entrypoint-sh]: containers/entrypoint.sh

When all Ansible playbook runs for both Ansible hosts `lvrt-lcl-system` and `lvrt-lcl-session` have been completed
successfully, attach to the Bash shell for user `cloudy` running inside the container:

```sh
# Attach to Bash shell for user cloudy who runs the libvirt domains (QEMU/KVM based virtual machines)
docker attach cloudy
```
Inside the container continue with [running playbook `playbooks/site.yml` for all remaining hosts](#usage-and-playbooks)
from your copy of the [`inventory/`][inventory-example] directory which is available in `/home/cloudy/project`.

To connect to the libvirt daemon running inside the container from the container host, run the following command at your
container host:

```sh
# List all libvirt domains running inside the container
virsh --connect 'qemu+tcp://127.0.0.1:16509/session' list
```

The same connection URI `qemu+tcp://127.0.0.1:16509/session` can also be used with virt-manager at the container host.
To view a virtual machine's graphical console, its Spice server or VNC server has to be changed, i.e. its listen type
has to be changed to `address`, and port has to be changed to a number between `5900-5999`. Then view its graphical
console on your container host with:

```sh
# View a libvirt domain's graphical console with vnc server at port 5900 running inside the container
remote-viewer vnc://127.0.0.1:5900
```

To stop and remove the container(s), exit the container's Bash shells and run on your container host:

```sh
# Stop and remove container(s)
docker-compose -f docker-compose.yml.debian_11 -p cloudy down
```

Both the SSH credentials and the libvirt storage volumes of the libvirt domains (QEMU/KVM based virtual machines) have
been persisted in Docker volumes which will not be deleted when shutting down the Docker container. To list and wipe
those Docker volumes, run:

```sh
# List all Docker volumes
docker volume ls

# Remove Docker volumes
docker volume rm cloudy_images cloudy_ssh
```

To remove all bridges, networks and nftables/iptables chains, run:

```sh
# Delete bridges and ip networks
for i in $(seq 0 7); do sudo ip link del "virbr-local-$i"; done

# Delete nftables chain
nft delete chain ip filter INPUT_CLOUDY
nft delete chain ip nat POSTROUTING_CLOUDY
# Or delete iptables chain
iptables -t filter -D INPUT -j INPUT_CLOUDY
iptables -t filter -F INPUT_CLOUDY
iptables -t filter -X INPUT_CLOUDY
iptables -t nat -D POSTROUTING -j POSTROUTING_CLOUDY
iptables -t nat -F POSTROUTING_CLOUDY
iptables -t nat -X POSTROUTING_CLOUDY
```

### Containerized setup with Podman

To run playbooks and roles of this collection with Podman,

* [Podman has to be installed](#installing-podman),
* [KVM nested virtualization has to be enabled](#enable-kvm-nested-virtualization),
* [a container has to be started with Podman](#start-container-with-podman).

#### Installing Podman

Ensure [Podman][podman-install] is installed on your system.

| OS  | Install Instructions |
| --- | -------------------- |
| Debian 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `apt install podman` |
| Fedora | `dnf install podman` |
| Red Hat Enterprise Linux (RHEL) 7, 8, 9 / CentOS Linux 7, CentOS Stream 8, 9 | `yum install podman` |
| Ubuntu 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat) | `apt install podman` |

#### Start container with Podman

[`podman-compose.sh`][podman-compose-sh] helps with managing Podman storage volumes, establishing network connectivity
between host and container as well as running our Ansible code and virtual machines inside containers. It offers command
line arguments similar to `docker-compose`, run `containers/podman-compose.sh --help` to find out more about its usage.

[podman-compose-sh]: containers/podman-compose.sh

**NOTE:** The Podman container shares the [host's networking namespace][podman-networking], i.e. its network stack
will not be isolated from the container host. The [example inventory][inventory-example], i.e. Ansible variable
`libvirt_networks` in [inventory/host_vars/lvrt-lcl-system.yml](inventory/host_vars/lvrt-lcl-system.yml), defines
several libvirt networks whose bridges `virbr-local-0` to `virbr-local-7` and ip networks `192.168.152.0/24` up to
`192.168.158.0/24` will be created, visible and accessible on the container host. Ensure those bridges and ip networks
are not present at the container host before running [`podman-compose.sh`][podman-compose-sh].

**NOTE:** The libvirt daemon running inside the container allows unprivileged access on TCP port 16509. It is exposed on
the network because the container shares the [host's networking namespace][podman-networking]. The
[example inventory][inventory-example] creates [nftables][nftables]/[iptables][iptables] rules (in chains `INPUT` and
`INPUT_CLOUDY`) to only allow access for legit traffic from localhost and ip network `192.168.153.0/24`. Ensure to
update the ruleset when changing the inventory, in particular Ansible variable `iptables_config` in
[`inventory/host_vars/lvrt-lcl-system.yml`][inventory-lvrt-lcl-system].

**NOTE:** Bridges `virbr-local-0` to `virbr-local-7`, ip networks `192.168.152.0/24` up to `192.168.158.0/24`, and
[iptables][iptables]/[nftables][nftables] chains `INPUT`, `INPUT_CLOUDY`, `POSTROUTING` and `POSTROUTING_CLOUDY` in
table `nat` will not be deleted from the container host when the Podman container exits. They have to be deleted
manually.

[podman-networking]: https://www.redhat.com/sysadmin/container-networking-podman

The following example shows how to use an example of how to use [`podman-compose.sh`][podman-compose-sh] at a container
host running on `Debian 11 (Bullseye)`:

```sh
# Change to containers directory inside your project directory
# containing your Ansible inventory, playbooks and ansible.cfg
cd containers/

# Start Podman networks, volumes and containers in the background
sudo DEBUG=yes DEBUG_SHELL=yes ./podman-compose.sh up --distribution debian_11 --detach

# Monitor container activity
sudo podman logs --follow cloudy
```

Inside the container, script [`containers/entrypoint.sh`][containers-entrypoint-sh] will execute playbook
[`playbooks/site.yml`][playbook-site-yml] for hosts `lvrt-lcl-system` and `lvrt-lcl-session`, as [defined in the
inventory](#define-cloud-infrastructure-and-prepare-host-environment). When container execution fails, try to start the
container again.

[containers-entrypoint-sh]: containers/entrypoint.sh

When all Ansible playbook runs for both Ansible hosts `lvrt-lcl-system` and `lvrt-lcl-session` have been completed
successfully, attach to the Bash shell for user `cloudy` running inside the container:

```sh
# Attach to Bash shell for user cloudy who runs the libvirt domains (QEMU/KVM based virtual machines)
sudo podman attach cloudy
```

Inside the container continue with [running playbook `playbooks/site.yml` for all remaining hosts](#usage-and-playbooks)
from your copy of the [`inventory/`][inventory-example] directory which is available in `/home/cloudy/project`.

To connect to the libvirt daemon running inside the container from the container host, run the following command at your
container host:

```sh
# List all libvirt domains running inside the container
virsh --connect 'qemu+tcp://127.0.0.1:16509/session' list
```

The same connection URI `qemu+tcp://127.0.0.1:16509/session` can also be used with virt-manager at the container host.
To view a virtual machine's graphical console, its Spice server or VNC server has to be changed, i.e. its listen type
has to be changed to `address`, and port has to be changed to a number between `5900-5999`. Then view its graphical
console on your container host with:

```sh
# View a libvirt domain's graphical console with vnc server at port 5900 running inside the container
remote-viewer vnc://127.0.0.1:5900
```

To stop the containers, exit the container's Bash shells and run on your container host:

```sh
# Stop containers
sudo DEBUG=yes ./podman-compose.sh stop
```

Both the SSH credentials and the libvirt storage volumes of the libvirt domains (QEMU/KVM based virtual machines) have
been persisted in Podman volumes which will not be deleted when stopping the Podman container:

```sh
# List all Podman volumes
sudo podman volume ls
```

To remove all containers and wipe all volumes, run:

```sh
# Stop and remove containers and volumes
sudo DEBUG=yes ./podman-compose.sh down
```

To remove all bridges, networks and nftables/iptables chains, run:

```sh
# Delete bridges and ip networks
for i in $(seq 0 7); do sudo ip link del "virbr-local-$i"; done

# Delete nftables chain
nft delete chain ip filter INPUT_CLOUDY
nft delete chain ip nat POSTROUTING_CLOUDY
# Or delete iptables chain
iptables -t filter -D INPUT -j INPUT_CLOUDY
iptables -t filter -F INPUT_CLOUDY
iptables -t filter -X INPUT_CLOUDY
iptables -t nat -D POSTROUTING -j POSTROUTING_CLOUDY
iptables -t nat -F POSTROUTING_CLOUDY
iptables -t nat -X POSTROUTING_CLOUDY
```

### Bare-metal setup

To use this collection on a bare-metal system,

* Ansible 2.9 or greater [^minimum-ansible-version] has to be installed either
  [with `pip`](#installing-ansible-29-with-pip) or
  [using distribution-provided packages](#installing-ansible-29-on-specific-operating-systems),
* [necessary Ansible roles and collections have to be fetched](#installing-ansible-roles-and-collections),
* [their requirements have to be satisfied](#satisfying-collections-requirements),
* [this collection has to be installed from Ansible Galaxy](#installing-the-collection-from-ansible-galaxy) and
* [the bare-metal system has to be configured with Ansible](#configure-bare-metal-system-with-ansible).

[^minimum-ansible-version]: [Ansible Collections][ansible-collections] have been introduced in Ansible 2.9, hence for
collection support a release equal to version 2.9 or greater has to be installed.

[ansible-collections]: https://github.com/ansible-collections/overview/blob/main/README.rst

Ansible's [Installation Guide][ansible-installation-guide] provides instructions on how to install Ansible on several
operating systems and with `pip`.

[ansible-installation-guide]: https://docs.ansible.com/ansible/latest/installation_guide/

#### Installing Ansible 2.9+ with `pip`

First, make sure that `pip` is available on your system.

| OS  | Install Instructions |
| --- | -------------------- |
| Debian 10 (Buster), 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `apt install python3 python3-pip` |
| Red Hat Enterprise Linux (RHEL) 7, 8, 9 / CentOS Linux 7, CentOS Stream 8, 9 | `yum install python3 python3-pip` |
| Ubuntu 18.04 LTS (Bionic Beaver), 20.04 LTS (Focal Fossa), 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat) | `apt install python3 python3-pip` |

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

| OS  | Install Instructions |
| --- | -------------------- |
| Debian 10 (Buster)  | Enable [Backports](https://backports.debian.org/Instructions/). `apt install ansible ansible-doc make` |
| Debian 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `apt install ansible make` |
| Fedora | `dnf install ansible make` |
| Red Hat Enterprise Linux (RHEL) 7 / CentOS Linux 7 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible ansible-doc make` |
| Red Hat Enterprise Linux (RHEL) 8, 9 / CentOS Stream 8, 9 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible make` |
| Ubuntu 18.04 LTS (Bionic Beaver), 20.04 LTS (Focal Fossa) | Enable [Launchpad PPA Ansible by Ansible, Inc.](https://launchpad.net/~ansible/+archive/ubuntu/ansible). `apt install ansible ansible-doc make` |
| Ubuntu 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat) | `apt install ansible make` |

Some Ansible modules used in this collection require additional tools and Python libraries which have to be installed 
manually. Refer to [`pip-requirements.txt`][pip-requirements-txt] for a complete list. Use a [package search][pkgs-org]
to find matching packages for your distribution.

[pkgs-org]: https://pkgs.org/
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

:warning: **WARNING:**
Ansible collections such as `community.general` have dropped support for older Ansible releases such as Ansible 2.9 and
2.10, so when using older Ansible releases you will have to downgrade to older versions of the Ansible collections.
:warning:

#### Satisfying collections requirements

These collections require additional tools and libraries, e.g. to interact with package managers, libvirt and OpenStack.
You can use the following roles to install necessary software packages:

```sh
sudo -s

ansible-playbook playbooks/setup.yml
# or
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

#### Installing the Collection from Ansible Galaxy

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
    version: 2024.5.30
```

#### Configure bare-metal system with Ansible

To configure and run the libvirt domains (QEMU/KVM based virtual machines) defined in the [example inventory][
inventory-example], both Ansible hosts `lvrt-lcl-system` and `lvrt-lcl-session` have to be provisioned successfully
first. Executing playbook [`playbooks/site.yml`][playbook-site-yml] for hosts `lvrt-lcl-system` and `lvrt-lcl-session`
will create several [libvirt virtual networks][libvirt-networking], both [NAT based networks as well as isolated
networks][libvirt-format-network]. For each network, a bridge will be created with names `virbr-local-0` to
`virbr-local-7`. To each network an ip subnet will be assigned, from `192.168.151.0/24` to `192.168.158.0/24`. The
libvirt virtual networks are defined with variable `libvirt_networks` in [`inventory/host_vars/lvrt-lcl-system.yml`][
inventory-lvrt-lcl-system].

[playbook-site-yml]: playbooks/site.yml
[inventory-lvrt-lcl-system]: inventory/host_vars/lvrt-lcl-system.yml

Before running the playbooks for hosts `lvrt-lcl-system` and `lvrt-lcl-session`, please make sure that no bridges with
such names do exist on your system. Please also verify that the ip subnets `192.168.151.0/24` to `192.168.156.0/24` are
not currently known to your system. For example, use `ip addr` to show all IPv4 and IPv6 addresses assigned to all
network interfaces.

Both ip subnets `192.168.157.0/24` and `192.168.158.0/24` have either to be published to your router(s), probably your
standard gateway only, or your bare-metal system has to do masquerading.

Once ip subnets have been set up properly, the libvirtd configuration for your local user (not root) has to be changed
to allow tcp connections from libvirt isolated network `192.168.153.0/24` which is used for virtual BMCs:

```sh
# Disable libvirt tls transport, enable unauthenticated libvirt tcp transport
# and bind to 192.168.153.1 for connectivity from libvirt domains.
mkdir -p ~/.config/libvirt/
cp -nv /etc/libvirt/libvirtd.conf ~/.config/libvirt/libvirtd.conf
sed -i \
    -e 's/^[#]*listen_tls = .*/listen_tls = 0/g' \
    -e 's/^[#]*listen_tcp = .*/listen_tcp = 1/g' \
    -e 's/^[#]*listen_addr = .*/listen_addr = "192.168.153.1"/g' \
    -e 's/^[#]*auth_tcp = .*/auth_tcp = "none"/g' \
    ~/.config/libvirt/libvirtd.conf
```

An SSH agent must be running and your SSH private key(s) must be loaded. Ansible will use SSH agent forwarding to access
nested virtual machines such as the bootstrap virtual machine of [OpenShift Installer-provisioned installation (IPI)][
ocp-ipi] or [OKD Installer-provisioned installation (IPI)][okd-ipi].

```sh
# Start ssh-agent and add SSH private keys if ssh-agent is not running
if [ -z "$SSH_AGENT_PID" ]; then
    eval $(ssh-agent)
    ssh-add
fi

# Ensure your SSH public key is listed
ssh-add -L
```

:warning: **WARNING:**
Run the following playbooks on disposable non-productive bare-metal machines only.
They will apply changes that might break your system.
:warning:

Run playbook `playbooks/site.yml` for host `lvrt-lcl-system` to prepare a libvirt environment on your system, e.g. to
install packages for libvirt and QEMU, configure libvirt networks and prepare a default libvirt storage pool.

```sh
# Cache user credentials so that Ansible can escalate privileges and execute tasks with root privileges
sudo true

ansible-playbook playbooks/site.yml --limit lvrt-lcl-system
```

The former will also enable masquerading with [nftables][nftables] or [iptables][iptables] (if [nftables][nftables] is
unavailable) on your bare-metal system for both ip subnets `192.168.157.0/24` and `192.168.158.0/24`.
The [nftables][nftables] / [iptables][iptables] are defined in Ansible variable `iptables_config` in
[`inventory/host_vars/lvrt-lcl-system.yml`][inventory-lvrt-lcl-system].

**NOTE:** The changes applied to [nftables][nftables] and [iptables][iptables] are not persistant and will not survive
reboots. Please refer to your operating system's documentation on how to store [nftables][nftables] or [iptables][
iptables] rules persistently. Or run `playbooks/site.yml` again after rebooting.

[nftables]: https://wiki.archlinux.org/title/Nftables
[iptables]: https://wiki.archlinux.org/title/Iptables

Run playbook `playbooks/site.yml` for host `lvrt-lcl-session` to prepare the libvirt session of your local user, e.g. to
prepare a default libvirt storage pool and preload OS images for host provisioning.

```sh
ansible-playbook playbooks/site.yml --limit lvrt-lcl-session
```

With both hosts `lvrt-lcl-system` and `lvrt-lcl-session` being set up, continue with [running playbook
`playbooks/site.yml` for all remaining hosts](#usage-and-playbooks).

## Usage and Playbooks

The [example inventory][inventory-example] of this collection, [on which your cloud infrastructure can be build upon](
#define-cloud-infrastructure-and-prepare-host-environment), defines several libvirt domains (QEMU/KVM based virtual
machines) `lvrt-lcl-session-srv-*` and two special Ansible hosts `lvrt-lcl-system` and `lvrt-lcl-session`. The latter
two have been used above to [deploy a container with Docker Compose](#containerized-setup-with-docker-compose),
[deploy a container with Podman](#containerized-setup-with-podman) or[prepare a bare-metal system](#bare-metal-setup)
and are not of interest here. For an overview about the libvirt domains please refer to the introduction at the
beginning.

For example, to set up Ansible host `lvrt-lcl-session-srv-020-debian10` run the following command from inside [your
project directory](#define-cloud-infrastructure-and-prepare-host-environment) as local non-root user, e.g. `cloudy` in
[containerized setup](#containerized-setup-with-docker-compose):

```sh
# Set up and boot a libvirt domain (QEMU/KVM based virtual machine) based on Debian 10 (Buster)
ansible-playbook playbooks/site.yml --limit lvrt-lcl-session-srv-020-debian10
```

Inside [`inventory/host_vars/lvrt-lcl-session-srv-020-debian10.yml`][inventory-example-host] you will find the ip address
of that system which can be used for ssh'ing into it:

[inventory-example-host]: inventory/host_vars/lvrt-lcl-session-srv-020-debian10.yml

```sh
# Establish SSH connection to Ansible host lvrt-lcl-session-srv-020-debian10
ssh ansible@192.168.158.13
```

Besides individual Ansible hosts, you can also use Ansible groups such as `build_level1`, `build_level2` and et cetera
to set up several systems in parallel.

:warning: **WARNING:**
Running playbook `playbooks/site.yml` for multiple hosts across many build levels at once will create dozens of virtual
machines. Ensure that your system has enough memory to run them in parallel. To lower memory requirements, you may want
to limit `playbooks/site.yml` to a few hosts or a single host instead. Refer to [`hosts.yml`][inventory-example] for a
complete list of hosts and build levels.
:warning:

```sh
# build_level0 contains lvrt-lcl-system and lvrt-lcl-session which have been prepared in previous steps
ansible-playbook playbooks/site.yml --limit build_level1
ansible-playbook playbooks/site.yml --limit build_level2
ansible-playbook playbooks/site.yml --limit build_level3
```

### Using content of this Collection

You can either call modules and roles by their Fully Qualified Collection Name (FQCN), like `jm1.cloudy.devstack`, or
you can call modules by their short name if you list the `jm1.cloudy` collection in the playbook's `collections`,
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

| OS  | Install Instructions |
| --- | -------------------- |
| Debian 10 (Buster) | Enable [Backports](https://backports.debian.org/Instructions/). `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |
| Debian 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `apt install ansible ansible-lint flake8 make yamllint` |
| Fedora | `dnf install ansible python3-flake8 make yamllint` |
| Red Hat Enterprise Linux (RHEL) 7 / CentOS Linux 7 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible ansible-lint ansible-doc  python-flake8 make yamllint` |
| Red Hat Enterprise Linux (RHEL) 8, 9 / CentOS Stream 8, 9 | Enable [EPEL](https://fedoraproject.org/wiki/EPEL). `yum install ansible python3-flake8 make yamllint` |
| Ubuntu 18.04 LTS (Bionic Beaver), 20.04 LTS (Focal Fossa) | Enable [Launchpad PPA Ansible by Ansible, Inc.](https://launchpad.net/~ansible/+archive/ubuntu/ansible). `apt install ansible ansible-doc ansible-lint flake8 make yamllint` |
| Ubuntu 22.04 LTS (Jammy Jellyfish), 24.04 LTS (Noble Numbat) | `apt install ansible ansible-lint flake8 make yamllint` |

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
