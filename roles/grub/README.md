# Ansible Role `jm1.cloudy.grub`

This role helps with configuring [GRUB][grub-wiki] from Ansible variables. Role variable `grub_config` defines a list of
tasks which will be run by this role. Each task calls an Ansible module similar to tasks in roles or playbooks except
that [task keywords such as `name`, `notify` and `when`][playbooks-keywords] are ignored. For example, to enable IOMMU
for PCI devices (and remove other parameters), define variable `grub_config` in [`group_vars` or `host_vars`][
ansible-inventory] as such:

```yml
grub_config:
- # Enable IOMMU for PCI devices
  # Ref.: https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
  lineinfile:
    path: /etc/default/grub
    regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
    line: 'GRUB_CMDLINE_LINUX_DEFAULT="iommu=pt intel_iommu=on"'
```

Once all tasks have been run and if anything has changed, then the GRUB configuration will be (re)generated and the
system will be rebooted automatically to apply the changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[grub-wiki]: https://wiki.archlinux.org/title/GRUB
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

| Name              | Default value                  | Required | Description |
| ----------------- | ------------------------------ | -------- | ----------- |
| `distribution_id` | *depends on operating system*  | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `grub_config`     | `[]`                           | no       | List of tasks to run [^supported-modules], e.g. to edit `/etc/default/grub` on Debian |

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

To enable IOMMU for PCI devices:

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
    grub_config:
    - # Enable IOMMU for PCI devices
      # Ref.: https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
      lineinfile:
        path: /etc/default/grub
        regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
        line: 'GRUB_CMDLINE_LINUX_DEFAULT="iommu=pt intel_iommu=on"'
  roles:
  - name: Manage GRUB2 configuration
    role: jm1.cloudy.grub
    tags: ["jm1.cloudy.grub"]
```

To enable [Predictable Network Interface Names][predictable-network-interface-names]:

[predictable-network-interface-names]: https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

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
    grub_config:
    - # Enable Predictable Network Interface Names
      # Ref.: https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/
      lineinfile:
        path: /etc/default/grub
        regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
        line: 'GRUB_CMDLINE_LINUX_DEFAULT="biosdevname=1 net.ifnames=1"'
  roles:
  - name: Manage GRUB2 configuration
    role: jm1.cloudy.grub
    tags: ["jm1.cloudy.grub"]
```

To open consoles on `tty0` and `ttyS0` and enable verbose output which helps with debugging e.g. OpenStack instances:

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
    grub_config:
    - # Open consoles on tty0 and ttyS0 and enable verbose output
      # Inspired by Debian's OpenStack images
      # Ref.: https://cdimage.debian.org/cdimage/openstack/
      lineinfile:
        path: /etc/default/grub
        regexp: '^GRUB_CMDLINE_LINUX_DEFAULT='
        line: >-
          GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0
          systemd.show_status=true"
  roles:
  - name: Manage GRUB2 configuration
    role: jm1.cloudy.grub
    tags: ["jm1.cloudy.grub"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
