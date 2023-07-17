# Ansible Role `jm1.cloudy.podman`

This role helps with managing the [Podman][podman] container engine from Ansible variables. For example, it allows to
pulling or pushing container images, running commands in containers and managing groups of containers aka pods. Variable
`podman_config` defines a list of tasks which will be run by this role. Each task calls an Ansible module similar to
tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `become` and `when` are
supported.

For example, to run [Apache HTTP Server][httpd] aka `httpd` in a rootful Podman container on system boot define variable
`podman_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
podman_config:
- # Create systemd service unit for running Apache HTTP server in a Podman container
  become: true
  ansible.builtin.copy:
    content: |
      [Unit]
      Description=Apache HTTP server in a Podman container
      Wants=network.target
      After=network-online.target

      [Service]
      Environment=PODMAN_SYSTEMD_UNIT=%n
      Restart=on-failure
      TimeoutStopSec=70
      ExecStartPre=/bin/rm -f %t/podman-httpd.pid %t/podman-httpd.ctr-id
      ExecStart=/usr/bin/podman run \
        --conmon-pidfile %t/podman-httpd.pid \
        --cidfile %t/podman-httpd.ctr-id \
        --cgroups=no-conmon \
        --replace \
        --detach --tty --publish 8080:80/tcp --name httpd docker.io/library/httpd
      ExecStop=/usr/bin/podman stop --ignore --cidfile %t/podman-httpd.ctr-id -t 10
      ExecStopPost=/usr/bin/podman rm --ignore -f --cidfile %t/podman-httpd.ctr-id
      PIDFile=%t/podman-httpd.pid
      Type=forking

      [Install]
      WantedBy=multi-user.target default.target
    dest: /etc/systemd/system/podman-httpd.service
  handlers:
  - # On changes reload systemd daemon and restart Podman container
    become: true
    ansible.builtin.service:
      daemon_reload: true
      name: podman-httpd.service
      state: restarted
- # Ensure systemd service is enabled
  become: true
  ansible.builtin.service:
    enabled: true
    name: podman-httpd.service
```

First, this role will install packages for Podman which match the distribution specified in variable `distribution_id`.
Next, it will run all tasks listed in `podman_config`. Once all tasks have finished and if anything has changed, then
special task variable `handlers` will be evaluated for any changed tasks and all tasks defined in `handlers` will be
run.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[httpd]: https://httpd.apache.org/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[podman]: https://podman.io/

**Tested OS images**
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS 8 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
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

| Name                     | Default value                  | Required | Description |
| ------------------------ | ------------------------------ | -------- | ----------- |
| `podman_config`          | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to create systemd unit files for containers and pods in `/etc/systemd/system` |
| `distribution_id`        | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. (Only exception is [`meta: flush_handlers`][
ansible-builtin-meta] which is fully supported). In addition, Ansible does not support free-form parameters for
arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `become`, `become_exe`, `become_flags`, `become_method`, `become_user`, `environment`, `when` and
special keyword `handlers` only. Task keyword `handlers` defines a list of handlers which will be notified and run when
a task has changed anything. Handlers will also be executed with [`jm1.ansible.execute_module`][
jm1-ansible-execute-module] and thus only keywords `become`, `become_exe`, `become_flags`, `become_method`,
`become_user`, `environment` and `when` are supported. **NOTE:** Keywords related to `become` will not inherit values
from the role's caller. For example, when `become` is defined in a playbook it will not be passed on to a task or
handler here.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`command`][ansible-builtin-command], [`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][
ansible-builtin-lineinfile], [`sefcontext`][community-general-sefcontext], [`selinux`][ansible-posix-selinux],
[`service`][ansible-builtin-service], [`systemd`][ansible-builtin-systemd] and [`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-command]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-service]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html
[ansible-builtin-systemd]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[ansible-posix-selinux]: https://docs.ansible.com/ansible/latest/collections/ansible/posix/selinux_module.html
[community-general-sefcontext]: https://docs.ansible.com/ansible/latest/collections/community/general/sefcontext_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Manage pods, containers and images with Podman
    role: jm1.cloudy.podman
    tags: ["jm1.cloudy.podman"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-035-ubuntu2204-podman` from the
provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host
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
