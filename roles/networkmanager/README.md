# Ansible Role `jm1.cloudy.networkmanager`

This role helps with managing [NetworkManager][networkmanager] from Ansible variables. Role variable
`networkmanager_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][
playbooks-keywords] are ignored. For example, to assign static ip address `192.168.0.2`, DNS server `192.168.0.1` and
default gateway `192.168.0.1` to network interface `eth0`, define variable `networkmanager_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
networkmanager_config:
- # Assign a static ip address, dns server and default gateway to network interface eth0
  nmcli:
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
system will be rebooted to apply the changes. Ansible module ['nmcli'][ansible-module-nmcli] will not cause a reboot,
because it applies changes immediately.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[jm1-cloudy-packages]: ../packages/
[jm1-cloudy-services]: ../services/
[networkmanager]: https://wiki.gnome.org/Projects/NetworkManager
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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

This role uses module(s) from collection [`community.general`][galaxy-community-general]. To install this collection
you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                    | Default value | Required | Description |
| ----------------------- | ------------- | -------- | ----------- |
| `networkmanager_config` | `[]`          | no       | List of tasks to run [^supported-modules], e.g. to edit files in `/etc/NetworkManager/` |

[^supported-modules]: Supported Ansible modules are [`blockinfile`][ansible-module-blockinfile], [`copy`][
ansible-module-copy], [`debconf`][ansible-module-debconf], [`file`][ansible-module-file], [`lineinfile`][
ansible-module-lineinfile], ['nmcli'][ansible-module-nmcli] and [`template`][ansible-module-template].

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-module-nmcli]: https://docs.ansible.com/ansible/latest/collections/community/general/nmcli_module.html
[ansible-module-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  become: yes
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    networkmanager_config:
    - # Assign a static ip address, dns server and default gateway to network interface eth0
      nmcli:
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
