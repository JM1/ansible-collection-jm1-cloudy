# Ansible Role `jm1.cloudy.services`

This role helps with managing services from Ansible variables. For example, it allows to start, stop, enable and disable
[systemd units][archlinux-wiki-systemd] and [SysV services][gentoo-wiki-sysvinit]. Role variable `services_config`
defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to tasks in roles or
playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when` are supported. For example,
to stop and disable [Samba][samba]'s [smbd][smbd] service, define variable `services_config` in [`group_vars` or
`host_vars`][ansible-inventory] as such:

```yml
services_config:
- # Stop and disable Samba's smbd service
  service:
    enabled: no
    name: smbd
    state: stopped
```

When this role is executed, it will run all tasks listed in `services_config`.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[archlinux-wiki-systemd]: https://wiki.archlinux.org/title/Systemd
[gentoo-wiki-sysvinit]: https://wiki.gentoo.org/wiki/Sysvinit
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[samba]: https://www.samba.org/samba/
[smbd]: https://www.samba.org/samba/docs/current/man-html/smbd.8.html

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

| Name              | Default value | Required | Description |
| ----------------- | ------------- | -------- | ----------- |
| `services_config` | `[]`          | no       | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to start or stop services |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `register` and `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`service`][ansible-builtin-service], [`systemd`][
ansible-builtin-systemd] and [`sysvinit`][ansible-builtin-sysvinit].

[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-service]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html
[ansible-builtin-systemd]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html
[ansible-builtin-sysvinit]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/sysvinit_module.html
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
    services_config:
    - # Stop and disable Samba's smbd service
      service:
        enabled: no
        name: smbd
        state: stopped
  roles:
  - name: Manage services, e.g. systemd units and SysV services
    role: jm1.cloudy.services
    tags: ["jm1.cloudy.services"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
