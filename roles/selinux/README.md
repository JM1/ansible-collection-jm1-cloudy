# Ansible Role `jm1.cloudy.selinux`

This role helps with managing [SELinux][what-is-selinux] from Ansible variables. For example, it allows to toggle
[SELinux booleans][selinux-booleans] and change the [SELinux policy and state][selinux-howto]. Role variable
`selinux_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when` are
supported. For example, to put SELinux in permissive mode so that actions will be logged instead of being blocked,
define variable `selinux_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

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

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
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
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name             | Default value | Required | Description |
| ---------------- | ------------- | -------- | ----------- |
| `selinux_config` | `[]`          | no       | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to toggle SELinux booleans or change SELinux policy and state |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `register` and `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`seboolean`][ansible-posix-seboolean] and
[`selinux`][ansible-posix-selinux].

[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-posix-seboolean]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/seboolean_module.html
[ansible-posix-selinux]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/selinux_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

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
