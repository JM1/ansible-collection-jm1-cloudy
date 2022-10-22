# Ansible Role `jm1.cloudy.netplan`

This role helps with managing [Netplan][netplan] [configuration][netplan-ref] from Ansible variables. Role variable
`netplan_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when` are
supported. For example, to assign static ip address `192.168.0.2`, DNS server `192.168.0.1` and default gateway
`192.168.0.1` to network interface `eth0`, define variable `netplan_config` in [`group_vars` or `host_vars`][
ansible-inventory] as such:

```yml
netplan_config:
- # Assign a static ip address, dns server and default gateway to network interface eth0
  copy:
    content: |
      # 2021 Jakob Meng, <jakobmeng@web.de>
      network:
        version: 2
        ethernets:
          eth0:
            dhcp4: false
            dhcp6: false
            accept-ra: false
            addresses:
            - 192.168.0.2/24
            nameservers:
              addresses:
              - 192.168.0.1
            routes:
            - to: 0.0.0.0/0
              via: 192.168.0.1
    dest: /etc/netplan/99-jm1-cloudy-netplan-example.yaml
    owner: root
    group: root
    mode: u=rw,g=r,o=r
```

:warning: **WARNING:**
On systems without Netplan, a package such as `netplan.io` on Debian and Ubuntu has to be installed first. This role
will not install Netplan because presumably additional configuration is required such as deactivating the substituted
network configuration mechanism like `ifupdown` on Debian. For example, one may use role [`jm1.cloudy.packages`][
jm1-cloudy-packages] to install Netplan and role [`jm1.cloudy.services`][jm1-cloudy-services] to deactivate other
networking services.
:warning:

When this role is executed, it will run all tasks listed in `netplan_config`. Once all tasks have finished and if
anything has changed, then the updated Netplan configuration will be applied (with `netplan apply`) and the system will
be rebooted to apply more complex updates such as changes to the Netplan service itself.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[jm1-cloudy-packages]: ../packages/
[jm1-cloudy-services]: ../services/
[netplan]: https://netplan.io/
[netplan-ref]: https://netplan.io/reference/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name             | Default value | Required | Description |
| ---------------- | ------------- | -------- | ----------- |
| `netplan_config` | `[]`          | no       | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to edit files in `/etc/netplan/` |

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

None.

## Example Playbook

```yml
- hosts: all
  become: yes
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    netplan_config:
    - # Assign a static ip address, dns server and default gateway to network interface eth0
      copy:
        content: |
          # 2021 Jakob Meng, <jakobmeng@web.de>
          network:
            version: 2
            ethernets:
              eth0:
                dhcp4: false
                dhcp6: false
                accept-ra: false
                addresses:
                - 192.168.0.2/24
                nameservers:
                  addresses:
                  - 192.168.0.1
                routes:
                - to: 0.0.0.0/0
                  via: 192.168.0.1
        dest: /etc/netplan/99-jm1-cloudy-netplan-example.yaml
        owner: root
        group: root
        mode: u=rw,g=r,o=r
  roles:
  - name: Change Netplan configuration
    role: jm1.cloudy.netplan
    tags: ["jm1.cloudy.netplan"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
