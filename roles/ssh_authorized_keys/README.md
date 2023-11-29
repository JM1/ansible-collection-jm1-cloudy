# Ansible Role `jm1.cloudy.ssh_authorized_keys`

This role helps with managing [SSH authorized keys][archlinux-wiki-ssh-keys] from Ansible variables. It allows to add,
modify and delete SSH public keys e.g. from `~/.ssh/authorized_keys` with variable `ssh_authorized_keys`. This variable
is defined as a list where each list item is a dictionary of parameters that will be passed to Ansible's [authorized_key
][ansible-module-authorized-key] module. For example, to ensure that the public SSH (RSA) key of the current user who
runs Ansible on the Ansible controller is present on an Ansible host, define variable `ssh_authorized_keys` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
ssh_authorized_keys:
- comment: >-
    {{ lookup('pipe','whoami') + '@' + lookup('pipe','hostname') + ':' + lookup('env','HOME') + '/.ssh/id_rsa.pub' }}
  key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/id_rsa.pub') | mandatory }}"
  state: present
  user: '{{ ansible_user }}'
```

When this role is executed, it will pass each item of the `ssh_authorized_keys` list one after another as parameters to
Ansible's [authorized_key][ansible-module-authorized-key] module.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[ansible-module-authorized-key]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/authorized_key_module.html
[archlinux-wiki-ssh-keys]: https://wiki.archlinux.org/title/SSH_keys

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
    - # Add SSH public (RSA) keys from jm1's github account
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
