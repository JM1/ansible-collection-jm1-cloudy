# Ansible Role `jm1.cloudy.meta_packages`

This role helps with managing meta packages [^meta-packages] from Ansible variables. It allows to install, upgrade
and remove meta packages [^meta-packages] with variable `meta_packages` which is defined as a list where each list item
is a dictionary of parameters that will be passed to module [`jm1.pkg.meta_pkg`][jm1-pkg-meta-pkg] from collection
[`jm1.pkg`][galaxy-jm1-pkg]. For example, to install helpful tools for Python development on Debian 11 (Bullseye),
define variable `meta_packages` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
meta_packages:
- name: "jm1-cloudy-meta-packages-example"
  version: "1"
  depends:
  - ipython3
  - flake8
  - pycodestyle # formerly called pep8
  - python3-pip
  - python3-virtualenv
  - python3-pytest
```

[^meta-packages]: For rationale behind meta packages refer to description of the [`jm1.pkg.meta_pkg`][jm1-pkg-meta-pkg] module.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[jm1-pkg-meta-pkg]: https://github.com/JM1/ansible-collection-jm1-pkg/blob/master/plugins/modules/meta_pkg.py

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

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name            | Default value | Required | Description                               |
| --------------- | ------------- | -------- | ----------------------------------------- |
| `meta_packages` | `[]`          | false    | List of parameter dictionaries or a single parameter dictionary for module [`jm1.pkg.meta_pkg`][jm1-pkg-meta-pkg] from collection [`jm1.pkg`][galaxy-jm1-pkg] |

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

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
    meta_packages:
    - name: "jm1-cloudy-meta-packages-example"
      version: "1"
      depends:
      - ipython3
      - flake8
      - pycodestyle # formerly called pep8
      - python3-pip
      - python3-virtualenv
      - python3-pytest
  roles:
  - name: Manage meta packages
    role: jm1.cloudy.meta_packages
    tags: ["jm1.cloudy.meta_packages"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
