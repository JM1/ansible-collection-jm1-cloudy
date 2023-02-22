# Ansible Role `jm1.cloudy.initrd`

This role helps with editing [initial ramdisk / initramfs images][ramfs-rootfs-initramfs] from Ansible variables. Role
variable `initrd_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `when` are supported.
For example, to [enable DRM (Direct Rendering Manager) kernel mode setting with NVIDIA's proprietary graphics card
driver at the earliest possible occasion][nvidia-drm-kms], define variable `initrd_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
initrd_config:
- ansible.builtin.blockinfile:
    block: |
      # DRM kernel mode setting
      # Ref.: https://wiki.archlinux.org/title/Nvidia#DRM_kernel_mode_setting
      nvidia
      nvidia_modeset
      nvidia_uvm
      nvidia_drm
    path: /etc/initramfs-tools/modules
```

Once all tasks have been run and if anything has changed, then initramfs images will be (re)generated with `initrd_cmd`
and the system will be rebooted automatically to apply the changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[nvidia-drm-kms]: https://wiki.archlinux.org/title/Nvidia#DRM_kernel_mode_setting
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[ramfs-rootfs-initramfs]: https://docs.kernel.org/filesystems/ramfs-rootfs-initramfs.html

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

| Name              | Default value                  | Required | Description |
| ----------------- | ------------------------------ | -------- | ----------- |
| `distribution_id` | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `initrd_cmd`      | *depends on `distribution_id`* | false    | Command to generate initramfs images, e.g. `update-initramfs -u -k all` on Debian and `dracut --regenerate-all --force` on Red Hat Enterprise Linux |
| `initrd_config`   | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to edit `/etc/initramfs-tools/modules` on Debian |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keyword `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][ansible-builtin-lineinfile] and
[`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

## Dependencies

None.

## Example Playbook

To load kernel modules for PCI passthrough of NVIDIA and AMD GPUs to virtual machines ([PCI passthrough via OVMF][
archlinux-pci-passthrough], [GPU passthrough with libvirt qemu kvm][gentoo-gpu-passthrough]):

[archlinux-pci-passthrough]: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
[gentoo-gpu-passthrough]: https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm

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
    initrd_config:
    - ansible.builtin.blockinfile:
        block: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          # Load kernel modules for PCI passthrough
          # Ref.: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
          vfio_pci
          vfio
          vfio_iommu_type1
          vfio_virqfd
        path: /etc/modules
    - ansible.builtin.blockinfile:
        block: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          # Add kernel modules for PCI passthrough to initrd
          # Ref.: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
          vfio_pci
          vfio
          vfio_iommu_type1
          vfio_virqfd
        path: /etc/initramfs-tools/modules
    - ansible.builtin.copy:
        content: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          # VGA PCI IDs to allow PCI passthrough
          # Ref.: https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm
          #
          # 03:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Device [1002:7341]
          # 04:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:1c31] (rev a1)
          # 64:00.0 VGA compatible controller [0300]: ASPEED Technology, Inc. ASPEED Graphics Family [1a03:2000] (rev 41)
          # Ref.: lspci -nn | grep VGA
          options vfio-pci ids=1002:7341,10de:1c31
        dest: /etc/modprobe.d/vfio.conf
  roles:
  - name: Generate initial ramdisk / initramfs images
    role: jm1.cloudy.initrd
    tags: ["jm1.cloudy.initrd"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
