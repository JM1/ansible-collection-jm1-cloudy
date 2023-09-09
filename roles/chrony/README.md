# Ansible Role `jm1.cloudy.chrony`

This role helps with configuring [chrony][chrony] from Ansible variables. For example, it allows to edit
`/etc/chrony.conf` on Red Hat Enterprise Linux or `/etc/chrony/chrony.conf` and files in `/etc/chrony/{conf,sources}.d/`
on Debian. Variable `chrony_config` defines a list of tasks which will be run by this role. Each task calls an Ansible
module similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `when` are
supported. For example, to allow NTP clients from a particular subnet to access a NTP server on Debian define variable
`chrony_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
chrony_config:
- ansible.builtin.copy:
    content: |
      allow 192.168.158.0/24
    dest: /etc/chrony/conf.d/home.arpa.conf
    mode: u=rw,g=r,o=
    group: root
    owner: root
```

First, this role will install a chrony package which matches the distribution specified in variable `distribution_id`.
Next, it will run all tasks listed in `chrony_config`. Once all tasks have finished and if anything has changed (and if
`chrony_service_state` is not set to `stopped`), then chrony's service (set in `chrony_service_name`) is restarted to
apply changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[chrony]: https://chrony-project.org/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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
| `chrony_config`          | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to configure `/etc/chrony.conf` or `/etc/chrony/chrony.conf` |
| `chrony_service_enabled` | `true`                         | false    | Whether the chrony service should start on boot |
| `chrony_service_name`    | *depends on `distribution_id`* | false    | Name of the chrony service, e.g. `chrony.service` on Debian and `chronyd.service` on Red Hat Enterprise Linux |
| `chrony_service_state`   | `started`                      | false    | State of the chrony service |
| `distribution_id`        | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

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

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  become: true
  roles:
  - name: Manage chrony service
    role: jm1.cloudy.chrony
    tags: ["jm1.cloudy.chrony"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-400-okd-ipi-router`,
`lvrt-lcl-session-srv-500-okd-abi-ha-router`, `lvrt-lcl-session-srv-600-okd-ipi-router` or 
`lvrt-lcl-session-srv-700-okd-sno-router` from the provided [examples inventory][inventory-example]. The top-level
[`README.md`][jm1-cloudy-readme] describes how this host can be provisioned with playbook [`playbooks/site.yml`][
playbook-site-yml].

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
