# Ansible Role `jm1.cloudy.cloudinit`

This role helps with changing the [cloud-init][cloud-init-doc] configuration, e.g. files in `/etc/cloud/cloud.cfg.d/`.
Role variable `cloudinit_config` defines a list of tasks which will be run by this role. Each task calls an Ansible 
module similar to tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][
playbooks-keywords] are ignored. For example, to disable cloud-init's network configuration, define variable
`cloudinit_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
cloudinit_config:
- # disable network configuration with cloud-init
  copy:
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
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

None.

## Variables


| Name               | Default value | Required | Description                               |
| ------------------ | ------------- | -------- | ----------------------------------------- |
| `cloudinit_config` | `[]`          | no       | List of tasks to run [^supported-modules] |

[^supported-modules]: Supported Ansible modules are [`blockinfile`][ansible-module-blockinfile], [`copy`][
ansible-module-copy], [`debconf`][ansible-module-debconf], [`file`][ansible-module-file], [`lineinfile`][
ansible-module-lineinfile] and [`template`][ansible-module-template].

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
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
    cloudinit_config:
    - # disable network configuration with cloud-init
      copy:
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
