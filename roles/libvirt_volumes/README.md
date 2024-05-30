# Ansible Role `jm1.cloudy.libvirt_volumes`

This role helps with managing [libvirt volumes][libvirt] from Ansible variables. For example, it allows to create volume
snapshots from existing volumes within the same libvirt storage pool with variable `libvirt_volumes`. This variable is
defined as a list where each list item is a dictionary of parameters that will be passed to module
[`jm1.libvirt.volume`][jm1-libvirt-volume] or [`jm1.libvirt.volume_snapshot`][jm1-libvirt-volume-snapshot] from
collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-volumes-parameter]. For example, to create a snapshot of an
existing Debian cloud image `debian-11-genericcloud-amd64.qcow2` in storage pool `default` of the local libvirt daemon
(run by current Ansible user on the Ansible controller), define variable `libvirt_volumes` in [`group_vars` or
`host_vars`][ansible-inventory] as such:

```yml
libvirt_volumes:
- backing_vol: 'debian-11-genericcloud-amd64.qcow2'
  backing_vol_format: 'qcow2'
  capacity: 5G
  format: 'qcow2'
  linked: false
  name: '{{ inventory_hostname }}.qcow2'
  pool: 'default'
  prealloc_metadata: false
  state: present

# libvirt connection uri
# Ref.: https://libvirt.org/uri.html
libvirt_uri: 'qemu:///session'
```

Use role [`jm1.cloudy.libvirt_pools`][jm1-cloudy-libvirt-pools] to create libvirt storage pool `default` as shown in the
introduction of that role.

Use role [`jm1.cloudy.libvirt_images`][jm1-cloudy-libvirt-images] to fetch the cloud image of Debian 11 (Bullseye) and
add it as a volume `debian-11-genericcloud-amd64.qcow2` to storage pool `default` as shown in the introduction of that
role.

Once all previous roles have finished, execute this role `jm1.cloudy.libvirt_volumes`. It will pass each item of the
`libvirt_volumes` list one after another as parameters to module [`jm1.libvirt.volume_snapshot`][
jm1-libvirt-volume-snapshot] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-volumes-parameter]. If a
libvirt volume with the same name already exists, it will not be changed.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[jm1-cloudy-libvirt-images]: ../libvirt_images/
[jm1-cloudy-libvirt-pools]: ../libvirt_pools/
[jm1-libvirt-volume]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/volume.py
[jm1-libvirt-volume-snapshot]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/volume_snapshot.py
[libvirt]: https://libvirt.org/

**Tested OS images**
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/buster/daily/) of Debian 10 (Buster)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bullseye/daily/) of Debian 11 (Bullseye)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bookworm/daily/) of Debian 12 (Bookworm)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/trixie/daily/) of Debian 13 (Trixie)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/7/images/) of CentOS 7 (Core)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/8-stream/x86_64/images/) of CentOS 8 (Stream)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/9-stream/x86_64/images/) of CentOS 9 (Stream)
- [Cloud image (`amd64`)](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/) of Fedora Cloud Base 40
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/bionic/current/) of Ubuntu 18.04 LTS (Bionic Beaver)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/focal/) of Ubuntu 20.04 LTS (Focal Fossa)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/jammy/) of Ubuntu 22.04 LTS (Jammy Jellyfish)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/noble/) of Ubuntu 24.04 LTS (Noble Numbat)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collections [`community.libvirt`][galaxy-community-libvirt] and [`jm1.libvirt`][
galaxy-jm1-libvirt]. To install these collections you may follow the steps described in [`README.md`][
jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name              | Default value    | Required | Description |
| ----------------- | ---------------- | -------- | ----------- |
| `libvirt_volumes` | `[]`             | false    | List of parameter dictionaries for module [`jm1.libvirt.volume`][jm1-libvirt-volume] or [`jm1.libvirt.volume_snapshot`][jm1-libvirt-volume-snapshot] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-volumes-parameter] |
| `libvirt_uri`     | `qemu:///system` | false    | [libvirt connection uri][libvirt-uri] |

[^libvirt-volumes-parameter]: If key `backing_vol` is *NOT* present in a list item, then the item, i.e. its key-value
pairs, is passed to module [`jm1.libvirt.volume`][jm1-libvirt-volume] else it is passed to module
[`jm1.libvirt.volume_snapshot`][jm1-libvirt-volume-snapshot]. If a list item does not contain key `uri` then it will be
initialized from Ansible variables `libvirt_uri`.

[libvirt-uri]: https://libvirt.org/uri.html

## Dependencies

None.

## Example Playbook

Use role [`jm1.cloudy.libvirt_pools`][jm1-cloudy-libvirt-pools] to create a libvirt storage pool with name `default` as
shown in the introduction of that role.

Use role [`jm1.cloudy.libvirt_images`][jm1-cloudy-libvirt-images] to fetch the cloud image of Debian 11 (Bullseye) and
add it as a volume `debian-11-genericcloud-amd64.qcow2` to storage pool `default` as shown in the introduction of that
role.

```yml
- hosts: all
  # do not become root because connection is local
  connection: local # Assign libvirt_uri to setup a connection to the libvirt host
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    libvirt_volumes:
    - backing_vol: 'debian-11-genericcloud-amd64.qcow2'
      backing_vol_format: 'qcow2'
      capacity: 5G
      format: 'qcow2'
      linked: false
      name: '{{ inventory_hostname }}.qcow2'
      pool: 'default'
      prealloc_metadata: false
      state: present

    # libvirt connection uri
    # Ref.: https://libvirt.org/uri.html
    libvirt_uri: 'qemu:///session'

  roles:
  - name: Setup libvirt block storage volumes
    role: jm1.cloudy.libvirt_volumes
    tags: ["jm1.cloudy.libvirt_volumes"]
```

For more examples on how to use this role, refer to variable `libvirt_volumes` as defined in `group_vars/lvrt.yml` and
`host_vars` from the provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme]
describes how the listed hosts can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

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
