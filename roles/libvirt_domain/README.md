# Ansible Role `jm1.cloudy.libvirt_domain`

This role helps with defining [libvirt domains][libvirt] aka virtual machines as Ansible hosts. Similar to provisioning
in public clouds such as [OpenStack][openstack-user-data] and [Amazon EC2][amazon-ec2-user-data], configuration
information like [cloud-init][cloud-init-doc] [user data][cloud-init-examples] can be passed on a [config drive][
cloud-init-config-drive] to libvirt domains.

For example, suppose a libvirt domain `debian.home.arpa` based on Debian 11 (Bullseye) should be launched on the local
libvirt daemon (run by current Ansible user on the Ansible controller). It should be connected to bridge `virbr-nat-0`
and two libvirt volumes in storage pool `default`, one 5GB volume `debian.home.arpa.qcow2` with a fresh copy of the
Debian cloud image and one cloud-init config drive `debian.home.arpa_cidata.qcow2` with [cloud-init user data][
cloud-init-doc].

First, define [an Ansible host `debian.home.arpa` in an Ansible inventory][ansible-inventory]. A minimal [Ansible
inventory][ansible-inventory] could be defined in file `inventory/hosts.yml` as such:

```yml
all:
  hosts:
    debian.home.arpa:
```

Then define properties of host `debian.home.arpa` like cloud-init [user data][cloud-init-examples], cloud-init [network
configuration][cloud-init-network-config], libvirt block storage volumes and the hardware specification of the libvirt
domain as Ansible variables in file `inventory/host_vars/debian.home.arpa.yml`. For example:

```yml
# Hostname might not be DNS resolvable.
ansible_host: 192.168.123.2

cloudinit_networkconfig: |
  # netplan-compatible configuration for cloud-init
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      dhcp6: false
      accept-ra: false

      addresses:
      - 192.168.123.2/16

      nameservers:
        addresses:
        - 192.168.123.1
      routes:
      - to: 0.0.0.0/0
        via: 192.168.123.1

cloudinit_userdata: |
  #cloud-config
  chpasswd:
    list: |
      ansible:secret
    expire: False
  packages:
  - python3

distribution_id:
- 'Debian'
- '11'

libvirt_configdrive: '{{ inventory_hostname }}_cidata.{{ libvirt_configdrive_format }}'

libvirt_configdrive_format: 'qcow2'

libvirt_configdrive_pool: '{{ libvirt_pool }}'

# Hardware specification of the libvirt domain. Accepts all two-dash command line arguments (those with a leading '--')
# of virt-install as a list. Arguments are formatted as key-value pairs without the leading '--' and having other dashs
# replaced by underscores. Arguments without a value (flags), e.g. pxe, must be specified with a value of !!null.
# Ref.: man virt-install
libvirt_hardware:
- cpu: 'host'
- vcpus: '2'
- memory: '1024'
- virt_type: 'kvm'
- graphics: 'vnc,listen=socket'
- network: 'bridge=virbr-nat-0,model=virtio'
- disk: "vol='{{ libvirt_pool }}/{{ libvirt_volumes[0]['name'] }}',device=disk,bus=virtio,serial='root'"
- disk: "vol='{{ libvirt_pool }}/{{ libvirt_configdrive }}',device=disk,bus=virtio,serial='cidata'"
# Specifying os variant is HIGHLY RECOMMENDED, as it can greatly increase performance by specifying virtio
# among other guest tweaks. It also enables support for QEMU Guest Agent by adding a virtio-serial channel.
# Ref.: man virt-install
- os_variant: 'debian10'

# Indicate to playbooks/site.yml that libvirt-related tasks should not be executed with root privileges. Privilege
# escalation is not necessary because the local libvirt daemon (qemu:///session) on the Ansible controller is used.
libvirt_host_become: false

libvirt_pool: 'default'

# libvirt connection uri
# Ref.: https://libvirt.org/uri.html
libvirt_uri: 'qemu:///session'

libvirt_volumes:
- backing_vol: 'debian-11-genericcloud-amd64.qcow2'
  backing_vol_format: 'qcow2'
  capacity: 5G
  format: 'qcow2'
  linked: false
  name: '{{ inventory_hostname }}.qcow2'
  pool: '{{ libvirt_pool }}'
  prealloc_metadata: false
  state: present
```

