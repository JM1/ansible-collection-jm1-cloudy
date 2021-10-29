# Ansible Role `jm1.cloudy.pxe_installer`

This role helps with preparing a [PXE][pxe-wiki] server which allows to boot PXE clients from network and install an
operating system such as [CentOS][centos-pxe], [Debian][debian-pxe] and [Ubu][ubuntu-pxe-1][ntu][ubuntu-pxe-2]
automatically. Both BIOS based systems and UEFI based systems are supported, [PXELINUX][pxelinux] will be used on the
former, [GRUB2][grub] on the latter.

Operating systems currently supported are:
* CentOS 7/8 with [Kickstart][kickstart]
* Debian 10/11 with [Preseed][preseed]
* Ubuntu 18.04/20.04 with [Autoinstall][autoinstall]

It is possible to provide client-specific Kickstart, Preseed and Autoinstall (e.g. [cloud-init][cloud-init-doc] user
data) files to customize the installation process per host.

[autoinstall]: https://ubuntu.com/server/docs/install/autoinstall-quickstart
[centos-pxe]: https://docs.centos.org/en-US/centos/install-guide/pxe-server/
[cloud-init-doc]: https://cloudinit.readthedocs.io/
[debian-pxe]: https://wiki.debian.org/PXEBootInstall
[grub]: https://www.gnu.org/software/grub/manual/grub/html_node/Network.html
[kickstart]: https://docs.centos.org/en-US/centos/install-guide/Kickstart2/
[preseed]: https://wiki.debian.org/DebianInstaller/Preseed
[pxelinux]: https://wiki.syslinux.org/wiki/index.php?title=PXELINUX
[pxe-wiki]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
[ubuntu-pxe-1]: https://ubuntu.com/server/docs/install/netboot-arm64
[ubuntu-pxe-2]: https://ubuntu.com/server/docs/install/netboot-amd64

