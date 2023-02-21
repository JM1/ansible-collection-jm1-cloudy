# Ansible Role `jm1.cloudy.ipmi`

This role helps with managing IPMI devices from Ansible variables. It allows to change a machine's power state and its
boot devices. For example, to power-cycle an Ansible host `server.home.arpa` and boot it from network, define `ipmi_*`
variables in its [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
# Hostname or IP address of the BMC
ipmi_host: ipmi.home.arpa

# Username which is used to connect to the BMC
ipmi_username: 'ADMIN'

# Password which is used to connect to the BMC
ipmi_password: 'secret'
```

Next, run this role as an [ad hoc command][adhoc]:

```sh
ansible server.home.arpa -m include_role -a name=jm1.cloudy.ipmi \
    -e "ansible_connection=local force_ipmi_boot_from_network=true"
```

When this role is executed, it will first configure the system to boot from network. Then it will reset the system if it
is powered on or boot the system if it is powered off. Finally, this role will wait for the system to come up.

[adhoc]: https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html
[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`community.general`][galaxy-community-general]. To install this collection
you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                           | Default value | Required | Description |
| ------------------------------ | ------------- | -------- | ----------- |
| `force_ipmi_boot`              | `false`       | false    | Whether boot devices should be changed. :warning: This variable is supposed to be a safety guard and as such should be set as extra vars on the command line, *NOT* in `host_vars` or `group_vars`! :warning: |
| `force_ipmi_power`             | `false`       | false    | Whether machine power state should be changed. :warning: This variable is supposed to be a safety guard and as such should be set as extra vars on the command line, *NOT* in `host_vars` or `group_vars`! :warning: |
| `force_ipmi_boot_from_network` | `false`       | false    | Whether system should be reset and boot from network. :warning: This variable is supposed to be a safety guard and as such should be set as extra vars on the command line, *NOT* in `host_vars` or `group_vars`! :warning: |
| `impi_boot_persistent`         | `false`       | false    | ["If set, ask that system firmware uses this device beyond next boot. Be aware many systems do not honor this."][ansible-module-ipmi-boot] |
| `ipmi_boot_device`             | `default`     | false    | [Set boot device to use on next reboot. The choices for the device are: `['network', 'floppy', 'hd', 'safe', 'optical', 'setup', 'default']`][ansible-module-ipmi-boot] |
| `ipmi_host`                    | *undefined*   | true     | Hostname or IP address of the BMC |
| `ipmi_password`                | `ADMIN`       | false    | Password which is used to connect to the BMC |
| `ipmi_port`                    | `{{ omit }}`  | false    | Remote RMCP port |
| `ipmi_power_state`             | `on`          | false    | [Possible power states: `['on', 'off']`][ansible-module-ipmi-power] |
| `ipmi_uefiboot`                | `false`       | false    | ["If set, request UEFI boot explicitly. Strictly speaking, the spec suggests that if not set, the system should BIOS boot and offers no \"don't care\" option. In practice, this flag not being set does not preclude UEFI boot on any system I've encountered."][ansible-module-ipmi-boot] |
| `ipmi_username`                | `ADMIN`       | false    | Username which is used to connect to the BMC |

[ansible-module-ipmi-boot]: https://docs.ansible.com/ansible/latest/collections/community/general/ipmi_boot_module.html
[ansible-module-ipmi-power]: https://docs.ansible.com/ansible/latest/collections/community/general/ipmi_power_module.html

## Dependencies

None.

## Example Playbook

A playbook to change the boot device of an Ansible host `server.home.arpa` could be defined in `ipmi.yml` as such:

```yml
- hosts: all
  connection: local
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    # Hostname or IP address of the BMC
    ipmi_host: ipmi.home.arpa

    # Username which is used to connect to the BMC
    ipmi_username: 'ADMIN'

    # Password which is used to connect to the BMC
    ipmi_password: 'secret'
  roles:
  - name: Manage IPMI devices, e.g. machine power state and its boot device
    role: jm1.cloudy.ipmi
    tags: ["jm1.cloudy.ipmi"]
```

To execute this playbook, run

```sh
ansible-playbook ipmi.yml -l server.home.arpa -e "force_ipmi_boot=true"
```

Instead of defining a playbook, this role can be run as an [ad hoc command][adhoc]. First, define the `ipmi_*` variables
in [`group_vars` or `host_vars`][ansible-inventory] as shown in the introductory example. Then run:

```sh
ansible server.home.arpa -m include_role -a name=jm1.cloudy.ipmi -e "ansible_connection=local force_ipmi_boot=true"
```

To change the power state of a system only, define the `ipmi_power_state` and possibly other `ipmi_*` variables in
[`group_vars` or `host_vars`][ansible-inventory] as shown in the introductory example. Then run:

```sh
ansible server.home.arpa -m include_role -a name=jm1.cloudy.ipmi -e "ansible_connection=local force_ipmi_power=true"
```

To reset a system and boot it from network, refer to the introductory example.

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
