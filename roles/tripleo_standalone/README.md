# Ansible Role `jm1.cloudy.tripleo_standalone`

This role deploys a [TripleO standalone environment][tripleo-standalone-setup].

[tripleo-standalone-setup]: https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/deployment/standalone.html

**Tested OS images**
- Generic cloud image of [`CentOS 8 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                                          | Default value                         | Required | Description |
| --------------------------------------------- | ------------------------------------- | -------- | ----------- |
| `distribution_id`                             | *depends on operating system*         | no       | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `dns_suffix`                                  | *undefined*                           | yes      | DNS domain of the host which is used e.g. for `tripleo_standalone_cloud_domain` and `tripleo_standalone_neutron_dns_domain` |
| `tripleo_standalone_branch`                   | `master`                              | no       | TripleO ["Target branch. Should be the lowercase name of the OpenStack release. e.g. liberty"][tripleo-repos-main] |
| `tripleo_standalone_cloud_name`               | `tripleo_standalone`                  | no       | ["The DNS name of this cloud. E.g. ci-overcloud.tripleo.org"][tripleo-heat-templates-overcloud] |
| `tripleo_standalone_cloud_domain`             | `{{ dns_suffix }}`                    | no       | ["The DNS domain used for the hosts. This must match the overcloud_domain_name configured on the undercloud"][tripleo-heat-templates-deploy-steps] |
| `tripleo_standalone_control_virtual_ip`       | *undefined*                           | yes      | ["Control plane VIP. This allows the undercloud installer to configure a custom VIP on the control plane"][tripleo-deploy-cmd] |
| `tripleo_standalone_home_dir`                 | `/home/{{ tripleo_standalone_user }}` | no       | Home of `tripleo_standalone_user` where TripleO config files will be created |
| `tripleo_standalone_local_ip`                 | *undefined*                           | yes      | ["Local IP/CIDR for undercloud traffic"][tripleo-deploy-cmd] |
| `tripleo_standalone_neutron_dns_domain`       | `{{ dns_suffix }}`                    | no       | ["Domain to use for building the hostnames"][tripleo-heat-templates-neutron-base] |
| `tripleo_standalone_neutron_public_interface` | *undefined*                           | yes      | ["Which interface to add to the NeutronPhysicalBridge"][tripleo-heat-templates-overcloud] |
| `tripleo_standalone_parameters`               | *refer to [`roles/tripleo_standalone/defaults/main.yml`](defaults/main.yml)* | no | Content of TripleO standalone configuration file `{{ tripleo_standalone_home_dir }}/standalone_parameters.yaml` |
| `tripleo_standalone_repo_uri`                 | `https://trunk.rdoproject.org/centos8-{{ tripleo_standalone_branch }}/component/tripleo/current/delorean.repo` | no | Where to download the Yum repository information file (`*.repo`) for TripleO |
| `tripleo_standalone_repos`                    | `current`                             | no       | [Name of package repositories list which `tripleo-repos` will install][tripleo-repos] |
| `tripleo_standalone_user`                     | `stack`                               | no       | UNIX user that TripleO will use for deployment aka `DeploymentUser` in ` tripleo_standalone_parameters` |

[tripleo-deploy-cmd]: https://docs.openstack.org/python-tripleoclient/latest/commands.html#tripleo-deploy
[tripleo-heat-templates-deploy-steps]: https://opendev.org/openstack/tripleo-heat-templates/src/branch/master/common/deploy-steps.j2
[tripleo-heat-templates-overcloud]: https://opendev.org/openstack/tripleo-heat-templates/src/branch/master/overcloud.j2.yaml
[tripleo-heat-templates-neutron-base]: https://opendev.org/openstack/tripleo-heat-templates/src/branch/master/deployment/neutron/neutron-base.yaml
[tripleo-repos]: https://opendev.org/openstack/tripleo-repos/src/branch/master/README.rst
[tripleo-repos-main]: https://opendev.org/openstack/tripleo-repos/src/branch/master/plugins/module_utils/tripleo_repos/main.py

## Dependencies

| Name               | Description                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `jm1.pkg.setup`    | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

The example host is supposed to have two network interfaces:
* device `eth0` with dhcp or any static ip address which Ansible uses to connect to the host and which TripleO will not
  touch. Do *NOT* use any ip address from network `192.168.152.0/24`, this network is used on `eth1`.
* device `eth1` with static ip address `192.168.152.2/24`.

Ip address `192.168.152.3/24` must not be assigned on the network of `eth1`. TripleO will assign this ip address during
setup.

The DNS name of the host is supposed to be `tripleo_standalone` and the DNS domain is supposed to be `home.arpa`, so
the FQDN of the host is `tripleo_standalone.home.arpa`.

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
    dns_suffix: home.arpa
    tripleo_standalone_control_virtual_ip: '192.168.152.3/24'
    tripleo_standalone_local_ip: '192.168.152.2/24'
    tripleo_standalone_neutron_public_interface: 'eth1'
  roles:
  - name: Deploy TripleO standalone
    role: jm1.cloudy.tripleo_standalone
    tags: ["jm1.cloudy.tripleo_standalone"]
```
Once this role has finished, login to the host and verify your setup with OpenStack CLI:

```sh
export OS_CLOUD=standalone
openstack endpoint list
```

Red Hat's Enable Sysadmin team has further instructions on [how to use your TripleO standalone environment][
tripleo-standalone-guide].

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-210-tripleo-standalone` from the
provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host
can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml
[tripleo-standalone-guide]: https://www.redhat.com/sysadmin/tripleo-standalone-system

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
