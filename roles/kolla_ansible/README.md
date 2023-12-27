# Ansible Role `jm1.cloudy.kolla_ansible`

This role helps with deploying an OpenStack cloud using [Kolla Ansible][kolla-ansible]. It codifies Kolla Ansible's
quickstart guides for [deployment/evaluation][kolla-ansible-quickstart] and [development][kolla-ansible-quickstart-dev].
It also supports [multinode deployments][kolla-ansible-multinode].

First, this role will install package dependencies for [Kolla Ansible][kolla-ansible] such as Python 3, Python packages
for Python virtual environments, a compiler and development libraries. Next, [Kolla Ansible will be installed to a
virtual environment][kolla-ansible-virtual-environments] at path defined in Ansible variable `kolla_ansible_venv_dir`.
Variable `kolla_ansible_pip_spec` controls what version of Kolla Ansible is being installed (**NOTE:** The OpenStack
release which Kolla Ansible will install is defined with `globals.yml` instead][kolla-ansible-globals-yml]). Afterwards,
the role will query the minimum and maximum Ansible versions which are supported by Kolla Ansible and install a suitable
candidate for `ansible-core` to the virtual environment.

Next, a directory for Kolla Ansible's configuration will be created at the path defined in `kolla_ansible_config_dir`.
The configuration files themselves like [`globals.yml`][kolla-ansible-globals-yml], [`passwords.yml`][
kolla-ansible-passwords-yml] and the inventory (e.g. [`all-in-one`][kolla-ansible-inventory-all-in-one] or
[`multinode`][kolla-ansible-inventory-multinode]) will be created from variable `kolla_ansible_config`:

This variable defines a list of tasks that this role shall run in order to create the configuration files. Each task
calls an Ansible module similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such
as `become` and `when` are supported.

To aid debugging, the version of `kolla-ansible` will be printed.

With all of Kolla Ansible's prerequisites satisfied, the role will call `kolla-ansible`'s commands to deploy OpenStack:
1. `kolla-ansible install-deps` will install Ansible Galaxy dependencies for Kolla Ansible,
2. `kolla-ansible bootstrap-servers` will bootstrap servers with Kolla deploy dependencies,
3. `kolla-ansible prechecks` will do pre-deployment checks for all hosts,
4. `kolla-ansible deploy` will deploy and start Kolla containers on all hosts,
5. `kolla-ansible post-deploy` will do the post deploy on the deploy node.

Each call above can be modified with `kolla_ansible_*_args` variables such as `kolla_ansible_prechecks_args` for Kolla
Ansible's pre-deployment checks. As a mimimum, variable `kolla_ansible_default_args` has to define the `-i` (or
`--inventory`) argument which Kolla Ansible uses to find the path to the Ansible inventory. By default, all other
`kolla_ansible_*_args` variables will inherit the value from `kolla_ansible_default_args`.

After each successful call, a hidden file `.jm1-cloudy-kolla-ansible-*` will be created in directory
`kolla_ansible_config_dir`. For example, when `kolla-ansible bootstrap-servers` has finished with exit code `0`, a file
`{{ kolla_ansible_config_dir }}/.jm1-cloudy-kolla-ansible-bootstrap-servers` will be written. When this role is executed
again, these files will be detected and corresponding calls will be skipped. To force this role to run any call again,
simply remove the corresponding `.jm1-cloudy-kolla-ansible-*` file.

When all steps have completed, the OpenStack cloud can be accessed with `openstack` aka [OpenStackClient aka OSC][
openstackclient] using the configuration file generated at `{{ kolla_ansible_config_dir }}/clouds.yaml` (manually copy
the file to `/etc/openstack` or `~/.config/openstack` or set environment variable `OS_CLIENT_CONFIG_FILE`).

[kolla-ansible]: https://docs.openstack.org/kolla-ansible/latest/
[kolla-ansible-globals-yml]: https://opendev.org/openstack/kolla-ansible/src/branch/master/etc/kolla/globals.yml
[kolla-ansible-inventory-all-in-one]: https://opendev.org/openstack/kolla-ansible/src/branch/master/ansible/inventory/all-in-one
[kolla-ansible-inventory-multinode]: https://opendev.org/openstack/kolla-ansible/src/branch/master/ansible/inventory/multinode
[kolla-ansible-multinode]: https://docs.openstack.org/kolla-ansible/latest/user/multinode.html
[kolla-ansible-passwords-yml]: https://opendev.org/openstack/kolla-ansible/src/branch/master/etc/kolla/passwords.yml
[kolla-ansible-quickstart]: https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html
[kolla-ansible-quickstart-dev]: https://docs.openstack.org/kolla-ansible/latest/user/quickstart-development.html
[kolla-ansible-virtual-environments]: https://docs.openstack.org/kolla-ansible/latest/user/virtual-environments.html
[openstackclient]: https://docs.openstack.org/python-openstackclient/latest/

