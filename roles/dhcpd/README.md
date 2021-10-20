# Ansible Role `jm1.cloudy.dhcpd`

This role helps with configuring DHCP IPv4 and DHCP IPv6 services from Ansible variables. It allows to edit e.g. config
files `/etc/dhcp/dhcpd.conf` and `/etc/dhcp/dhcpd6.conf` with variables `dhcpd_config` and `dhcpd6_config` which both
define lists of tasks which will be run by this role. Each task calls an Ansible module similar to tasks in roles or
playbooks except that [task keywords such as `name`, `notify` and `when`][playbooks-keywords] are ignored. For example,
to configure a DHCP IPv4 service define variable `dhcpd_config` in `group_vars` or `host_vars` as such:

```yml
dhcpd_config:
- # Configure /etc/dhcp/dhcpd.conf
  copy:
    dest: /etc/dhcp/dhcpd.conf
    group: root
    mode: u=rw,g=r,o=
    owner: root
    src: "{{ distribution_id|join('-')|regex_replace('[^A-Za-z0-9_.-]', '-') + '/etc/dhcp/dhcpd.conf' }}"
```

First, this role will install a DHCP service which matches the distribution specified in variable `distribution_id`.
Next, it will run all tasks listed in `dhcpd_config` and `dhcpd6_config`. Once all tasks have finished and if anything
has changed (and if `dhcpd_service_state` or `dhcpd6_service_state` are not set to `stopped`), then the DHCP IPv4 and
DHCP IPv6 services are restarted to apply changes.

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

Module `jm1.pkg.meta_pkg` from Collection [`jm1.pkg`][galaxy-jm1-pkg] is used to satisfy all package dependencies of
this Collection [jm1.cloudy][galaxy-jm1-cloudy]. To install `jm1.pkg.meta_pkg` you may follow the steps described in
[`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-cloudy]: https://galaxy.ansible.com/jm1/cloudy
[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                     | Default value                  | Required | Description |
| ------------------------ | ------------------------------ | -------- | ----------- |
| `dhcpd_config`           | *refer to [`roles/dhcpd/defaults/main.yml`](defaults/main.yml)* | no | List of tasks to run [^supported-modules], e.g. to configure `/etc/dhcp/dhcpd.conf` |
| `dhcpd6_config`          | *refer to [`roles/dhcpd/defaults/main.yml`](defaults/main.yml)* | no | List of tasks to run [^supported-modules], e.g. to configure `/etc/dhcp/dhcpd6.conf` |
| `dhcpd_service_enabled`  | `yes`                          | no       | Whether the DHCP IPv4 service should start on boot |
| `dhcpd6_service_enabled` | `yes`                          | no       | Whether the DHCP IPv6 service should start on boot |
| `dhcpd_service_name`     | *depends on `distribution_id`* | no       | Name of the DHCP IPv4 service, e.g. `isc-dhcp-server` on Debian and `dhcpd.service` on Red Hat Enterprise Linux |
| `dhcpd6_service_name`    | *depends on `distribution_id`* | no       | Name of the DHCP IPv6 service, e.g. `isc-dhcp-server6` on Ubuntu and `dhcpd6.service` on Red Hat Enterprise Linux |
| `dhcpd_service_state`    | `started`                      | no       | State of the DHCP IPv4 service |
| `dhcpd6_service_state`   | `started`                      | no       | State of the DHCP IPv6 service |
| `distribution_id`        | *depends on operating system*  | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

[^supported-modules]: Supported Ansible modules are [`blockinfile`][ansible-module-blockinfile], [`copy`][
ansible-module-copy], [`debconf`][ansible-module-debconf], [`file`][ansible-module-file], [`lineinfile`][
ansible-module-lineinfile], [`template`][ansible-module-template] modules.

[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-module-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Manage DHCP IPv4 and DHCP IPv6 services
    role: jm1.cloudy.dhcpd
    tags: ["jm1.cloudy.dhcpd"]
```

For complete examples on how to use this role, refer to hosts `lvrt-lcl-session-srv-10-pxe-server-debian11` or
`lvrt-lcl-session-srv-30-hwfp-server-debian11` from the provided [examples inventory][inventory-example]. The top-level
[`README.md`][jm1-cloudy-readme] describes how these hosts can be provisioned with playbook [`playbooks/site.yml`][
playbook-site-yml].

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
