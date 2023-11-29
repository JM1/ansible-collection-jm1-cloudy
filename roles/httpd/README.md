# Ansible Role `jm1.cloudy.httpd`

This role helps with configuring the [Apache HTTP Server][httpd] aka `httpd` from Ansible variables. For example, it
allows to edit config files in `/etc/apache2/` (on Debian) or `/etc/httpd/conf/` (on Red Hat Enterprise Linux). Variable
`httpd_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `when` are supported. For
example, to drop Apache's default site on Debian define variable `httpd_config` in [`group_vars` or `host_vars`][
ansible-inventory] as such:

```yml
httpd_config:
- ansible.builtin.file:
    path: /var/www/html
    state: absent
- ansible.builtin.file:
    path: /etc/apache2/sites-enabled/000-default.conf
    state: absent
```

First, this role will install packages for Apache HTTP Server which match the distribution specified in variable
`distribution_id`. Next, it will run all tasks listed in `httpd_config`. Once all tasks have finished and if anything
has changed (and if `httpd_service_state` is not set to `stopped`), then Apache's service (set in `httpd_service_name`)
is restarted to apply changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[httpd]: https://httpd.apache.org/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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
| `httpd_config`           | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to configure files in `/etc/apache2/` or `/etc/httpd/conf/` |
| `httpd_service_enabled`  | `true`                         | false    | Whether the httpd service should start on boot |
| `httpd_service_name`     | *depends on `distribution_id`* | false    | Name of the httpd service, e.g. `apache2.service` on Debian and `httpd.service` on Red Hat Enterprise Linux |
| `httpd_service_state`    | `started`                      | false    | State of the httpd service |
| `distribution_id`        | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keyword `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`apache2_module`][
community-general-apache2-module], [`blockinfile`][ansible-builtin-blockinfile], [`copy`][ansible-builtin-copy],
[`debconf`][ansible-builtin-debconf],[`file`][ansible-builtin-file], [`lineinfile`][ansible-builtin-lineinfile] and
[`template`][ansible-builtin-template].

[community-general-apache2-module]: https://docs.ansible.com/ansible/latest/collections/community/general/apache2_module_module.html
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
  become: true
  roles:
  - name: Manage httpd service
    role: jm1.cloudy.httpd
    tags: ["jm1.cloudy.httpd"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-100-pxe-server-debian11` from the
provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host
can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

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
