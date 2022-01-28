# Ansible Role `jm1.cloudy.sudoers`

This role helps with managing [sudo][archlinux-wiki-sudo] from Ansible variables. For example, it allows to edit
`/etc/sudoers` and files in `/etc/sudoers.d/`. Role variable `sudoers_config` defines a list of tasks which will be run
by this role. Each task calls an Ansible module similar to tasks in roles or playbooks except that [task keywords such
as `name`, `notify` and `when`][playbooks-keywords] are ignored. For example, to ensure that the Ansible user can gain
full root privileges with `sudo`, define variable `sudoers_config` in [`group_vars` or `host_vars`][ansible-inventory]
as such:

```yml
sudoers_config:
- # Ensure that the Ansible user can gain full root privileges with sudo
  lineinfile:
    create: no # assert that file exist else system is probably not setup using cloud-init
    group: root
    line: '{{ ansible_user }} ALL=(ALL) NOPASSWD:ALL'
    mode: u=r,g=r,o=
    owner: root
    path: /etc/sudoers.d/99-jm1-cloudy-sudoers-example
    state: present
```

When this role is executed, it will run all tasks listed in `sudoers_config` one after another.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[archlinux-wiki-sudo]: https://wiki.archlinux.org/title/Sudo
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

None.

## Variables
| Name             | Default value | Required | Description |
| ---------------- | ------------- | -------- | ----------- |
| `sudoers_config` | `[]`          | no       | List of tasks to run [^supported-modules], e.g. to edit `/etc/sudoers` |

[^supported-modules]: Supported Ansible modules are [`blockinfile`][ansible-module-blockinfile], [`copy`][
ansible-module-copy], [`file`][ansible-module-file], [`lineinfile`][ansible-module-lineinfile] and [`template`][
ansible-module-template].

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
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
    sudoers_config:
    - # Ensure that the Ansible user can gain full root privileges with sudo
      lineinfile:
        create: no # assert that file exist else system is probably not setup using cloud-init
        group: root
        line: '{{ ansible_user }} ALL=(ALL) NOPASSWD:ALL'
        mode: u=r,g=r,o=
        owner: root
        path: /etc/sudoers.d/99-jm1-cloudy-sudoers-example
        state: present
  roles:
  - name: Setup sudoers
    role: jm1.cloudy.sudoers
    tags: ["jm1.cloudy.sudoers"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
