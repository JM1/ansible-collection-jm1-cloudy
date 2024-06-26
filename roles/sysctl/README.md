# Ansible Role `jm1.cloudy.sysctl`

This role helps with managing kernel parameters from Ansible variables. For example, it allows to change parameters at
runtime with Ansible's [`sysctl`][ansible-builtin-sysctl] module or edit files in `/etc/sysctl.d/` with [`lineinfile`][
ansible-builtin-lineinfile] module. Role variable `sysctl_config` defines a list of tasks which will be run by this role.
Each task calls an Ansible module similar to tasks in roles or playbooks except that only few [keywords][
playbooks-keywords] such as `when` are supported. For example, to enable forwarding of incoming IPv4 packets aka
routing, define variable `sysctl_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
sysctl_config:
- # Enable forwarding of IPv4 packets at runtime
  ansible.posix.sysctl:
    name: net.ipv4.ip_forward
    value: '1'
    state: present
    sysctl_file: /etc/sysctl.d/10-ip-forward.conf
    sysctl_set: true
- # Enable forwarding of IPv4 packets after reboots
  ansible.builtin.copy:
    content: |
      # 2021 Jakob Meng, <jakobmeng@web.de>
      net.ipv4.ip_forward = 1
    dest: /etc/sysctl.d/10-ip-forward.conf
```

When this role is executed, it will run all tasks listed in `sysctl_config` one after another.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables
| Name            | Default value | Required | Description |
| --------------- | ------------- | -------- | ----------- |
| `sysctl_config` | `[]`          | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to update kernel parameters Ansible's [`sysctl`][ansible-builtin-sysctl] module |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keyword `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][ansible-builtin-lineinfile], [`sysctl`][
ansible-posix-sysctl] and [`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-posix-sysctl]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/sysctl_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
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
    sysctl_config:
    - # Enable forwarding of IPv4 packets at runtime
      ansible.posix.sysctl:
        name: net.ipv4.ip_forward
        value: '1'
        state: present
        sysctl_file: /etc/sysctl.d/10-ip-forward.conf
        sysctl_set: true
    - # Enable forwarding of IPv4 packets after reboots
      ansible.builtin.copy:
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
