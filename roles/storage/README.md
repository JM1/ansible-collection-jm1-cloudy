# Ansible Role `jm1.cloudy.storage`

This role helps with managing [partitions][redhat-filesystem], [encrypted (LUKS) devices][redhat-luks], [LVM volume
groups, LVM volumes][redhat-lvm], [filesystems and mountpoints][redhat-filesystem] from Ansible variables. Role variable
`storage_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `when` are supported. For
example, to create an ext4 primary partition on device `/dev/sdb`, define variable `storage_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
storage_config:
- # Create ext4 primary partition on device /dev/sdb
  community.general.parted:
    device: /dev/sdb
    fs_type: ext4
    number: 1
    state: present
```

When this role is executed, it will run all tasks listed in `storage_config` one after another. When `storage_config`
includes `meta: flush_handlers` and `storage_reboot` evaluates to `true`, then this role will reboot the system
immediately and continue with remaining tasks in `storage_config` once the host has come up again. Once all tasks have
finished, if anything has changed and `storage_reboot` evaluates to `true`, then the system will be rebooted
automatically.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[redhat-filesystem]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/managing_file_systems/index
[redhat-luks]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/encrypting-block-devices-using-luks_security-hardening
[redhat-lvm]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/configuring_and_managing_logical_volumes/index

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS Linux 7` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS Stream 8` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS Stream 9` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
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

| Name             | Default value | Required | Description |
| ---------------- | ------------- | -------- | ----------- |
| `storage_config` | `[]`          | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules] |
| `storage_reboot` | `false`       | false    | Whether the system should be rebooted on `meta: flush_handlers` or after all changes have been applied |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. (Only exception is [`meta: flush_handlers`][
ansible-builtin-meta] which is fully supported). In addition, Ansible does not support free-form parameters for arbitrary
modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keyword `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`crypttab`][community-general-crypttab], [`mount`][
ansible-posix-mount], [`luks_device`][community-crypto-luks-device], [`lvg`][community-general-lvg], [`lvol`][
community-general-lvol] and [`parted`][community-general-parted].

[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-posix-mount]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/mount_module.html
[community-crypto-luks-device]: https://docs.ansible.com/ansible/latest/collections/community/crypto/luks_device_module.html
[community-general-crypttab]: https://docs.ansible.com/ansible/latest/collections/community/general/crypttab_module.html
[community-general-lvg]: https://docs.ansible.com/ansible/latest/collections/community/general/lvg_module.html
[community-general-lvol]: https://docs.ansible.com/ansible/latest/collections/community/general/lvol_module.html
[community-general-parted]: https://docs.ansible.com/ansible/latest/collections/community/general/parted_module.html
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
    storage_config:
    - # Create ext4 primary partition on device /dev/sdb
      community.general.parted:
        device: /dev/sdb
        fs_type: ext4
        number: 1
        state: present

    # reboot system after changes have been applied
    storage_reboot: true
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