For a complete example, take a look at host `lvrt-lcl-session-srv-10-pxe-server-debian11` from the provided [examples
inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how it can be provisioned with
playbook [`playbooks/site.yml`][playbook-site-yml]:

First, role [`jm1.cloudy.dhcpd`][jm1-cloudy-dhcpd] installs a `dhcpd` service which will grant IP addresses and publish
the [`next-server`][dhcpd-conf-man] which PXE clients will use to find the tftp server. Role [`jm1.cloudy.httpd`][
jm1-cloudy-httpd] installs an Apache HTTP Server which will provide Kickstart and Preseed configs, cloud-init user data
and installation sources with package repositories during network installation. Role [`jm1.cloudy.tftpd`][
jm1-cloudy-tftpd] will install a `tftpd` service which PXE clients will use during PXE network boot to load e.g. the
kernel and initrd files.

Once `dhcpd`, `httpd` and `tftpd` services have been configured, playbook [`playbooks/site.yml`][playbook-site-yml] will
execute this role `jm1.cloudy.pxe_installer`. In short, it will populate the `pxe_installer_tftpd_root` directory with
PXELINUX, GRUB2 UEFI binaries and client-specific Preseed configs. It will also equip the `pxe_installer_httpd_root`
directory with rpm package repositories, client-specific Kickstart configs and cloud-init user data.

First, this role will install required tools like `cpio` and `7z` which will be used e.g. for archive extraction.

Then, this role will prepare CentOS installations. It will fetch and extract the CentOS isos to subdirectories in
`{{ pxe_installer_httpd_root }}/archive/`. The download will take some time because CentOS full isos are required as
smaller isos do not have the required rpm's. After extraction it will decompress the rpm's of shim and GRUB2 to
subdirectories in `pxe_installer_tftpd_root`. GRUB2 UEFI binaries (`grubx64.efi`) have to be patched so that GRUB2
finds its boot files in the `tftpd` subdirectory. The syslinux-tftpboot rpm from the isos will be decompressed to obtain
PXELINUX files for booting on BIOS-based systems. After kernels and initrds have been copied from the extracted isos,
the host-specific PXELINUX and GRUB2 configs will be generated: For each Ansible host listed in `pxe_installer_clients`,
its `distribution_id` variable will be queried to identify CentOS hosts, `pxe_installer_client_mac` will be used to
write host-specific PXELINUX and GRUB2 configs and with variable `pxe_installer_kernel_parameters` additional kernel
parameters will be added. Last, host-specific Kickstart files will be generated in
`{{ pxe_installer_httpd_root }}/kickstarts/` for all hosts listed in `pxe_installer_clients`, using the host-specific
`kickstart_config` variable.

Next, this role will prepare Debian installations. It will fetch and extract Debian netboot archives to subdirectories
in `pxe_installer_tftpd_root`. They contain all required files like kernel, initrd, PXELINUX and GRUB2 UEFI binaries.
The latter (`grubx64.efi`) have to be patched so that GRUB2 finds its boot files in Debian's `tftpd` subdirectory. After
decompression the host-specific PXELINUX and GRUB2 configs will be generated: For each Ansible host listed in
`pxe_installer_clients`, its `distribution_id` variable will be queried to identify Debian hosts,
`pxe_installer_client_mac` will be used to write host-specific configs and additional kernel parameters will be added
from variable `pxe_installer_kernel_parameters`. Last, host-specific Preseed files will be generated in subdirectories
of `pxe_installer_tftpd_root` for all hosts listed in `pxe_installer_clients`, using the host-specific `preseed_config`
variable.

Finally, this role will prepare Ubuntu installations. It will fetch and extract Ubuntu's live server isos and netboot
archives to subdirectories in `pxe_installer_tftpd_root`. Ubuntu's netbootable GRUB2 UEFI binaries will to be downloaded
to the same subdirectory and then patched so that GRUB2 finds its boot files in that directory. Next, the host-specific
PXELINUX and GRUB2 configs will be generated: For each Ansible host listed in `pxe_installer_clients`, its
`distribution_id` variable will be queried to identify Ubuntu hosts, `pxe_installer_client_mac` will be used to write
host-specific GRUB2 and PXELINUX configs and additional kernel parameters will be added from variable
`pxe_installer_kernel_parameters`. Last, host-specific cloud-init user data etc. will be generated in subdirectories
of `{{ pxe_installer_httpd_root }}/cloud-init/` for all hosts listed in `pxe_installer_clients`, using the host-specific
`cloudinit_userdata`, `cloudinit_metadata` and `cloudinit_vendordata` variables.

For examples on how to configure PXE clients as Ansible hosts and how to define variables `kickstart_config`,
`preseed_config` or `cloudinit_userdata`, refer to hosts `lvrt-lcl-session-srv-11-pxe-client-debian11-bios` up to
`lvrt-lcl-session-srv-17-pxe-client-centos8-uefi` in the provided [examples inventory][inventory-example]. The top-level
[`README.md`][jm1-cloudy-readme] describes how hosts can be provisioned with playbook [`playbooks/site.yml`][
playbook-site-yml]. During playbook execution, these hosts will boot from network, fetch the kernel, initrd and more
from host `lvrt-lcl-session-srv-10-pxe-server-debian11`, continue with installing operating systems automatically and
finally will be provisioned with Ansible.

[jm1-cloudy-dhcpd]: ../dhcpd/
[jm1-cloudy-httpd]: ../httpd/
[jm1-cloudy-tftpd]: ../tftpd/

**Tested OS images**
- Network boot image of [`Debian 10 (Buster)` \[`amd64`\]](
    https://deb.debian.org/debian/dists/buster/main/installer-amd64/current/images/netboot/)
- Network boot image of [`Debian 11 (Bullseye)` \[`amd64`\]](
    https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/)
- ISO image of [`CentOS 7 (Core)` \[`amd64`\]](http://isoredirect.centos.org/centos/7/isos/x86_64/)
- ISO image of [`CentOS 8 (Core)` \[`amd64`\]](http://isoredirect.centos.org/centos/8/isos/x86_64/)
- Ubuntu Server install image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://releases.ubuntu.com/bionic/)
- Ubuntu Server install image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://releases.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module `jm1.pkg.meta_pkg` from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may
follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                                                | Default value                                        | Required | Description |
| --------------------------------------------------- | ---------------------------------------------------- | -------- | ----------- |
| `distribution_id`                                   | *depends on operating system*                        | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `pxe_installer_clients`                             | *undefined*                                          | yes      | List of Ansible hosts which are going to be installed [^clients-parameter] [^clients-parameter-extra] |
| `pxe_installer_cloudinit_url`                       | `http://{{ pxe_installer_host_address\|mandatory }}` | no       | Base url where Ubuntu's Subiquity installer will fetch the autoinstall config |
| `pxe_installer_distribution_filename_map`           | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Path for use in `filename` parameter of [`dhcpd.conf`][dhcpd-conf-man] so that PXE clients know where to find bootable files on the tftp server |
| `pxe_installer_files_centos_7_amd64`                | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download CentOS's iso which will be used to pxe-boot and kickstart `CentOS 7 [amd64]`. A CentOS full iso is required because its rpm's will be extracted. |
| `pxe_installer_files_centos_8_amd64`                | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download CentOS's iso which will be used to pxe-boot and kickstart `CentOS 8 [amd64]`. A CentOS full iso is required because its rpm's will be extracted. |
| `pxe_installer_files_debian_10_amd64`               | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download Debian's netboot files which will be used to pxe-boot and preseed `Debian 10 (Buster) [amd64]` |
| `pxe_installer_files_debian_11_amd64`               | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download Debian's netboot files which will be used to pxe-boot and preseed `Debian 11 (Bullseye) [amd64]` |
| `pxe_installer_files_ubuntu_1804_amd64`             | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download Ubuntu's netbootable GRUB2 UEFI executable, its live server iso and netboot files which will be used to pxe-boot and autoinstall `Ubuntu 18.04 LTS (Bionic Beaver) [amd64]` [^iso-parameter] |
| `pxe_installer_files_ubuntu_2004_amd64`             | *refer to [`roles/pxe_installer/defaults/main.yml`](defaults/main.yml)* | no | Where to download Ubuntu's netbootable GRUB2 UEFI executable, its live server iso and netboot files which will be used to pxe-boot and autoinstall `Ubuntu 20.04 LTS (Focal Fossa) [amd64]` [^iso-parameter] |
| `pxe_installer_host_address`                        | *undefined*                                          | yes      | IP address on which the `httpd` and `tftpd` services will listen. It is sourced from `pxe_installer_*_url` variables. |
| `pxe_installer_httpd_root`                          | *depends on `distribution_id`*                       | no       | Base path which is served by a `httpd` site [^root-parameter], e.g. `/var/www` on Debian and `/var/lib/httpd` on Red Hat Enterprise Linux |
| `pxe_installer_kernel_parameters`                   | `''`                                                 | no       | Convenience variable which is sourced from `pxe_installer_kernel_parameters_*` variables to set additional kernel parameters for all distributions and architectures |
| `pxe_installer_kernel_parameters_centos_7_amd64`    | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to kickstart `CentOS 7 [amd64]` |
| `pxe_installer_kernel_parameters_centos_8_amd64`    | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to kickstart `CentOS 8 [amd64]` |
| `pxe_installer_kernel_parameters_debian_10_amd64`   | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to preseed `Debian 10 (Buster) [amd64]` |
| `pxe_installer_kernel_parameters_debian_11_amd64`   | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to preseed `Debian 11 (Bullseye) [amd64]` |
| `pxe_installer_kernel_parameters_ubuntu_1804_amd64` | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to autoinstall `Ubuntu 18.04 LTS (Bionic Beaver) [amd64]` |
| `pxe_installer_kernel_parameters_ubuntu_2004_amd64` | `{{ pxe_installer_kernel_parameters }}`              | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to autoinstall `Ubuntu 20.04 LTS (Focal Fossa) [amd64]` |
| `pxe_installer_kickstart_url`                       | `http://{{ pxe_installer_host_address\|mandatory }}` | no       | Base url where CentOS's Anaconda installer will fetch the Kickstart config |
| `pxe_installer_preseed_url`                         | `tftp://{{ pxe_installer_host_address\|mandatory }}` | no       | Base url where Debian's Installer will fetch Preseed config |
| `pxe_installer_rpm_archive_url`                     | `http://{{ pxe_installer_host_address\|mandatory }}` | no       | Base url to installation source providing package repositories for CentOS's Anaconda installer |
| `pxe_installer_tftpd_root`                          | *depends on `distribution_id`*                       | no       | Base path which is served by `tftpd` [^root-parameter], e.g. `/srv/tftp` on Debian and `/var/lib/tftpboot` on Red Hat Enterprise Linux |

[^clients-parameter]: Ansible hosts in `pxe_installer_clients` have to define variables `distribution_id`,
`os_architecture`, `pxe_installer_client_mac` and might define variable `pxe_installer_kernel_parameters` e.g. in
`host_vars` or `group_vars`.  Variable `distribution_id` defines a list which identifies the distribution release that
is going to be installed, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)`. Variable `os_architecture` defines the
architecture of that distribution, currently only `x86_64` is supported. Variable `pxe_installer_client_mac` defines the
primary MAC address which a PXE client uses to query its PXELINUX or GRUB2 config. This role will create a specific
PXELINUX and GRUB2 config for each PXE client and uses `pxe_installer_client_mac` to distinguish clients. Variable
`pxe_installer_kernel_parameters` defines additional kernel parameters which will be passed to the kernel when booting
via PXE. If `pxe_installer_kernel_parameters` is not specified for client, then variable
`pxe_installer_kernel_parameters_*` matching `distribution_id` and `os_architecture` of that client will be used.
For examples refer to hosts `lvrt-lcl-session-srv-11-pxe-client-debian11-bios` up to
`lvrt-lcl-session-srv-17-pxe-client-centos8-uefi` from the provided [examples inventory][inventory-example].

[^clients-parameter-extra]: Depending on the distribution release (`distribution_id`) which should be installed, Ansible
hosts in `pxe_installer_clients` have to define one of the following variables `kickstart_config`, `preseed_config` or
`cloudinit_userdata` (and `cloudinit_metadata` and `cloudinit_vendordata` optionally) in e.g. `host_vars` or
`group_vars`. For examples refer to hosts `lvrt-lcl-session-srv-11-pxe-client-debian11-bios` up to
`lvrt-lcl-session-srv-17-pxe-client-centos8-uefi` from the provided [examples inventory][inventory-example].

[^iso-parameter]: After changing iso urls make sure to delete and rebuild the whole directory tree below
`pxe_installer_httpd_root` and `pxe_installer_tftpd_root` because initrd's must match.

[^root-parameter]: This role will not set up the http server nor the tftp server. It will merely create a directory
hierarchies within the `httpd` and `tftpd` directories as specified with `pxe_installer_httpd_root` and
`pxe_installer_tftpd_root`.

## Dependencies

| Name               | Description |
| ------------------ | ----------- |
| `jm1.cloudy.dhcpd` | Installs a `dhcpd` service which is required to publish the [`next-server`][dhcpd-conf-man] which PXE clients use to find the tftp server. This role is optional. |
| `jm1.cloudy.httpd` | Installs a `httpd` service which is required during network installation to provide Kickstart and Preseed configs, cloud-init user data and installation sources with package repositories. This role is optional. |
| `jm1.cloudy.tftpd` | Installs a `tftpd` service which is required during PXE network boot to load e.g. the kernel and initrd files. This role is optional. |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

[dhcpd-conf-man]: https://manpages.debian.org/bullseye/isc-dhcp-server/dhcpd.conf.5.en.html

## Example Playbook

Define an Ansible host which acts as a [PXE][pxe-wiki] server. Use roles [`jm1.cloudy.dhcpd`][jm1-cloudy-dhcpd],
[`jm1.cloudy.httpd`][jm1-cloudy-httpd] and [`jm1.cloudy.tftpd`][jm1-cloudy-tftpd] to install and configure `dhcpd`,
`httpd` and `tftpd` services.

```yml
- hosts: all
  become: yes
  roles:
  - name: Prepare server installation using PXE network boot
    role: jm1.cloudy.pxe_installer
    tags: ["jm1.cloudy.pxe_installer"]
```

For a complete example on how to configure `dhcpd`, `httpd` and `tftpd` services and how to use this role, refer to host
`lvrt-lcl-session-srv-10-pxe-server-debian11` from the provided [examples inventory][inventory-example]. Additionally,
hosts `lvrt-lcl-session-srv-11-pxe-client-debian11-bios` up to `lvrt-lcl-session-srv-17-pxe-client-centos8-uefi` show
how to boot BIOS and UEFI systems from network via [PXE][pxe-wiki] and install operating systems automatically, i.e.
CentOS 8 with Kickstart, Debian 11 with Preseed and Ubuntu 20.04 with Autoinstall. The top-level [`README.md`][
jm1-cloudy-readme] describes how hosts can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/inventory/
[playbook-site-yml]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/playbooks/site.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
