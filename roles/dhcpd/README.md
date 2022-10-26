# Ansible Role `jm1.cloudy.dhcpd`

This role helps with configuring DHCP IPv4 and DHCP IPv6 services from Ansible variables. It allows to edit e.g. config
files `/etc/dhcp/dhcpd.conf` and `/etc/dhcp/dhcpd6.conf` with variables `dhcpd_config` and `dhcpd6_config` which both
define lists of tasks which will be run by this role. Each task calls an Ansible module similar to tasks in roles or
playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when` are supported. For example,
to configure a DHCP IPv4 service define variable `dhcpd_config` in [`group_vars` or `host_vars`][ansible-inventory] as
such:

```yml
dhcpd_config:
- # Configure /etc/dhcp/dhcpd.conf
  ansible.builtin.copy:
    dest: /etc/dhcp/dhcpd.conf
    group: root
    mode: u=rw,g=r,o=
    owner: root
    src: "{{ distribution_id | join('-') | regex_replace('[^A-Za-z0-9_.-]', '-') + '/etc/dhcp/dhcpd.conf' }}"
```

First, this role will install a DHCP service which matches the distribution specified in variable `distribution_id`.
Next, it will run all tasks listed in `dhcpd_config` and `dhcpd6_config`. Once all tasks have finished and if anything
has changed (and if `dhcpd_service_state` or `dhcpd6_service_state` are not set to `stopped`), then the DHCP IPv4 and
DHCP IPv6 services are restarted to apply changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible] and collection [`jm1.pkg`][galaxy-jm1-pkg].
To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided
[`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                     | Default value                  | Required | Description |
| ------------------------ | ------------------------------ | -------- | ----------- |
| `dhcpd_config`           | *refer to [`roles/dhcpd/defaults/main.yml`](defaults/main.yml)* | no | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to configure `/etc/dhcp/dhcpd.conf` |
| `dhcpd6_config`          | *refer to [`roles/dhcpd/defaults/main.yml`](defaults/main.yml)* | no | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to configure `/etc/dhcp/dhcpd6.conf` |
| `dhcpd_service_enabled`  | `yes`                          | no       | Whether the DHCP IPv4 service should start on boot |
| `dhcpd6_service_enabled` | `yes`                          | no       | Whether the DHCP IPv6 service should start on boot |
| `dhcpd_service_name`     | *depends on `distribution_id`* | no       | Name of the DHCP IPv4 service, e.g. `isc-dhcp-server` on Debian and `dhcpd.service` on Red Hat Enterprise Linux |
| `dhcpd6_service_name`    | *depends on `distribution_id`* | no       | Name of the DHCP IPv6 service, e.g. `isc-dhcp-server6` on Ubuntu and `dhcpd6.service` on Red Hat Enterprise Linux |
| `dhcpd_service_state`    | `started`                      | no       | State of the DHCP IPv4 service |
| `dhcpd6_service_state`   | `started`                      | no       | State of the DHCP IPv6 service |
| `distribution_id`        | *depends on operating system*  | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

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

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  become: yes
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
