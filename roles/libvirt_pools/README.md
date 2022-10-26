# Ansible Role `jm1.cloudy.libvirt_pools`

This role helps with managing [libvirt storage pools][libvirt] from Ansible variables. For example, it allows to create
and delete storage pools with variable `libvirt_images`. This variable is defined as a list where each list item is a
dictionary of parameters that will be passed to module [`jm1.libvirt.pool`][jm1-libvirt-pool] or
[`jm1.libvirt.pool_xml`][jm1-libvirt-pool-xml] from collection [`jm1.libvirt`][galaxy-jm1-libvirt]
[^libvirt-pools-parameter]. For example, to create libvirt storage pool `default` with the local libvirt daemon (run by
current Ansible user on the Ansible controller), define variable `libvirt_pools` in [`group_vars` or `host_vars`][
ansible-inventory] as such:

```yml
# connect from Ansible controller to local libvirt daemon
ansible_connection: local

libvirt_pools:
- autostart: yes
  hardware:
  - type: dir
  - target: '{{ ansible_env.HOME }}/.local/share/libvirt/images'
  name: 'default'

# libvirt connection uri
# Ref.: https://libvirt.org/uri.html
libvirt_uri: 'qemu:///session'
```

When this role is executed, it will pass each item of the `libvirt_pools` list one after another as parameters to module
[`jm1.libvirt.pool`][jm1-libvirt-pool] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-pools-parameter].
If a libvirt storage pool with the same name already exists, it will be updated if necessary. If a list item does not
contain key `autostart` or if its set to `yes` then module [`community.libvirt.virt_pool`][community-libvirt-virt-pool]
from collection [`community.libvirt`][galaxy-community-libvirt] will be used to mark that storage pool to be started
automatically when the libvirt daemon starts. At the end the same module will be used to stop and restart storage pools
automatically to apply pending changes at runtime.

If any list item in `libvirt_pools` has its key `state` set to `absent` then module [`community.libvirt.virt_pool`][
community-libvirt-virt-pool] will be used to stop (destroy) and delete (undefine) this storage pool.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[community-libvirt-virt-pool]: https://docs.ansible.com/ansible/latest/collections/community/libvirt/virt_pool_module.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[jm1-libvirt-pool]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/pool.py
[jm1-libvirt-pool-xml]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/pool_xml.py
[libvirt]: https://libvirt.org/

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collections [`community.libvirt`][galaxy-community-libvirt] and [`jm1.libvirt`][
galaxy-jm1-libvirt]. To install these collections you may follow the steps described in [`README.md`][
jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name            | Default value    | Required | Description |
| --------------- | ---------------- | -------- | ----------- |
| `libvirt_pools` | `[]`             | no       | List of parameter dictionaries for module [`jm1.libvirt.pool`][jm1-libvirt-pool] or [`jm1.libvirt.pool_xml`][jm1-libvirt-pool-xml] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-pools-parameter] |
| `libvirt_uri`   | `qemu:///system` | no       | [libvirt connection uri][libvirt-uri] |

[^libvirt-pools-parameter]: If keys `xml`, `xml_file` or `xml_var` are *NOT* present in a list item, then the item, i.e.
its key-value pairs, is passed to module [`jm1.libvirt.pool`][jm1-libvirt-pool] else it is passed to module
[`jm1.libvirt.pool_xml`][jm1-libvirt-pool-xml]. If key `xml` is present in a list item, then it will be passed unchanged
to `jm1.libvirt.pool_xml`. If `xml` is not present but `xml_file` is present in a list item, then the file path stored
in `xml_file` will be read with [Ansible's `lookup('template', item.xml_file)` plugin][template-lookup] and passed as
parameter `xml` to module `jm1.libvirt.pool_xml`. If both `xml` and `xml_var` are not present in a list item but key
`xml_var` is, then the variable named by `xml_var` will be read with [Ansible's `lookup('vars', item.xml_var)` plugin][
vars-lookup] and passed as parameter `xml` to module `jm1.libvirt.pool_xml`. If a list item does not contain key `uri`
then it will be initialized from Ansible variables `libvirt_uri`.

[libvirt-uri]: https://libvirt.org/uri.html
[template-lookup]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_lookup.html
[vars-lookup]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/vars_lookup.html

## Dependencies

None.

## Example Playbook

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

    libvirt_pools:
    - autostart: yes
      hardware:
      - type: dir
      - target: '{{ ansible_env.HOME }}/.local/share/libvirt/images'
      name: 'default'

    # libvirt connection uri
    # Ref.: https://libvirt.org/uri.html
    libvirt_uri: 'qemu:///session'

  roles:
  - name: Setup libvirt storage pools
    role: jm1.cloudy.libvirt_pools
    tags: ["jm1.cloudy.libvirt_pools"]
```

For more examples on how to use this role, refer to hosts `lvrt-lcl-session`, `lvrt-lcl-system` and variable
`libvirt_pools` as defined in `group_vars/svc_libvirt.yml` from the provided [examples inventory][inventory-example].
The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be provisioned with playbook
[`playbooks/site.yml`][playbook-site-yml].

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
