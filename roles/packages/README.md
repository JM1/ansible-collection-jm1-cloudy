# Ansible Role `jm1.cloudy.packages`

This role helps with managing packages from Ansible variables. It allows to install, upgrade and remove packages with
variable `packages` which is defined in [`group_vars` or `host_vars`][ansible-inventory] either as

* a list where each list item is a dictionary of parameters which will be passed to Ansible's [package][
  ansible-module-package] module, e.g.

```yml
# packages as a list of dictionaries
packages:
- name:
  - bash
  - vim
  state: 'present'
- name:
  - zsh
  - nano
  state: 'absent'
```

* a dictionary of parameters which will be passed to Ansible's [package][ansible-module-package] module, e.g.

```yml
# packages as a single dictionary
packages:
  name:
  - bash
  - vim
  state: 'present'
```

* a list of packages which will be installed with Ansible's [package][ansible-module-package] module, e.g.

```yml
# packages as a list of strings
packages:
- bash
- vim
```

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[ansible-module-package]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html

**Tested OS images**
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/buster/daily/) of Debian 10 (Buster)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bullseye/daily/) of Debian 11 (Bullseye)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bookworm/daily/) of Debian 12 (Bookworm)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/trixie/daily/) of Debian 13 (Trixie)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/7/images/) of CentOS 7 (Core)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/8-stream/x86_64/images/) of CentOS 8 (Stream)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/9-stream/x86_64/images/) of CentOS 9 (Stream)
- [Cloud image (`amd64`)](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/) of Fedora Cloud Base 40
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/bionic/current/) of Ubuntu 18.04 LTS (Bionic Beaver)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/focal/) of Ubuntu 20.04 LTS (Focal Fossa)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/jammy/) of Ubuntu 22.04 LTS (Jammy Jellyfish)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/noble/) of Ubuntu 24.04 LTS (Noble Numbat)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

None.

## Variables

| Name       | Default value | Required | Description                               |
| ---------- | ------------- | -------- | ----------------------------------------- |
| `packages` | `[]`          | false    | List of parameter dictionaries, a single parameter dictionary or a list of strings for Ansible's [package][ansible-module-package] module |

## Dependencies

None.

## Example Playbook

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
    packages:
    - fzf
  roles:
  - name: Manage packages
    role: jm1.cloudy.packages
    tags: ["jm1.cloudy.packages"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
