# Ansible Role `jm1.cloudy.ssh_authorized_keys`

This role helps with managing [SSH authorized keys][archlinux-wiki-ssh-keys] from Ansible variables. It allows to add,
modify and delete SSH public keys e.g. from `~/.ssh/authorized_keys` with variable `ssh_authorized_keys`. This variable
is defined as a list where each list item is a dictionary of parameters that will be passed to Ansible's [authorized_key
][ansible-module-authorized-key] module. For example, to ensure that public SSH keys of the current user who runs
Ansible on the Ansible controller is present on an Ansible host, define variable `ssh_authorized_keys` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
ssh_authorized_keys_default: |
  {% for type in ['dsa', 'ecdsa', 'ed25519', 'rsa'] %}
  {% set path = lookup('env','HOME') + '/.ssh/id_' + type + '.pub' %}
  {% set found = lookup('first_found', path, errors='ignore') | default('', true) | length > 0 %}
  {% if found %}
  - comment: "{{ lookup('pipe','whoami') + '@' + lookup('pipe','hostname') + ':' + path }}"
    key: "{{ lookup('file', path) }}"
    state: present
    user: '{{ ansible_user }}'
  {% endif %}
  {% endfor %}

ssh_authorized_keys: '{{ ssh_authorized_keys_default | from_yaml }}'
```

When this role is executed, it will pass each item of the `ssh_authorized_keys` list one after another as parameters to
Ansible's [authorized_key][ansible-module-authorized-key] module.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[ansible-module-authorized-key]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html
[archlinux-wiki-ssh-keys]: https://wiki.archlinux.org/title/SSH_keys

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

| Name                  | Default value | Required | Description                               |
| --------------------- | ------------- | -------- | ----------------------------------------- |
| `ssh_authorized_keys` | `[]`          | false    | List of parameter dictionaries for Ansible's [authorized_key][ansible-module-authorized-key] module |

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
    ssh_authorized_keys:
    - # Add SSH public keys from jm1's github account
      key: https://github.com/jm1.keys
      state: present
      user: ansible
  roles:
  - name: Setup SSH authorized keys
    role: jm1.cloudy.ssh_authorized_keys
    tags: ["jm1.cloudy.ssh_authorized_keys"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
