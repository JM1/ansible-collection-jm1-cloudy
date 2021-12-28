# Ansible Role `jm1.cloudy.files`

This role helps with assembling, copying, moving, deleting, editing, uploading and downloading files, directories and
links, changing ownership and permissions, cloning git and subversion repositories, extracting archives, accessing web
services and more from Ansible variables.

Role variable `files_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that [task keywords such as `name`, `notify` and `when`][
playbooks-keywords] are ignored. For example, to ensure the inventory name for the current Ansible host being iterated
over in the play is in `/etc/hosts` define variable `files_config` in [`group_vars` or `host_vars`][ansible-inventory]
as such:

```yml
files_config:
- lineinfile:
    path: /etc/hosts
    search_string: '.1 {{ inventory_hostname }} {{ inventory_hostname_short }}'
    line: "{{ '{ip} {fqdn} {hostname}'.format(
                ip='127.0.0.1' if ansible_facts.distribution in ['CentOS', 'Red Hat Enterprise Linux'] else '127.0.1.1',
                fqdn=inventory_hostname, hostname=inventory_hostname_short) }}"
    owner: root
    group: root
    mode: '0644'
- lineinfile:
    path: /etc/hosts
    search_string: '::1 {{ inventory_hostname }} {{ inventory_hostname_short }}'
    line: '::1 {{ inventory_hostname }} {{ inventory_hostname_short }}'
    owner: root
    group: root
    mode: '0644'
```

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`community.general`][galaxy-community-general]. To install this collection
you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables


| Name           | Default value | Required | Description                               |
| -------------- | ------------- | -------- | ----------------------------------------- |
| `files_config` | `[]`          | no       | List of tasks to run [^supported-modules] |

[^supported-modules]: Supported Ansible modules are [`assemble`][ansible-module-assemble], [`blockinfile`][
ansible-module-blockinfile], [`capabilities`][ansible-module-capabilities], [`copy`][ansible-module-copy], [`fetch`][
ansible-module-fetch], [`file`][ansible-module-file], [`get_url`][ansible-module-get-url], [`git`][ansible-module-git],
[`lineinfile`][ansible-module-lineinfile], [`replace`][ansible-module-replace], [`slurp`][ansible-module-slurp],
[`subversion`][ansible-module-subversion], [`template`][ansible-module-template], [`unarchive`][
ansible-module-unarchive], [`uri`][ansible-module-uri] and [`xattr`][ansible-module-xattr].

[ansible-module-assemble]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assemble_module.html
[ansible-module-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-module-capabilities]: https://docs.ansible.com/ansible/latest/collections/community/general/capabilities_module.html
[ansible-module-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-module-fetch]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html
[ansible-module-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-module-get-url]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/get_url_module.html
[ansible-module-git]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/git_module.html
[ansible-module-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-module-replace]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/replace_module.html
[ansible-module-slurp]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/slurp_module.html
[ansible-module-subversion]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/subversion_module.html
[ansible-module-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[ansible-module-unarchive]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html
[ansible-module-uri]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/uri_module.html
[ansible-module-xattr]: https://docs.ansible.com/ansible/latest/collections/community/general/xattr_module.html

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
      git:
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
