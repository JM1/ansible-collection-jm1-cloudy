# Ansible Role `jm1.cloudy.networkmanager`

This role helps with managing [NetworkManager][networkmanager] from Ansible variables. Role variable
`networkmanager_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when`
are supported. For example, to assign static ip address `192.168.0.2`, DNS server `192.168.0.1` and default gateway
`192.168.0.1` to network interface `eth0`, define variable `networkmanager_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
networkmanager_config:
- # Assign a static ip address, dns server and default gateway to network interface eth0
  community.general.nmcli:
    conn_name: eth0
    dns4:
    - '192.168.0.1'
    gw4: 192.168.0.1
    ip4:
    - '192.168.0.2/24'
    state: present
    type: ethernet
```

:warning: **WARNING:**
On systems without NetworkManager, a package such as `network-manager` on Debian and Ubuntu has to be installed first.
This role will not install NetworkManager because presumably additional configuration is required such as deactivating
the substituted network configuration mechanism like `ifupdown` on Debian. For example, one may use role
[`jm1.cloudy.packages`][jm1-cloudy-packages] to install NetworkManager and role [`jm1.cloudy.services`][
jm1-cloudy-services] to deactivate other networking services.
:warning:

When this role is executed, it will run all tasks listed in `networkmanager_config`. Once all tasks have finished, the
system will be rebooted to apply the changes. Ansible module ['nmcli'][ansible-builtin-nmcli] will not cause a reboot,
because it applies changes immediately.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[jm1-cloudy-packages]: ../packages/
[jm1-cloudy-services]: ../services/
[networkmanager]: https://wiki.gnome.org/Projects/NetworkManager
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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

This role uses module(s) from collection [`community.general`][galaxy-community-general] and collection [`jm1.ansible`][
galaxy-jm1-ansible]. To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme]
using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                    | Default value | Required | Description |
| ----------------------- | ------------- | -------- | ----------- |
| `networkmanager_config` | `[]`          | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to edit files in `/etc/NetworkManager/` |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `register` and `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`copy`][ansible-builtin-copy], [`debconf`][ansible-builtin-debconf], [`file`][ansible-builtin-file], [`lineinfile`][
ansible-builtin-lineinfile], ['nmcli'][community-general-nmcli] and [`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[community-general-nmcli]: https://docs.ansible.com/ansible/latest/collections/community/general/nmcli_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  become: true
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    networkmanager_config:
    - # Assign a static ip address, dns server and default gateway to network interface eth0
      community.general.nmcli:
        conn_name: eth0
        dns4:
        - '192.168.0.1'
        gw4: 192.168.0.1
        ip4:
        - '192.168.0.2/24'
        state: present
        type: ethernet

  roles:
  - name: Change NetworkManager configuration
    role: jm1.cloudy.networkmanager
    tags: ["jm1.cloudy.networkmanager"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
