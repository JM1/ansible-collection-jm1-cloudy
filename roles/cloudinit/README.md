# Ansible Role `jm1.cloudy.cloudinit`

This role helps with changing the [cloud-init][cloud-init-doc] configuration, e.g. files in `/etc/cloud/cloud.cfg.d/`.
Role variable `cloudinit_config` defines a list of tasks which will be run by this role. Each task calls an Ansible
module similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and
`when` are supported. For example, to disable cloud-init's network configuration, define variable `cloudinit_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
cloudinit_config:
- # disable network configuration with cloud-init
  ansible.builtin.copy:
    content: |
      # 2021 Jakob Meng, <jakobmeng@web.de>
      network: {config: disabled}
    dest: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    owner: root
    group: root
    mode: u=rw,g=r,o=r
```

Once all tasks have been run and if anything has changed, then the system will automatically be rebooted to apply the
cloud-init configuration.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[cloud-init-doc]: https://cloudinit.readthedocs.io/
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

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name               | Default value | Required | Description |
| ------------------ | ------------- | -------- | ----------- |
| `cloudinit_config` | `[]`          | no       | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules] |

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
ansible-builtin-lineinfile] and [`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
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
    cloudinit_config:
    - # disable network configuration with cloud-init
      ansible.builtin.copy:
        content: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          network: {config: disabled}
        dest: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
        owner: root
        group: root
        mode: u=rw,g=r,o=r
  roles:
  - name: Change cloud-init configuration
    role: jm1.cloudy.cloudinit
    tags: ["jm1.cloudy.cloudinit"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
