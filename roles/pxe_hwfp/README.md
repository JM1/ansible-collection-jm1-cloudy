# Ansible Role `jm1.cloudy.pxe_hwfp`

This role helps with fingerprinting and reporting the hardware of systems which can be booted via [PXE][pxe-wiki].

Suppose you have a rack with several servers and want to get their specifications, e.g. MAC addresses of NICs and
serial numbers of SSDs and HDDs. Once this role and its dependencies have been run, you power on the first system, wait
for it to boot via PXE, to automatically fingerprint the hardware with the `hwfp` script, to report it to the `hwfp`
service and to finally poweroff the system. Once powered off you power on the next system, wait for it to poweroff and
continue until all systems are done. Then, on the host which executed this role (and runs `hwfp` service), you go to
directory `/var/lib/hwfp` and find all system specifications in sub directories where each sub directory has the specs
of a single system. For example, this includes the output of `dmesg`, `find /dev`, `ipmitool`, `ip addr`, `ip link`,
`lshw`, `lsmod` and `lspci`. Directory names consists of timestamps, indicating when the `hwfp` service received the
specs and indicating to you which system has which specification, e.g. lowest timestamp has specs of first booted system
etc.

:warning: **WARNING:**
Do not expose the `hwfp` service to external networks or the internet. It has no authentication mechanism, transport 
security or security hardening. It is only meant to be run on internal networks.
:warning:

[inventory-example]: ../../inventory/
[pxe-wiki]: https://en.wikipedia.org/wiki/Preboot_Execution_Environment

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/buster/latest/)
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

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                                 | Default value                  | Required | Description |
| ------------------------------------ | ------------------------------ | -------- | ----------- |
| `distribution_id`                    | *depends on operating system*  | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `pxe_hwfp_daemon_host`               | *undefined*                    | yes      | IP address on which the `hwfp` service will listen |
| `pxe_hwfp_daemon_group`              | `nogroup`                      | no       | UNIX group that the `hwfp` service is executed as |
| `pxe_hwfp_daemon_port`               | 8000                           | no       | TCP port on which the `hwfp` service will listen |
| `pxe_hwfp_daemon_user`               | `hwfp`                         | no       | UNIX user that the `hwfp` service is executed as |
| `pxe_hwfp_distribution_filename_map` | `{ x86_64: { UEFI: 'hwfp/amd64/debian-installer/amd64/bootnetx64.efi', BIOS: 'hwfp/amd64/pxelinux.0' } }` | no | Path for use in `filename` parameter of [`dhcpd.conf`][dhcpd-conf-man] so that PXE clients know where to find bootable files on the tftp server |
| `pxe_hwfp_files_amd64`               | `https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/netboot.tar.gz` | no | Where to download Debian's netboot files which will be used to boot BIOS based systems with PXELINUX and UEFI based systems with GRUB2 |
| `pxe_hwfp_kernel_parameters`         | `''`                           | no       | Additional kernel parameters which will be passed to the kernel when booting via PXE to run the `hwfp` script |
| `pxe_hwfp_tftpd_root`                | *depends on `distribution_id`* | no       | Base path which is served by `tftpd`, e.g. `/srv/tftp` on Debian and `/var/lib/tftpboot` on Red Hat Enterprise Linux |
| `pxe_hwfp_virtualenv`                | `/opt/hwfp_venv/`              | no       | Base path where the [Python environment][virtualenv] for and with the `hwfp` service is installed to |

[virtualenv]: https://virtualenv.pypa.io/en/latest/

## Dependencies

| Name               | Description |
| ------------------ | ----------- |
| `jm1.cloudy.dhcpd` | Installs a `dhcpd` service which is required to publish the [`next-server`][dhcpd-conf-man] which PXE clients use to find the tftp server. This role is optional. |
| `jm1.cloudy.tftpd` | Installs a `tftpd` service which is required during PXE network boot to load e.g. the kernel and initrd files and then run the `hwfp` script. This role is optional. |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

[dhcpd-conf-man]: https://manpages.debian.org/bullseye/isc-dhcp-server/dhcpd.conf.5.en.html

## Example Playbook

For a complete example on how to configure `dhcpd`, `tftpd` and `hwfp` services, refer to host
[`lvrt-lcl-session-srv-300-hwfp-server-debian11` from the provided examples inventory][inventory-example]. Additionally,
hosts `lvrt-lcl-session-srv-310-hwfp-client-debian11-bios` and `lvrt-lcl-session-srv-311-hwfp-client-debian11-uefi` can be
booted manually (once provisioned with Ansible) to showcase and debug the whole poweron-fingerprint-report-poweroff
cycle. The top-level [`README.md`][jm1-cloudy-readme] describes how hosts can be provisioned with playbook
[`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
