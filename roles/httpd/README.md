# Ansible Role `jm1.cloudy.httpd`

This role helps with configuring the [Apache HTTP Server][httpd] aka `httpd` from Ansible variables. For example, it
allows to edit config files in `/etc/apache2/` (on Debian) or `/etc/httpd/conf/` (on Red Hat Enterprise Linux). Variable
`httpd_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][playbooks-keywords] are
ignored. For example, to drop Apache's default site on Debian define variable `httpd_config` in `group_vars` or
`host_vars` as such:

```yml
httpd_config:
- file:
    path: /var/www/html
    state: absent
- file:
    path: /etc/apache2/sites-enabled/000-default.conf
    state: absent
```

First, this role will install packages for Apache HTTP Server which match the distribution specified in variable
`distribution_id`. Next, it will run all tasks listed in `httpd_config`. Once all tasks have finished and if anything
has changed (and if `httpd_service_state` is not set to `stopped`), then Apache's service (set in `httpd_service_name`)
is restarted to apply changes.

[httpd]: https://httpd.apache.org/
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
| `httpd_config`           | *refer to [`roles/httpd/defaults/main.yml`](defaults/main.yml)* | no | List of tasks to run [^supported-modules], e.g. to configure files in `/etc/apache2/` or `/etc/httpd/conf/` |
| `httpd_service_enabled`  | `yes`                          | no       | Whether the httpd service should start on boot |
| `httpd_service_name`     | *depends on `distribution_id`* | no       | Name of the httpd service, e.g. `apache2.service` on Debian and `httpd.service` on Red Hat Enterprise Linux |
| `httpd_service_state`    | `started`                      | no       | State of the httpd service |
| `distribution_id`        | *depends on operating system*  | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

[^supported-modules]: Supported Ansible modules are [`apache2_module`][ansible-module-apache2-module], [`blockinfile`][
ansible-module-blockinfile], [`copy`][ansible-module-copy], [`debconf`][ansible-module-debconf], [`file`][
ansible-module-file], [`lineinfile`][ansible-module-lineinfile], [`template`][ansible-module-template] modules.

[ansible-module-apache2-module]: https://docs.ansible.com/ansible/latest/collections/community/general/apache2_module_module.html
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
  - name: Manage httpd service
    role: jm1.cloudy.httpd
    tags: ["jm1.cloudy.httpd"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-10-pxe-server-debian11` from the
provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host
can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

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
