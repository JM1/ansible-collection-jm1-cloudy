# Ansible Role `jm1.cloudy.files`

This role helps with assembling, copying, moving, deleting, editing, uploading and downloading files, directories and
links, changing ownership and permissions, cloning git and subversion repositories, extracting archives, accessing web
services and more from Ansible variables.

Role variable `files_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `register` and `when`
are supported. For example, to ensure the inventory name for the current Ansible host being iterated over in the play is
in `/etc/hosts` define variable `files_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
files_config:
- ansible.builtin.lineinfile:
    path: /etc/hosts
    regexp: '\.1\s+{{ hostname }}'
    line: "{{ '{ip} {fqdn} {hostname}'.format(ip='127.0.0.1', fqdn=fqdn, hostname=hostname) }}"
    owner: root
    group: root
    mode: '0644'
  when: distribution_id|first in ['CentOS', 'Red Hat Enterprise Linux']
        or distribution_id in [['Debian', '10']]
- ansible.builtin.lineinfile:
    path: /etc/hosts
    regexp: '\.1\s+{{ hostname }}'
    line: "{{ '{ip} {fqdn} {hostname}'.format(ip='127.0.1.1', fqdn=fqdn, hostname=hostname) }}"
    owner: root
    group: root
    mode: '0644'
  when: distribution_id|first not in ['CentOS', 'Red Hat Enterprise Linux']
        and distribution_id not in [['Debian', '10']]
- ansible.builtin.lineinfile:
    path: /etc/hosts
    regexp: '::1\s+{{ hostname }}'
    line: '::1 {{ fqdn }} {{ hostname }}'
    owner: root
    group: root
    mode: '0644'
```

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
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

This role uses module(s) from collections [`community.general`][galaxy-community-general] and [`jm1.ansible`][
galaxy-jm1-ansible]. To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme]
using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name           | Default value | Required | Description |
| -------------- | ------------- | -------- | ----------- |
| `files_config` | `[]`          | no       | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules] |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters
for arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `register` and `when` only.

[^example-modules]: Useful Ansible modules in this context could be [`assemble`][ansible-builtin-assemble],
[`blockinfile`][ansible-builtin-blockinfile], [`capabilities`][community-general-capabilities], [`copy`][
ansible-builtin-copy], [`fetch`][ansible-builtin-fetch], [`file`][ansible-builtin-file], [`get_url`][
ansible-builtin-get-url], [`git`][ansible-builtin-git], [`lineinfile`][ansible-builtin-lineinfile], [`replace`][
ansible-builtin-replace], [`slurp`][ansible-builtin-slurp], [`subversion`][ansible-builtin-subversion], [`template`][
ansible-builtin-template], [`unarchive`][ansible-builtin-unarchive], [`uri`][ansible-builtin-uri] and [`xattr`][
community-general-xattr].

[ansible-builtin-assemble]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assemble_module.html
[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-fetch]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-get-url]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html
[ansible-builtin-git]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-replace]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/replace_module.html
[ansible-builtin-slurp]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/slurp_module.html
[ansible-builtin-subversion]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/subversion_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[ansible-builtin-unarchive]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html
[ansible-builtin-uri]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/uri_module.html
[community-general-capabilities]: https://docs.ansible.com/ansible/latest/collections/community/general/capabilities_module.html
[community-general-xattr]: https://docs.ansible.com/ansible/latest/collections/community/general/xattr_module.html
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
    files_config:
    - name: Clone a git repository
      ansible.builtin.git:
        repo: https://github.com/ansible/ansible-examples.git
        dest: /src/ansible-examples
  roles:
  - name: Manage files, directories, links and more
    role: jm1.cloudy.files
    tags: ["jm1.cloudy.files"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
