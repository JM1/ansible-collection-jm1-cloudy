# TODO

* `grep -r -i -F -I TODO`

* Implement role to verify e.g. network, i.e. to check expected vs open sockets (`netstat -tulpen` / `ss -tulpen`)

* Add unit tests, e.g. for build dependency groups in [`inventory/hosts.yml`](inventory/hosts.yml)

* Add role `jm1.cloudy.ifupdown` similar to role `jm1.netplan`?

* Add OpenStack-based hosts to example inventory to showcase OpenStack integration

* Replace role `jm1.cloudy.tripleo_standalone` with tripleo.operator collection and its `playbooks/standalone.yml` play

* Migrate `users_config`, `ssh_authorized_keys`, `groups_config` and others to `jm1.ansible.execute_module`?

* Added support for Fedora

* Drop `jm1.cloudy.openstack_server` role

* Replace `changed_when: true` in role `jm1.cloudy.kolla_ansible` to identify changes from command output
