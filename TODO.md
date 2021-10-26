# TODO

* `grep -r -i -F -I TODO`

* Implement role to verify e.g. network, i.e. to check expected vs open sockets (`netstat -tulpen` / `ss -tulpen`)

* Add unit tests, e.g. for build dependency groups in [`inventory/hosts.yml`](inventory/hosts.yml)

* Add role `jm1.cloudy.ifupdown` similar to role `jm1.netplan`?

* Move related `jm1.*` roles, e.g. jm1.dhcpd`, into this collection

* Add OpenStack-based hosts to example inventory to showcase OpenStack integration

* Replace role `jm1.cloudy.tripleo_standalone` with tripleo.operator collection and its `playbooks/standalone.yml` play
