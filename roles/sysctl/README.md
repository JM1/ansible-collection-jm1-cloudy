# Ansible Role `jm1.cloudy.sysctl`

This role helps with managing kernel parameters from Ansible variables. For example, it allows to change parameters at
runtime with Ansible's [`sysctl`][ansible-module-sysctl] module or edit files in `/etc/sysctl.d/` with [`lineinfile`][
ansible-module-lineinfile] module. Role variable `sysctl_config` defines a list of tasks which will be run by this role.
Each task calls an Ansible module similar to tasks in roles or playbooks except that [task keywords such as `name`,
`notify` and `when`][playbooks-keywords] are ignored. For example, to enable forwarding of incoming IPv4 packets aka
routing, define variable `sysctl_config` in `group_vars` or `host_vars` as such:

```yml
sysctl_config:
- # Enable forwarding of IPv4 packets at runtime
  sysctl:
    name: net.ipv4.ip_forward
    value: '1'
    state: present
    sysctl_file: /etc/sysctl.d/10-ip-forward.conf
    sysctl_set: yes
- # Enable forwarding of IPv4 packets after reboots
  copy:
    content: |
      # 2021 Jakob Meng, <jakobmeng@web.de>
      net.ipv4.ip_forward = 1
    dest: /etc/sysctl.d/10-ip-forward.conf
```

When this role is executed, it will run all tasks listed in `sysctl_config` one after another.

[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

None.

## Variables
| Name            | Default value | Required | Description |
| --------------- | ------------- | -------- | ----------- |
| `sysctl_config` | `[]`          | no       | List of tasks to run [^supported-modules], e.g. to update kernel parameters Ansible's [`sysctl`][ansible-module-sysctl] module |

[^supported-modules]: Supported Ansible modules are [`blockinfile`][ansible-module-blockinfile], [`copy`][
ansible-module-copy], [`file`][ansible-module-file], [`lineinfile`][ansible-module-lineinfile], [`sysctl`][
ansible-module-sysctl] and [`template`][ansible-module-template].

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-module-sysctl]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/sysctl_module.html
[ansible-module-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html

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
    sysctl_config:
    - # Enable forwarding of IPv4 packets at runtime
      sysctl:
        name: net.ipv4.ip_forward
        value: '1'
        state: present
        sysctl_file: /etc/sysctl.d/10-ip-forward.conf
        sysctl_set: yes
    - # Enable forwarding of IPv4 packets after reboots
      copy:
        content: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          net.ipv4.ip_forward = 1
        dest: /etc/sysctl.d/10-ip-forward.conf
  roles:
  - name: Manage kernel parameters
    role: jm1.cloudy.sysctl
    tags: ["jm1.cloudy.sysctl"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
