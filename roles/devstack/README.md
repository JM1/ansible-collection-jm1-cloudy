# Ansible Role `jm1.cloudy.devstack`

This role helps with quickly bringing up a complete OpenStack environment with [DevStack][devstack].

[devstack]: https://docs.openstack.org/devstack/latest/

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                         | Default value                   | Required | Description |
| ---------------------------- | ------------------------------- | -------- | ----------- |
| `devstack_admin_password`    | `secret`                        | no       | Password for Horizon and Keystone (20 chars or less) |
| `devstack_config`            | *refer to [`roles/devstack/defaults/main.yml`](defaults/main.yml)* | no | Content of `devstack/local.conf` which defines the OpenStack environment |
| `devstack_database_password` | `{{ devstack_admin_password }}` | no       | Password to use for the database |
| `devstack_rabbit_password`   | `{{ devstack_admin_password }}` | no       | Password to use for RabbitMQ |
| `devstack_service_password`  | `{{ devstack_admin_password }}` | no       | Password to use for the service authentication |
| `devstack_user`              | `stack`                         | no       | UNIX user that the `stack.sh` script is executed as |
| `distribution_id`            | *depends on operating system*   | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  become: yes
  roles:
  - name: Setup an OpenStack cluster with DevStack
    role: jm1.cloudy.devstack
    tags: ["jm1.cloudy.devstack"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-20-devstack` from the provided
[examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

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
