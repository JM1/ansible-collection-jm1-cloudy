# TODO

* `grep -r -i -F -I TODO`

* Implement role to verify e.g. network, i.e. to check expected vs open sockets (`netstat -tulpen` / `ss -tulpen`)

* Add unit tests, e.g. for build dependency groups in [`inventory/hosts.yml`](inventory/hosts.yml)

* Add role `jm1.cloudy.ifupdown` similar to role `jm1.netplan`?

* Move related `jm1.*` roles, e.g. jm1.dhcpd`, into this collection

* Drop requirement to execute role `jm1.cloudy.openstack_server_netplan`

  Role `jm1.cloudy.openstack_server_netplan` sets Ansible fact `openstack_netplan`
  which is used in `inventory/group_vars/ostk.yml` to set variable `ansible_host`.

* Add OpenStack-based hosts to example inventory to showcase OpenStack integration

* Replace role `jm1.cloudy.tripleo_standalone` with tripleo.operator collection and its `playbooks/standalone.yml` play
