# Ansible Role `jm1.cloudy.openstack_server_state`

This role helps with managing the [state][server-concepts] of [OpenStack Nova (Compute) instances][nova] aka servers
from Ansible variables. It allows to start, pause, suspend, shutoff, shelve and offload a server with variable
`openstack_server_state`. For example, to shutdown instance `debian.home.arpa` which was launched in the introduction of
role [`jm1.cloudy.openstack_server`][jm1-cloudy-openstack-server], define `openstack_server_state` in [`group_vars` or
`host_vars`][ansible-inventory] as such:

```yml
# Possible server states: [active, paused, suspended, shutoff, shelved, shelved_offloaded]
# Ref.: https://docs.openstack.org/api-guide/compute/server_concepts.html
openstack_server_state: shutoff
```

When this role is executed, it will first query the OpenStack API for the current [state][server-concepts] of Compute
instance named by `openstack_server_name` using module [`openstack.cloud.server_info`][openstack-cloud-server-info] from
collection [`openstack.cloud`][galaxy-openstack-cloud]. When any host operation is pending like the original build
process has not yet finished, the server is hard rebooting or is migrating, then this role will wait until the
operations have been completed. Next, it will perform server actions such as (un)pause and (un)shelve using module
[`openstack.cloud.server_action`][openstack-cloud-server-action] to bring the server into the desired state.

If variable `state` is `absent`, then this role does nothing.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[galaxy-openstack-cloud]: https://galaxy.ansible.com/openstack/cloud
[jm1-cloudy-openstack-server]: ../openstack_server/
[nova]: https://docs.openstack.org/nova/latest/
[openstack-cloud-server-action]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/server_action_module.html
[openstack-cloud-server-info]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/server_info_module.html
[openstacksdk-config]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html
[server-concepts]: https://docs.openstack.org/api-guide/compute/server_concepts.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`openstack.cloud`][galaxy-openstack-cloud]. To install this collection you may
follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                            | Default value              | Required | Description                               |
| ------------------------------- | -------------------------- | -------- | ----------------------------------------- |
| `openstack_auth`                | `{{ omit }}`               | no       | ["Dictionary containing auth information as needed by the cloud's auth plugin strategy. For the default `password` plugin, this would contain `auth_url`, `username`, `password`, `project_name` and any information about domains (for example, `user_domain_name` or `project_domain_name`) if the cloud supports them. For other plugins, this param will need to contain whatever parameters that auth plugin requires. This parameter is not needed if a named cloud is provided or OpenStack `OS_*` environment variables are present"][openstack-cloud-server-action] |
| `openstack_cloud`               | `{{ omit }}`               | no       | ["Named cloud or cloud config to operate against. If cloud is a string, it references a named cloud config as defined in an OpenStack clouds.yaml file. Provides default values for `auth` and `auth_type`. This parameter is not needed if `auth` is provided or if OpenStack `OS_*` environment variables are present. If cloud is a dict, it contains a complete cloud configuration like would be in a section of `clouds.yaml`"][openstack-cloud-server-action] |
| `openstack_interface`           | `{{ omit }}`               | no       | ["Endpoint URL type to fetch from the service catalog"][openstack-cloud-server-action] |
| `openstack_server_name`         | `{{ inventory_hostname }}` | no       | Name of the [OpenStack Nova (Compute) instance][nova] aka server |
| `openstack_server_state`        | `active`                   | no       | [Possible server states: `[active, paused, suspended, shutoff, shelved, shelved_offloaded]`][server-concepts] |
| `state`                         | `present`                  | no       | Should the server be present or absent |

## Dependencies

None.

## Example Playbook

First, define and launch [Nova (Compute) instance `debian.home.arpa` as described in the introduction of role
`jm1.cloudy.openstack_server`][jm1-cloudy-openstack-server]. Provide [OpenStack auth information for the OpenStack SDK
][openstacksdk-config] as well by defining Ansible variable `openstack_auth` or `openstack_cloud` or by defining
OpenStack `OS_*` environment variables.

```yml
- hosts: all
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    # Possible server states: [active, paused, suspended, shutoff, shelved, shelved_offloaded]
    # Ref.: https://docs.openstack.org/api-guide/compute/server_concepts.html
    openstack_server_state: shutoff
  roles:
  - name: Manage OpenStack server state
    role: jm1.cloudy.openstack_server_state
    tags: ["jm1.cloudy.openstack_server_state"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
