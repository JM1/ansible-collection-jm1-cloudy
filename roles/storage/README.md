# Ansible Role `jm1.cloudy.storage`

This role helps with managing [partitions][redhat-filesystem], [encrypted (LUKS) devices][redhat-luks], [LVM volume
groups, LVM volumes][redhat-lvm], [filesystems and mountpoints][redhat-filesystem] from Ansible variables. Role variable
`storage_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][playbooks-keywords] are
ignored. For example, to create an ext4 primary partition on device `/dev/sdb`, define variable `storage_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
storage_config:
- # Create ext4 primary partition on device /dev/sdb
  parted:
    device: /dev/sdb
    fs_type: ext4
    number: 1
    state: present
```

When this role is executed, it will run all tasks listed in `storage_config` one after another. When `storage_config`
includes `meta: flush_handlers` and `storage_reboot` evaluates to `yes`, then this role will reboot the system
immediately and continue with remaining tasks in `storage_config` once the host has come up again. Once all tasks have
finished, if anything has changed and `storage_reboot` evaluates to `yes`, then the system will be rebooted
automatically.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[redhat-filesystem]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/managing_file_systems/index
[redhat-luks]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/encrypting-block-devices-using-luks_security-hardening
[redhat-lvm]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/configuring_and_managing_logical_volumes/index

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
| `storage_config` | `[]`          | no       | List of tasks to run [^supported-modules] [^supported-actions] |
| `storage_reboot` | `no`          | no       | Whether the system should be rebooted on `meta: flush_handlers` or after all changes have been applied |

[^supported-modules]: Supported Ansible modules are [`crypttab`][ansible-module-crypttab], [`mount`][
ansible-module-mount], [`luks_device`][ansible-module-luks-device], [`lvg`][ansible-module-lvg], [`lvol`][
ansible-module-lvol] and [`parted`][ansible-module-parted].

[^supported-actions]: Currently, the only supported Ansible action is [`meta: flush_handlers`][ansible-action-meta].

[ansible-action-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-module-crypttab]: https://docs.ansible.com/ansible/latest/collections/community/general/crypttab_module.html
[ansible-module-luks-device]: https://docs.ansible.com/ansible/latest/collections/community/crypto/luks_device_module.html
[ansible-module-lvg]: https://docs.ansible.com/ansible/latest/collections/community/general/lvg_module.html
[ansible-module-lvol]: https://docs.ansible.com/ansible/latest/collections/community/general/lvol_module.html
[ansible-module-mount]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html
[ansible-module-parted]: https://docs.ansible.com/ansible/latest/collections/community/general/parted_module.html

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
    storage_config:
    - # Create ext4 primary partition on device /dev/sdb
      parted:
        device: /dev/sdb
        fs_type: ext4
        number: 1
        state: present

    # reboot system after changes have been applied
    storage_reboot: yes
  roles:
  - name: Manage partitions, encrypted (LUKS) devices, LVM volume groups, LVM volumes, filesystems and mountpoints
    role: jm1.cloudy.storage
    tags: ["jm1.cloudy.storage"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
