# Ansible Role `jm1.cloudy.initrd`

This role helps with editing [initial ramdisk / initramfs images][ramfs-rootfs-initramfs] from Ansible variables. Role
variable `initrd_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][
playbooks-keywords] are ignored. For example, to [enable DRM (Direct Rendering Manager) kernel mode setting with
NVIDIA's proprietary graphics card driver at the earliest possible occasion][nvidia-drm-kms], define variable
`initrd_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
initrd_config:
- blockinfile:
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
| `initrd_cmd`      | *depends on `distribution_id`* | no       | Command to generate initramfs images, e.g. `update-initramfs -u -k all` on Debian and `dracut --regenerate-all --force` on Red Hat Enterprise Linux |
| `initrd_config`   | `[]`                           | no       | List of tasks to run [^supported-modules], e.g. to edit `/etc/initramfs-tools/modules` on Debian |

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

To load kernel modules for PCI passthrough of NVIDIA and AMD GPUs to virtual machines ([PCI passthrough via OVMF][
archlinux-pci-passthrough], [GPU passthrough with libvirt qemu kvm][gentoo-gpu-passthrough]):

[archlinux-pci-passthrough]: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
[gentoo-gpu-passthrough]: https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm

```yml
- hosts: all
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    initrd_config:
    - blockinfile:
        block: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          # Load kernel modules for PCI passthrough
          # Ref.: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
          vfio_pci
          vfio
          vfio_iommu_type1
          vfio_virqfd
        path: /etc/modules
    - blockinfile:
        block: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          # Add kernel modules for PCI passthrough to initrd
          # Ref.: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
          vfio_pci
          vfio
          vfio_iommu_type1
          vfio_virqfd
        path: /etc/initramfs-tools/modules
    - copy:
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