**Tested OS images**
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS Stream 8` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS Stream 9` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from Ansible collections [`jm1.ansible`][galaxy-jm1-ansible] and [`jm1.pkg`][galaxy-jm1-pkg].
To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided
[`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                                   | Default value                      | Required | Description |
| -------------------------------------- | ---------------------------------- | -------- | ----------- |
| `distribution_id`                      | *depends on operating system*      | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `kolla_ansible_bootstrap_servers_args` | `{{ kolla_ansible_default_args }}` | false    | Extra command arguments for `kolla-ansible bootstrap-servers` which will bootstrap servers with Kolla deploy dependencies |
| `kolla_ansible_config`                 | *undefined*                        | true     | List of tasks to run in order to create configuration files for Kolla Ansible in `kolla_ansible_config_dir` [^example-modules] [^supported-keywords] [^supported-modules] |
| `kolla_ansible_config_dir`             | `/etc/kolla`                       | false    | Directory where configuration files for Kolla Ansible like `globals.yml` and `passwords.yml` will be created |
| `kolla_ansible_default_args`           | *undefined*                        | true     | Extra command arguments for `kolla-ansible` calls. In particular, `-i` (or `--inventory`) is required to specify the path to the Ansible inventory. |
| `kolla_ansible_deploy_args`            | `{{ kolla_ansible_default_args }}` | false    | Extra command arguments for `kolla-ansible deploy` which will deploy and start all Kolla containers |
| `kolla_ansible_pip_spec`               | `git+https://opendev.org/openstack/kolla-ansible@master` | false | A pip [requirement specifier][pip-requirement-specifier] which defines what version of Kolla Ansible will be installed. **NOTE:** What release of OpenStack will be installed is defined in [Kolla Ansible's `globals.yml`][kolla-ansible-globals-yml]! |
| `kolla_ansible_post_deploy_args`       | `{{ kolla_ansible_default_args }}` | false    | Extra command arguments for `kolla-ansible post-deploy` which will do post deploy on the deploy node |
| `kolla_ansible_prechecks_args`         | `{{ kolla_ansible_default_args }}` | false    | Extra command arguments for `kolla-ansible prechecks` which will do pre-deployment checks for hosts |
| `kolla_ansible_user`                   | `{{ ansible_user }}`               | false    | UNIX user which will be used to run the `kolla-ansible` commands |
| `kolla_ansible_venv_dir`               | `/opt/kolla_ansible_venv`          | false    | Base path where the [Python virtual environment][kolla-ansible-virtual-environments] for Kolla Ansible and Ansible will be created |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters for
arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `become`, `become_exe`, `become_flags`, `become_method`, `become_user`, `environment` and `when` only.
**NOTE:** Keywords related to `become` will not inherit values from the role's caller. For example, when `become` is
defined in a playbook it will not be passed on to a task here.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`command`][ansible-builtin-command], [`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][
ansible-builtin-lineinfile], [`openssh_keypair`][community-crypto-openssh-keypair] and [`template`][
ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-command]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[community-crypto-openssh-keypair]: https://docs.ansible.com/ansible/latest/collections/community/crypto/openssh_keypair_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py
[pip-requirement-specifier]: https://pip.pypa.io/en/stable/reference/requirement-specifiers/

## Dependencies

| Name                | Description |
| ------------------- | ----------- |
| `jm1.pkg.setup`     | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Deploy an OpenStack cloud using Kolla Ansible
    role: jm1.cloudy.kolla_ansible
    tags: ["jm1.cloudy.kolla_ansible"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-800-kolla-router` up to
`lvrt-lcl-session-srv-899-kolla-provisioner` from the provided [examples inventory][inventory-example]. The top-level
[`README.md`][jm1-cloudy-readme] describes how these hosts can be provisioned with playbook [`playbooks/site.yml`][
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
