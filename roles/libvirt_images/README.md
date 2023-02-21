# Ansible Role `jm1.cloudy.libvirt_images`

This role helps with managing cloud images in [libvirt storage pools][libvirt] from Ansible variables. For example, it
allows to download and add cloud images of [CentOS][centos-cloud-images], [Debian][debian-cloud-images] and [Ubuntu][
ubuntu-cloud-images] as [libvirt (block storage) volumes][libvirt] to storage pools with variable `libvirt_images`.
This variable is defined as a list where each list item is a dictionary of parameters that will be passed to module
[`jm1.libvirt.volume_import`][jm1-libvirt-volume-import] from collection [`jm1.libvirt`][galaxy-jm1-libvirt]
[^libvirt-images-parameter]. For example, to fetch the latest cloud image of Debian 11 (Bullseye) and add it to the
libvirt storage pool `default` of the local libvirt daemon (run by current Ansible user on the Ansible controller),
define variable `libvirt_images` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
# connect from Ansible controller to local libvirt daemon
ansible_connection: local

libvirt_images:
- # no checksum because image is updated every week
  format: 'qcow2'
  image: https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
  name: debian-11-genericcloud-amd64.qcow2
  pool: 'default'
  state: present

# libvirt connection uri
# Ref.: https://libvirt.org/uri.html
libvirt_uri: 'qemu:///session'
```

Use role [`jm1.cloudy.libvirt_pools`][jm1-cloudy-libvirt-pools] to create the libvirt storage pool `default` as shown by
the example playbook of this role.

Once the previous role has finished, execute this role `jm1.cloudy.libvirt_images`. It will pass each item of the
`libvirt_images` list one after another as parameters to module [`jm1.libvirt.volume_import`][jm1-libvirt-volume-import]
from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-images-parameter]. If a libvirt volume with the same
`name` already exists, it will not be changed.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[centos-cloud-images]: https://cloud.centos.org/centos/
[debian-cloud-images]: https://cdimage.debian.org/images/cloud/
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[jm1-cloudy-libvirt-pools]: ../libvirt_pools/
[jm1-libvirt-volume-import]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/volume_import.py
[libvirt]: https://libvirt.org/
[ubuntu-cloud-images]: https://cloud-images.ubuntu.com/

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
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

| Name             | Default value    | Required | Description |
| ---------------- | ---------------- | -------- | ----------- |
| `libvirt_images` | `[]`             | false    | List of parameter dictionaries for module [`jm1.libvirt.volume_import`][jm1-libvirt-volume-import] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-images-parameter] |
| `libvirt_uri`    | `qemu:///system` | false    | [libvirt connection uri][libvirt-uri] |

[^libvirt-images-parameter]: If a list item does not contain key `uri` then it will be initialized from Ansible
variables `libvirt_uri`.

[libvirt-uri]: https://libvirt.org/uri.html

## Dependencies

None.

## Example Playbook

First, use role [`jm1.cloudy.libvirt_pools`][jm1-cloudy-libvirt-pools] to create a libvirt storage pool with name
`default` as shown in the introduction of that role.

```yml
- hosts: all
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    # connect from Ansible controller to local libvirt daemon
    ansible_connection: local

    libvirt_images:
    - # no checksum because image is updated every week
      format: 'qcow2'
      image: https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
      name: debian-11-genericcloud-amd64.qcow2
      pool: 'default'
      state: present

    # libvirt connection uri
    # Ref.: https://libvirt.org/uri.html
    libvirt_uri: 'qemu:///session'

  roles:
  - name: Setup OS images as libvirt block storage volumes
    role: jm1.cloudy.libvirt_images
    tags: ["jm1.cloudy.libvirt_images"]
```

For a complete example on how to use this role to add cloud images of [CentOS][centos-cloud-images], [Debian][
debian-cloud-images] and [Ubuntu][ubuntu-cloud-images], refer to hosts `lvrt-lcl-session` and `lvrt-lcl-system` as well
as variable `libvirt_images` like defined in `host_vars` and `group_vars/svc_libvirt.yml` from the provided [examples
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
