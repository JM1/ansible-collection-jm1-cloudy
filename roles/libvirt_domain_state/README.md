# Ansible Role `jm1.cloudy.libvirt_domain_state`

This role helps with managing the [state][libvirt-domain-state] of [libvirt domains][libvirt] aka virtual machines
from Ansible variables. It allows to start, pause, suspend and shutdown a domain with variable `libvirt_domain_state`.
For example, to shutdown domain `debian.home.arpa` which was launched in the introduction of role
[`jm1.cloudy.libvirt_domain`][jm1-cloudy-libvirt-domain], define `libvirt_domain_state` in [`group_vars` or
`host_vars`][ansible-inventory] as such:

```yml
# Possible domain states: [running, paused, pmsuspended, shutoff]
# Ref.: https://libvirt.org/html/libvirt-libvirt-domain.html#virDomainState
libvirt_domain_state: shutoff
```

When this role is executed, it will first query the local libvirt daemon (run by current Ansible user on the Ansible
controller) for the current [state][libvirt-domain-state] of the libvirt domain named by `libvirt_domain`. Next it will
perform domain commands such as starting or pausing to bring the domain into the desired state.
If `libvirt_domain_state` is set to `shutoff`, then this role will send a shutdown signal to the domain, then it will
wait for the domain to shutdown and if it is still running after 900 seconds it will be destroyed (killed). All
operations will be performed with module [`community.libvirt.virt`][community-libvirt-virt] from collection
[`community.libvirt`][galaxy-community-libvirt].

If variable `state` is `absent`, then this role does nothing.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[community-libvirt-virt]: https://docs.ansible.com/ansible/latest/collections/community/libvirt/virt_module.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[jm1-cloudy-libvirt-domain]: ../libvirt_domain/
[libvirt]: https://libvirt.org/

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`community.libvirt`][galaxy-community-libvirt]. To install this collection you
may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[jm1-cloudy-readme]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/README.md
[jm1-cloudy-requirements]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/requirements.yml

## Variables

| Name                             | Default value              | Required | Description |
| -------------------------------- | -------------------------- | -------- | ----------- |
| `libvirt_domain`                 | `{{ inventory_hostname }}` | no       | Name of the domain |
| `libvirt_domain_state`           | `running`                  | no       | [Possible domain states: `[running, paused, pmsuspended, shutoff]`][libvirt-domain-state] [^libvirt-domain-state-parameter] |
| `libvirt_uri`                    | `qemu:///system`           | no       | [libvirt connection uri][libvirt-uri] |
| `state`                          | `present`                  | no       | Should the libvirt domain be present or absent |

[^libvirt-domain-state-parameter]: Domain state `pmsuspended` is currently not supported by release version `1.0.0` of
module [`community.libvirt.virt`][community-libvirt-virt] and so this role respectively.

[libvirt-domain-state]: https://libvirt.org/html/libvirt-libvirt-domain.html#virDomainState
[libvirt-uri]: https://libvirt.org/uri.html

## Dependencies

None.

## Example Playbook

First, define and launch [libvirt domain `debian.home.arpa` as described in the introduction of role
`jm1.cloudy.libvirt_domain`][jm1-cloudy-libvirt-domain].

```yml
- hosts: all
  # do not become root because connection is local
  connection: local # Assign libvirt_uri to setup a connection to the libvirt host
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    # Possible domain states: [running, paused, pmsuspended, shutoff]
    # Ref.: https://libvirt.org/html/libvirt-libvirt-domain.html#virDomainState
    libvirt_domain_state: shutoff

  roles:
  - name: Manage libvirt domain state
    role: jm1.cloudy.libvirt_domain_state
    tags: ["jm1.cloudy.libvirt_domain_state"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-*` from the provided [examples
inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/inventory/
[playbook-site-yml]: https://github.com/JM1/ansible-collection-jm1-cloudy/blob/master/playbooks/site.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
