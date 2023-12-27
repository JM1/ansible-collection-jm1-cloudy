# TODO

* `grep -r -i -F -I TODO`

* Add role `jm1.cloudy.ifupdown` similar to role `jm1.netplan`?

* Add OpenStack-based hosts to example inventory to showcase OpenStack integration

* Migrate `users_config`, `ssh_authorized_keys`, `groups_config` and others to `jm1.ansible.execute_module`?

* Added support for Fedora

* Drop `jm1.cloudy.openstack_server` role

* Replace `changed_when: true` in role `jm1.cloudy.kolla_ansible` to identify changes from command output

* Add role `jm1.cloudy.{openstack_,}tempest` to run [Tempest](https://docs.openstack.org/tempest/latest/) against
  DevStack, TripleO and Kolla Ansible deployments

* Add role `jm1.cloudy.ceph{,adm}` to deploy a Ceph cluster with [cephadm](https://docs.ceph.com/en/quincy/cephadm/)