Use role [`jm1.cloudy.libvirt_networks`][jm1-cloudy-libvirt-networks] to create network bridge `virbr-nat-0` as
shown in the introduction of that role.

Use role [`jm1.cloudy.libvirt_pools`][jm1-cloudy-libvirt-pools] to create libvirt storage pool `default` as shown in the
introduction of that role.

Use role [`jm1.cloudy.libvirt_images`][jm1-cloudy-libvirt-images] to fetch the cloud image of Debian 11 (Bullseye) and
add it as a volume `debian-11-genericcloud-amd64.qcow2` to storage pool `default` as shown in the introduction of that
role.

Use role [`jm1.cloudy.libvirt_volumes`][jm1-cloudy-libvirt-volumes] to create a snapshot of the Debian cloud image
`debian-11-genericcloud-amd64.qcow2` in storage pool `default` as shown in the introduction of that role.

Once all previous roles have finished, execute this role `jm1.cloudy.libvirt_domain`. It will use variables
`cloudinit_networkconfig` and `cloudinit_userdata` to create the cloud-init [config drive][cloud-init-config-drive]
`debian.home.arpa_cidata.qcow2` in storage pool `default`, using module [`jm1.libvirt.volume_cloudinit`][
jm1-libvirt-volume-cloudinit] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-configdrive-parameter].
Next, variables `libvirt_domain` and `libvirt_hardware` will be passed to [`jm1.libvirt.domain`][jm1-libvirt-domain] to
create libvirt domain `debian.home.arpa` [^libvirt-domain-parameter]. If a libvirt domain with the same name already
exists, it will not be changed. If `libvirt_domain_autostart` evaluates to `true`, then module
[`community.libvirt.virt`][community-libvirt-virt] from collection [`community.libvirt`][galaxy-community-libvirt] will
be used to mark that domain to be started automatically when the libvirt daemon starts. At the end the same module will
be used to start the newly created domain if `libvirt_domain_state` is `running`.

If `state` is `absent` then module [`community.libvirt.virt`][community-libvirt-virt] will be used to stop (destroy) the
domain, module [`jm1.libvirt.domain`][jm1-libvirt-domain] will be used to delete (undefine) the domain and module
[`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] will be used to remove the cloud-init config drive.

[^libvirt-configdrive-parameter]: For a complete list of parameters which will be passed to
[`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] refer to [`roles/libvirt_domain/tasks/main.yml`](
tasks/main.yml).

[^libvirt-domain-parameter]: For a complete list of parameters which will be passed to [`jm1.libvirt.domain`][
jm1-libvirt-domain] refer to [`roles/libvirt_domain/tasks/main.yml`](tasks/main.yml).

