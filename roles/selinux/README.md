# Ansible Role `jm1.cloudy.selinux`

This role helps with managing [SELinux][what-is-selinux] from Ansible variables. For example, it allows to toggle
[SELinux booleans][selinux-booleans] and change the [SELinux policy and state][selinux-howto]. Role variable
`selinux_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][playbooks-keywords] are
ignored. For example, to put SELinux in permissive mode so that actions will be logged instead of being blocked, define
variable `selinux_config` in `group_vars` or `host_vars` as such:

```yml
selinux_config:
- # Put SELinux in permissive mode, logging actions that would otherwise be blocked
  selinux:
    policy: targeted
    state: permissive
```

:warning: **WARNING:**
On systems without SELinux such as Debian or Ubuntu, packages for SELinux have to be installed first, e.g. refer to the
SELinux pages on the [Debian Wiki][debian-wiki-selinux] or [Ubuntu Wiki][ubuntu-wiki-selinux]. This role will not
install SELinux because presumably additional configuration is required to configure SELinux on such systems.
:warning:

When this role is executed, it will run all tasks listed in `selinux_config`.

[debian-wiki-selinux]: https://wiki.debian.org/SELinux
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[selinux-booleans]: https://www.redhat.com/sysadmin/selinux-policies-booleans
[selinux-howto]: https://wiki.centos.org/HowTos/SELinux
[ubuntu-wiki-selinux]: https://wiki.ubuntu.com/SELinux
[what-is-selinux]: https://www.redhat.com/en/topics/linux/what-is-selinux

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

| Name             | Default value | Required | Description |
| ---------------- | ------------- | -------- | ----------- |
| `selinux_config` | `[]`          | no       | List of tasks to run [^supported-modules], e.g. to toggle SELinux booleans or change SELinux policy and state |

[^supported-modules]: Supported Ansible modules are [`seboolean`][ansible-module-seboolean] and [`selinux`][
ansible-module-selinux].

[ansible-module-seboolean]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/seboolean_module.html
[ansible-module-selinux]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/selinux_module.html

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
    selinux_config:
    - # Put SELinux in permissive mode, logging actions that would otherwise be blocked
      selinux:
        policy: targeted
        state: permissive
  roles:
  - name: Manage SELinux booleans, policy and state
    role: jm1.cloudy.selinux
    tags: ["jm1.cloudy.selinux"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
