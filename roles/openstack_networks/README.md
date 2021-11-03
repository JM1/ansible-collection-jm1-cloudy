# Ansible Role `jm1.cloudy.openstack_networks`

This role helps with managing [OpenStack (Neutron) networks][neutron-admin-guide] from Ansible variables. It allows to
create, modify and delete [OpenStack networks, subnets, routers, ports and floating ips][neutron-intro] with variables
`openstack_networks`, `openstack_subnets`, `openstack_routers`, `openstack_ports` and `openstack_floating_ips`
respectively. These variables are defined as a list where each list item is a dictionary of parameters that will be
passed to modules from collection [`openstack.cloud`][galaxy-openstack-cloud], e.g. items in `openstack_networks` will
be passed to module [`openstack.cloud.network`][openstack-cloud-network] [^openstack-networks-parameter]. For example,
to add an externally accessible network `external_network` to [OpenStack project][openstack-ops-guide-projects-users]
`admin`, define variable `openstack_networks` in [`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
openstack_networks:
- external: true
  name: external_network
  state: present
```

Next, provide [OpenStack auth information for the OpenStack SDK][openstacksdk-config], i.e. define Ansible variables
`openstack_auth` or `openstack_cloud` or define OpenStack `OS_*` environment variables. For example, create file
`$HOME/.config/openstack/clouds.yaml` with

```yml
clouds:
  admin_devstack_home_arpa:
    profile: devstack_home_arpa
    auth:
      username: admin
      project_name: admin
      password: secret
```

and `$HOME/.config/openstack/clouds-public.yaml` with

```yml
public-clouds:
  devstack_home_arpa:
    auth:
      auth_url: http://devstack.home.arpa:5000/v3/
      user_domain_name: Default
      project_domain_name: Default
    block_storage_api_version: 3
    identity_api_version: 3
    volume_api_version: 3
    interface: internal
    # Workaround for a bug in python-openstackclient where 'interface' key is ignored.
    # The old 'endpoint_type' key is still respected though.
    # Ref.: https://storyboard.openstack.org/#!/story/2007380
    endpoint_type: internal
```

and define Ansible variable `openstack_cloud` as such:

```yml
openstack_cloud: 'admin_devstack_home_arpa'
```

When this role is executed, it will pass each item of the `openstack_networks` list one after another as
parameters to module [`openstack.cloud.network`][openstack-cloud-network] from collection [`openstack.cloud`][
galaxy-openstack-cloud] [^openstack-networks-parameter].

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[galaxy-jm1-openstack]: https://galaxy.ansible.com/jm1/openstack
[galaxy-openstack-cloud]: https://galaxy.ansible.com/openstack/cloud
[jm1-openstack-floating-ip]: https://github.com/JM1/ansible-collection-jm1-openstack/blob/master/plugins/modules/floating_ip.py
[neutron-admin-guide]: https://docs.openstack.org/neutron/latest/admin/
[neutron-intro]: https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html
[openstack-cloud-network]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/network_module.html
[openstack-cloud-port]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/port_module.html
[openstack-cloud-router]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/router_module.html
[openstack-cloud-subnet]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/subnet_module.html
[openstack-ops-guide-projects-users]: https://docs.openstack.org/operations-guide/ops-projects-users.html
[openstack-cloud-project-access]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/project_access_module.html
[openstacksdk-config]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collections [`jm1.openstack`][galaxy-jm1-openstack] and [`openstack.cloud`][
galaxy-openstack-cloud]. To install these collections you may follow the steps described in [`README.md`][
jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                     | Default value | Required | Description                               |
| ------------------------ | ------------- | -------- | ----------------------------------------- |
| `openstack_auth`         | `{{ omit }}`  | no       | ["Dictionary containing auth information as needed by the cloud's auth plugin strategy. For the default `password` plugin, this would contain `auth_url`, `username`, `password`, `project_name` and any information about domains (for example, `user_domain_name` or `project_domain_name`) if the cloud supports them. For other plugins, this param will need to contain whatever parameters that auth plugin requires. This parameter is not needed if a named cloud is provided or OpenStack `OS_*` environment variables are present"][openstack-cloud-network] |
| `openstack_cloud`        | `{{ omit }}`  | no       | ["Named cloud or cloud config to operate against. If cloud is a string, it references a named cloud config as defined in an OpenStack clouds.yaml file. Provides default values for `auth` and `auth_type`. This parameter is not needed if `auth` is provided or if OpenStack `OS_*` environment variables are present. If cloud is a dict, it contains a complete cloud configuration like would be in a section of `clouds.yaml`"][openstack-cloud-network] |
| `openstack_floating_ips` | `[]`          | no       | List of parameter dictionaries for module [`jm1.openstack.floating_ip`][jm1-openstack-floating-ip] from collection [`jm1.openstack`][galaxy-jm1-openstack] [^openstack-networks-parameter] |
| `openstack_interface`    | `{{ omit }}`  | no       | ["Endpoint URL type to fetch from the service catalog"][openstack-cloud-network] |
| `openstack_networks`     | `[]`          | no       | List of parameter dictionaries for module [`openstack.cloud.network`][openstack-cloud-network] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-networks-parameter] |
| `openstack_ports`        | `[]`          | no       | List of parameter dictionaries for module [`openstack.cloud.port`][openstack-cloud-port] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-networks-parameter] |
| `openstack_routers`      | `[]`          | no       | List of parameter dictionaries for module [`openstack.cloud.router`][openstack-cloud-router] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-networks-parameter] |
| `openstack_subnets`      | `[]`          | no       | List of parameter dictionaries for module [`openstack.cloud.subnet`][openstack-cloud-subnet] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-networks-parameter] |

[^openstack-networks-parameter]: If a list item does not contain key `auth`, `cloud` or `interface` then these
will be initialized from Ansible variables `openstack_auth`, `openstack_cloud` and `openstack_interface` respectively.

## Dependencies

| Name                  | Description |
| --------------------- | ----------- |
| `jm1.openstack.setup` | Installs necessary software for module `jm1.openstack.image_import` from collection `jm1.openstack`. |

## Example Playbook

First, provide [OpenStack auth information for the OpenStack SDK][openstacksdk-config] by defining Ansible variable
`openstack_auth` or `openstack_cloud` or by defining OpenStack `OS_*` environment variables as shown above.

```yml
- hosts: all
  connection: local # Connection to OpenStack is handled by OpenStack SDK and Ansible's OpenStack modules
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    openstack_networks:
    - external: true
      name: external_network
      state: present
  roles:
  - role: jm1.cloudy.openstack_networks
    tags: ["jm1.cloudy.openstack_networks"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