[amazon-ec2-user-data]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[cloud-init-config-drive]: https://cloudinit.readthedocs.io/en/latest/topics/datasources/configdrive.html
[cloud-init-doc]: https://cloudinit.readthedocs.io/
[cloud-init-examples]: https://cloudinit.readthedocs.io/en/latest/topics/examples.html
[cloud-init-network-config]: https://cloudinit.readthedocs.io/en/latest/topics/network-config.html
[community-libvirt-virt]: https://docs.ansible.com/ansible/latest/collections/community/libvirt/virt_module.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[jm1-cloudy-libvirt-images]: ../libvirt_images/
[jm1-cloudy-libvirt-networks]: ../libvirt_networks/
[jm1-cloudy-libvirt-pools]: ../libvirt_pools/
[jm1-cloudy-libvirt-volumes]: ../libvirt_volumes/
[jm1-libvirt-domain]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/domain.py
[jm1-libvirt-volume-cloudinit]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/volume_cloudinit.py
[libvirt]: https://libvirt.org/
[openstack-user-data]: https://docs.openstack.org/nova/latest/user/metadata.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS Linux 7` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS Stream 8` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS Stream 9` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collections [`community.libvirt`][galaxy-community-libvirt] and [`jm1.libvirt`][
galaxy-jm1-libvirt]. To install these collections you may follow the steps described in [`README.md`][
jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                             | Default value              | Required | Description |
| -------------------------------- | -------------------------- | -------- | ----------- |
| `cloudinit_metadata`             | `{{ omit }}`               | false    | [cloud-init meta data][cloud-init-nocloud] |
| `cloudinit_networkconfig`        | `{{ omit }}`               | false    | [cloud-init network configuration][cloud-init-network-config] |
| `cloudinit_userdata`             | *undefined*                | true     | [cloud-init user data][cloud-init-examples] |
| `libvirt_configdrive`            | `{{ inventory_hostname }}_cidata.{{ libvirt_configdrive_format }}'` | false | Name of the config drive volume. Passed as parameter `name` to module [`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] |
| `libvirt_configdrive_filesystem` | `iso`                      | false    | Filesystem format (vfat or iso) of the config drive volume. Passed as parameter `filesystem` to module [`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] |
| `libvirt_configdrive_format`     | `qcow2`                    | false    | Disk image format of the config drive volume (see [manpage of qemu-img][qemu-img] for allowed image file formats). Passed as parameter `format` to module [`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] |
| `libvirt_configdrive_pool`       | `default`                  | false    | Name or UUID of the storage pool to create the config drive volume in. Passed as parameter `pool` to module [`jm1.libvirt.volume_cloudinit`][jm1-libvirt-volume-cloudinit] |
| `libvirt_domain`                 | `{{ inventory_hostname }}` | false    | Name of the domain |
| `libvirt_domain_autostart`       | `false`                    | false    | Start libvirt domain at startup of the libvirt daemon |
| `libvirt_domain_state`           | `running`                  | false    | [Possible domain states: `[running, paused, pmsuspended, shutoff]`][libvirt-domain-state] |
| `libvirt_hardware`               | `{{ omit }}`               | false    | Hardware specification of the libvirt domain. Accepts all two-dash command line arguments (those with a leading `--`) of `virt-install` as a list. Arguments are formatted as key-value pairs without the leading '--' and having other dashs replaced by underscores. Arguments without a value (flags), e.g. pxe, must be specified with a value of `!!null`. See [manpage of virt-install][virt-install] for available arguments. |
| `libvirt_uri`                    | `qemu:///system`           | false    | [libvirt connection uri][libvirt-uri] |
| `state`                          | `present`                  | false    | Should the libvirt domain be present or absent |

[cloud-init-nocloud]: https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
[libvirt-domain-state]: https://libvirt.org/html/libvirt-libvirt-domain.html#virDomainState
[libvirt-uri]: https://libvirt.org/uri.html
[qemu-img]: https://manpages.debian.org/bullseye/qemu-utils/qemu-img.1.en.html
[virt-install]: https://manpages.debian.org/bullseye/virtinst/virt-install.1.en.html

## Dependencies

None.

## Example Playbook

First, use roles [`jm1.cloudy.libvirt_networks`][jm1-cloudy-libvirt-networks], [`jm1.cloudy.libvirt_pools`][
jm1-cloudy-libvirt-pools], [`jm1.cloudy.libvirt_images`][jm1-cloudy-libvirt-images] and [`jm1.cloudy.libvirt_volumes`][
jm1-cloudy-libvirt-volumes] to create required libvirt networks, pools and block storage volumes as shown in the
introductory example of this role. Define an Ansible host `debian.home.arpa` and its properties like libvirt networks
and block storage volumes as Ansible variables in an inventory as shown in the introductory example.

```yml
- hosts: all
  # do not become root because connection is local
  connection: local # Assign libvirt_uri to setup a connection to the libvirt host
  roles:
  - name: Setup libvirt domain
    role: jm1.cloudy.libvirt_domain
    tags: ["jm1.cloudy.libvirt_domain"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-*` from the provided [examples
inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
