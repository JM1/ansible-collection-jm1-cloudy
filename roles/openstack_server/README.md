# Ansible Role `jm1.cloudy.openstack_server`

This role helps with defining [OpenStack Nova (Compute) instances][nova] aka servers as Ansible hosts.

For example, to launch a Nova (Compute) instance named `debian.home.arpa` with Debian 11 (Bullseye) on external network
`external_network` in [OpenStack project][openstack-ops-guide-projects-users] `admin`, define [an Ansible host
`debian.home.arpa` in an Ansible inventory][ansible-inventory]. A minimal [Ansible inventory][ansible-inventory] could
be defined in file `inventory/hosts.yml` as such:

```yml
all:
  hosts:
    debian.home.arpa:
```

Then define properties of host `debian.home.arpa` like [Cinder (block storage) volumes][cinder-admin] and [Neutron
(network) ports][neutron-intro] as Ansible variables in file `inventory/host_vars/debian.home.arpa.yml` as such:

```yml
openstack_server_config:
  boot_volume: 'debian-home-arpa'
  config_drive: yes
  flavor: 'm1.tiny'
  userdata: |
    #cloud-config
    chpasswd:
      list: |
        ansible:secret
      expire: False
    packages:
    - python3

openstack_server_ports:
- name: 'debian-home-arpa-0'
  network: 'external_network'

# NOTE: Variable openstack_server_state has to be defined in this inventory else grouping fails in playbooks/site.yml!
#
# Possible server states: [active, paused, suspended, shutoff, shelved, shelved_offloaded]
# Ref.: https://docs.openstack.org/api-guide/compute/server_concepts.html
openstack_server_state: active

openstack_volumes:
- bootable: yes
  display_name: 'debian-home-arpa'
  image: 'debian-11-genericcloud-amd64'
  size: 20
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

Use role [`jm1.cloudy.openstack_compute_flavors`][jm1-cloudy-openstack-compute-flavors] to create a Nova (Compute)
flavor with name `m1.tiny` as shown by the example playbooks of this role.

Use role [`jm1.cloudy.openstack_networks`][jm1-cloudy-openstack-networks] to create the external network
`external_network` as shown by the example playbooks of this role.

Use role [`jm1.cloudy.openstack_volumes`][jm1-cloudy-openstack-volumes] and [`jm1.cloudy.openstack_images`][
jm1-cloudy-openstack-images] to create the Cinder (block storage) volume `debian-home-arpa` based on an Debian 11
(Bullseye) as shown by the example playbooks these roles.

Once all previous roles have finished, execute role `jm1.cloudy.openstack_server`. First, this role will [unshelve the
instance if it exists already and has been shelved because OpenStack does not allow to apply changes to shelved
instances][server-concepts]. Next, it will create (or delete) network ports listed in variable `openstack_server_ports`.
This variable is defined as a list where each list item is a dictionary of parameters that will be passed to module
[`openstack.cloud.port`][openstack-cloud-port] [^openstack-server-ports-parameter]. It will then query the OpenStack API
for the ids of `openstack_server_config.boot_volume` and all Cinder volumes listed in `openstack_server_config.volumes`.
The contents of the `openstack_server_config` variable, all network ports from `openstack_server_ports` and all volume
ids will then be passed as parameters to module [`openstack.cloud.server`][openstack-cloud-server] to create and launch
the Nova instance `debian.home.arpa` [^openstack-server-config-parameter]. Afterwards all floating ips listed in
`openstack_server_floating_ips` will be created if necessary and attached to the server. Variable
`openstack_server_floating_ips` is defined as a list where each list item is a dictionary of parameters that will be
passed to module [`openstack.cloud.floating_ip`][openstack-cloud-floating-ip]
[^openstack-server-floating-ips-parameter]. Once finished, it will be verified that all floating ips have been attached
correctly because [older releases of the `openstack.cloud.floating_ip` module do not support attaching multiple floating
ips to a server][openstack-story-2008181]. Finally, this role will wait for the server to launch and become usable.

If variable `state` is `absent` instead, then all floating ips listed in `openstack_server_floating_ips` will be
detached, the Nova instance specified with `openstack_server_config` will be deleted and all network ports listed in
`openstack_server_ports` will be removed.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[cinder-admin]: https://docs.openstack.org/cinder/latest/admin/blockstorage-manage-volumes.html
[galaxy-openstack-cloud]: https://galaxy.ansible.com/openstack/cloud
[jm1-cloudy-openstack-compute-flavors]: ../openstack_compute_flavors/
[jm1-cloudy-openstack-images]: ../openstack_images/
[jm1-cloudy-openstack-networks]: ../openstack_networks/
[jm1-cloudy-openstack-volumes]: ../openstack_volumes/
[neutron-intro]: https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html
[nova]: https://docs.openstack.org/nova/latest/
[openstack-cloud-port]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/port_module.html
[openstack-cloud-server]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/server_module.html
[openstack-cloud-floating-ip]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/floating_ip_module.html
[openstack-ops-guide-projects-users]: https://docs.openstack.org/operations-guide/ops-projects-users.html
[openstack-story-2008181]: https://storyboard.openstack.org/#!/story/2008181
[openstacksdk-config]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html
[server-concepts]: https://docs.openstack.org/api-guide/compute/server_concepts.html

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

This role uses module(s) from collection [`openstack.cloud`][galaxy-openstack-cloud]. To install this collection you may
follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                            | Default value              | Required | Description                               |
| ------------------------------- | -------------------------- | -------- | ----------------------------------------- |
| `openstack_auth`                | `{{ omit }}`               | no       | ["Dictionary containing auth information as needed by the cloud's auth plugin strategy. For the default `password` plugin, this would contain `auth_url`, `username`, `password`, `project_name` and any information about domains (for example, `user_domain_name` or `project_domain_name`) if the cloud supports them. For other plugins, this param will need to contain whatever parameters that auth plugin requires. This parameter is not needed if a named cloud is provided or OpenStack `OS_*` environment variables are present"][openstack-cloud-server] |
| `openstack_cloud`               | `{{ omit }}`               | no       | ["Named cloud or cloud config to operate against. If cloud is a string, it references a named cloud config as defined in an OpenStack clouds.yaml file. Provides default values for `auth` and `auth_type`. This parameter is not needed if `auth` is provided or if OpenStack `OS_*` environment variables are present. If cloud is a dict, it contains a complete cloud configuration like would be in a section of `clouds.yaml`"][openstack-cloud-server] |
| `openstack_interface`           | `{{ omit }}`               | no       | ["Endpoint URL type to fetch from the service catalog"][openstack-cloud-server] |
| `openstack_server_config`       | `{}`                       | no       | Parameter dictionary for module [`openstack.cloud.server`][openstack-cloud-server] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-server-config-parameter] |
| `openstack_server_floating_ips` | `[]`                       | no       | [Floating ips][neutron-intro] to be created and attached to the server. List of parameter dictionaries for module [`openstack.cloud.floating_ip`][openstack-cloud-floating-ip] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-server-floating-ips-parameter] |
| `openstack_server_name`         | `{{ inventory_hostname }}` | no       | Name of the [OpenStack Nova (Compute) instance][nova] aka server. It will be passed as parameter `name` to module [`openstack.cloud.server`][openstack-cloud-server] |
| `openstack_server_ports`        | `[]`                       | no       | [Neutron (network) ports][neutron-intro] to be created and assigned to the server. List of parameter dictionaries for module [`openstack.cloud.port`][openstack-cloud-port] from collection [`openstack.cloud`][galaxy-openstack-cloud] [^openstack-server-ports-parameter] |
| `openstack_server_state`        | `active`                   | no       | [Possible server states: `[active, paused, suspended, shutoff, shelved, shelved_offloaded]`][server-concepts] |
| `state`                         | `present`                  | no       | Should the server be present or absent |

[^openstack-server-config-parameter]: If a list item does not contain key `auth`, `cloud` or `interface` then these will
be initialized from Ansible variables `openstack_auth`, `openstack_cloud` and `openstack_interface` respectively. Keys
`floating_ips`, `name` and `state` in `openstack_server_config` will be ignored, instead use variables
`openstack_server_floating_ips`, `openstack_server_name` and `state` respectively. Key `nics` in
`openstack_server_config` will be expanded with ports listed in `openstack_server_ports`.

[^openstack-server-floating-ips-parameter]: If a list item does not contain key `auth`, `cloud`, `interface` or `server`
then these will be initialized from Ansible variables `openstack_auth`, `openstack_cloud`, `openstack_interface` and
`openstack_server_name` respectively.

[^openstack-server-ports-parameter]: If a list item does not contain key `auth`, `cloud` or `interface` then these will
be initialized from Ansible variables `openstack_auth`, `openstack_cloud` and `openstack_interface` respectively. After
ports in `openstack_server_ports` have been created, this role will query OpenStack's API for all port ids and pass
them as parameter `nics` to module [`openstack.cloud.server`][openstack-cloud-server].

## Dependencies

None.

## Example Playbook

First, define an Ansible host `debian.home.arpa` and its properties like Cinder (block storage) volumes and Neutron
(network) ports as Ansible variables in an inventory as shown in the introductory example. Provide [OpenStack auth
information for the OpenStack SDK][openstacksdk-config] as well by defining Ansible variable `openstack_auth` or
`openstack_cloud` or by defining OpenStack `OS_*` environment variables.

```yml
- hosts: all
  connection: local # Connection to OpenStack is handled by OpenStack SDK and Ansible's OpenStack modules
  roles:
  - name: Setup OpenStack server
    role: jm1.cloudy.openstack_server
    tags: ["jm1.cloudy.openstack_server"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
