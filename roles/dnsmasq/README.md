# Ansible Role `jm1.cloudy.dnsmasq`

This role helps with managing the [dnsmasq][dnsmasq], a lightweight DHCP and caching DNS server, from Ansible variables.
For example, it allows to edit config files in `/etc/dnsmasq.d/` and define [systemd units][archlinux-wiki-systemd].
Variable `dnsmasq_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when`
are supported. For example, to run [dnsmasq][dnsmasq] as a DHCP and DNS server on Debian 11 (Bullseye) define variable
`dnsmasq_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
dnsmasq_config:
- ansible.builtin.copy:
    content: |
      bind-dynamic
      dhcp-authoritative
      dhcp-no-override
      dhcp-range=192.168.158.100,192.168.158.254,255.255.255.0
      no-resolv
      server=192.168.158.1
      strict-order
    dest: /etc/dnsmasq.d/demo
    mode: u=rw,g=r,o=
    group: root
    owner: root
```

First, this role will install packages for dnsmasq which match the distribution specified in variable `distribution_id`.
Next, it will run all tasks listed in `dnsmasq_config`. Once all tasks have finished and if anything has changed (and if
`dnsmasq_service_state` is not set to `stopped`), then dnsmasq's service (set in `dnsmasq_service_name`) is restarted to
apply changes.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[dnsmasq]: https://dnsmasq.org

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

| Name                      | Default value                  | Required | Description |
| ------------------------- | ------------------------------ | -------- | ----------- |
| `distribution_id`         | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `dnsmasq_config`          | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to configure files in `/etc/dnsmasq.d/` |
| `dnsmasq_service_enabled` | `true`                         | false    | Whether the dnsmasq service should start on boot |
| `dnsmasq_service_name`    | `dnsmasq`                      | false    | Name of the dnsmasq service |
| `dnsmasq_service_state`   | `started`                      | false    | State of the dnsmasq service |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters for
arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `register` and `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][ansible-builtin-lineinfile] and [`template`][
ansible-builtin-template].

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
  - name: Manage dnsmasq service
    role: jm1.cloudy.dnsmasq
    tags: ["jm1.cloudy.dnsmasq"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-036-ubuntu2204-dnsmasq` from the
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
