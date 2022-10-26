# Ansible Role `jm1.cloudy.openstack_images`

This role helps with managing [images for OpenStack Glance][openstack-images] from Ansible variables. It allows to add
and delete images and define [image properties][openstack-image-properties] with variable `openstack_images`. This
variable is defined as a list where each list item is a dictionary of parameters that will be passed to module
[`jm1.openstack.image_import`][jm1-openstack-image-import] from collection [`jm1.openstack`][galaxy-jm1-openstack]
[^openstack-images-parameter]. For example, to add an image of Debian 11 (Bullseye) to [OpenStack project][
openstack-ops-guide-projects-users] `admin`, define variable `openstack_images` in [`group_vars` or `host_vars`][
ansible-inventory] as such:

```yml
openstack_images:
- # no checksum because image is updated every week
  name: debian-11-genericcloud-amd64
  properties:
    cpu_arch: x86_64
    hw_disk_bus: virtio
    hw_qemu_guest_agent: 'yes'
    hw_video_model: qxl
    hw_vif_model: virtio
    os_distro: debian
    os_require_quiesce: 'yes'
    os_version: 11
  state: present
  uri: https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.raw
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

When this role is executed, it will pass each item of the `openstack_images` list one after another as
parameters to module [`jm1.openstack.image_import`][jm1-openstack-image-import] from collection [`jm1.openstack`][
galaxy-jm1-openstack] [^openstack-images-parameter].

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[galaxy-jm1-openstack]: https://galaxy.ansible.com/jm1/openstack
[jm1-openstack-image-import]: https://github.com/JM1/ansible-collection-jm1-openstack/blob/master/plugins/modules/image_import.py
[openstack-image-properties]: https://docs.openstack.org/glance/latest/admin/useful-image-properties.html
[openstack-images]: https://docs.openstack.org/glance/latest/admin/manage-images.html
[openstack-ops-guide-projects-users]: https://docs.openstack.org/operations-guide/ops-projects-users.html
[openstacksdk-config]: https://docs.openstack.org/openstacksdk/latest/user/config/configuration.html

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

This role uses module(s) from collections [`jm1.openstack`][galaxy-jm1-openstack] and [`openstack.cloud`][
galaxy-openstack-cloud]. To install these collections you may follow the steps described in [`README.md`][
jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                  | Default value | Required | Description                               |
| --------------------- | ------------- | -------- | ----------------------------------------- |
| `openstack_auth`      | `{{ omit }}`  | no       | ["Dictionary containing auth information as needed by the cloud's auth plugin strategy. For the default `password` plugin, this would contain `auth_url`, `username`, `password`, `project_name` and any information about domains (for example, `user_domain_name` or `project_domain_name`) if the cloud supports them. For other plugins, this param will need to contain whatever parameters that auth plugin requires. This parameter is not needed if a named cloud is provided or OpenStack `OS_*` environment variables are present"][openstack-cloud-image] |
| `openstack_cloud`     | `{{ omit }}`  | no       | ["Named cloud or cloud config to operate against. If cloud is a string, it references a named cloud config as defined in an OpenStack clouds.yaml file. Provides default values for `auth` and `auth_type`. This parameter is not needed if `auth` is provided or if OpenStack `OS_*` environment variables are present. If cloud is a dict, it contains a complete cloud configuration like would be in a section of `clouds.yaml`"][openstack-cloud-image] |
| `openstack_images`    | `[]`          | no       | List of parameter dictionaries for module [`jm1.openstack.image_import`][jm1-openstack-image-import] from collection [`jm1.openstack`][galaxy-jm1-openstack] [^openstack-images-parameter] |
| `openstack_interface` | `{{ omit }}`  | no       | ["Endpoint URL type to fetch from the service catalog"][openstack-cloud-image] |

[^openstack-images-parameter]: If a list item does not contain key `auth`, `cloud` or `interface` then these
will be initialized from Ansible variables `openstack_auth`, `openstack_cloud` and `openstack_interface` respectively.
Each list item has an optional key `properties` which is used to manage [properties associated with this image][
openstack-image-properties]. It is not passed to module [`jm1.openstack.image_import`][jm1-openstack-image-import] but
to module [`openstack.cloud.image`][openstack-cloud-image] from collection [`openstack.cloud`][galaxy-openstack-cloud]
instead.

[galaxy-openstack-cloud]: https://galaxy.ansible.com/openstack/cloud
[openstack-cloud-image]: https://docs.ansible.com/ansible/latest/collections/openstack/cloud/image_module.html

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
    openstack_images:
    - # no checksum because image is updated every week
      name: debian-11-genericcloud-amd64
      properties:
        cpu_arch: x86_64
        hw_disk_bus: virtio
        hw_qemu_guest_agent: 'yes'
        hw_video_model: qxl
        hw_vif_model: virtio
        os_distro: debian
        os_require_quiesce: 'yes'
        os_version: 11
      state: present
      uri: https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.raw
  roles:
  - role: jm1.cloudy.openstack_images
    tags: ["jm1.cloudy.openstack_images"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
