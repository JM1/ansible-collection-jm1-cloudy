# Ansible Role `jm1.cloudy.iptables`

This role helps with managing [iptables][iptables] rules from Ansible variables. Role variable `iptables_config` defines
a list of tasks which will be run by this role. Each task calls an Ansible module similar to tasks in roles or playbooks
except that only few [keywords][playbooks-keywords] such as `when` are supported. For example, to enable
[SNAT (source NAT)][snat-wiki] for all packets coming from an internal network define variable `iptables_config` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
iptables_config:
- # do SNAT (source NAT) for all packets coming from internal network
  ansible.builtin.iptables:
    chain: POSTROUTING
    destination: 0.0.0.0/0
    jump: SNAT
    out_interface: 'eth0' # network device on external network
    source: 192.168.0.0/24 # internal network
    table: nat
    to_source: 10.10.10.10 # ip address on external network

# persist iptables rules across reboots
iptables_persistence: true
```

First, if `iptables_persistence` evaluates to `true`, then this role will install packages (matching the distribution
specified in `distribution_id`) to persist iptables rules across reboots. Next, it will run all tasks listed in
`iptables_config`. Once all tasks have finished, if anything has changed and `iptables_persistence` evaluates to `true`
(and if `iptables_service_state` is not set to `stopped`), then all iptables rules are stored to survive reboots.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[iptables]: https://wiki.archlinux.org/title/Iptables
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[snat-wiki]: https://en.wikipedia.org/wiki/SNAT

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

| Name                       | Default value                  | Required | Description |
| -------------------------- | ------------------------------ | -------- | ----------- |
| `distribution_id`          | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `iptables_config`          | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to modify iptables rules |
| `iptables_persistence`     | `false`                        | false    | Whether iptables rules should persist across reboots |
| `iptables_service_enabled` | `true`                         | false    | Whether the iptables service should start on boot (only used on CentOS and Red Hat Enterprise Linux) |
| `iptables_service_name`    | `iptables`                     | false    | Name of the iptables service (only used on CentOS and Red Hat Enterprise Linux) |
| `iptables_service_state`   | `started`                      | false    | State of the iptables service (only used on CentOS and Red Hat Enterprise Linux) |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keyword `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`iptables`][ansible-builtin-iptables] and
[`ansible.posix.firewalld`][ansible-posix-firewalld].

[ansible-builtin-iptables]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/iptables_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-posix-firewalld]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/firewalld_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

An example host is supposed to have two network interfaces:
* device `eth0` on external network with static ip address `10.10.10.10`
* device `eth1` on internal network `192.168.0.0/24` with any matching ip address

To enable [SNAT (source NAT)][snat-wiki] for all packets coming from an internal network:

```yml
- hosts: all
  become: true
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    iptables_config:
    - # do SNAT (source NAT) for all packets coming from internal network
      ansible.builtin.iptables:
        chain: POSTROUTING
        destination: 0.0.0.0/0
        jump: SNAT
        out_interface: 'eth0'
        source: 192.168.0.0/24
        table: nat
        to_source: 10.10.10.10
    iptables_persistence: true
  roles:
  - name: Manage iptables rules
    role: jm1.cloudy.iptables
    tags: ["jm1.cloudy.iptables"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-100-pxe-server-debian11`,
`lvrt-lcl-session-srv-210-tripleo-standalone` or `lvrt-lcl-session-srv-300-hwfp-server-debian11` from the provided
[examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts
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
