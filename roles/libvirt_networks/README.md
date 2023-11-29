# Ansible Role `jm1.cloudy.libvirt_networks`

This role helps with managing [libvirt networks][libvirt] from Ansible variables. For example, it allows to create,
modify and delete [NAT based networks, routed networks, isolated networks, bridged networks and direct (MacVTap)
connections][libvirt-format-network] with variable `libvirt_networks`. This variable is defined as a list where each
list item is a dictionary of parameters that will be passed to module [`jm1.libvirt.net_xml`][jm1-libvirt-net-xml] from
collection [`jm1.libvirt`][galaxy-jm1-libvirt]. For example, to create a [NAT based network][libvirt-format-network]
named `nat` with the system libvirt daemon (on the Ansible controller), define variable `libvirt_networks` in
[`group_vars` or `host_vars`][ansible-inventory] as such:

```yml
# connect from Ansible controller to local libvirt daemon
ansible_connection: local

libvirt_networks:
- acl: allow
  autostart: true
  xml: |
    <network>
      <name>nat</name>
      <bridge name="virbr-nat-0"/>
      <forward mode="nat"/>
      <ip address="192.168.123.1" netmask="255.255.255.0">
        <dhcp>
          <range start="192.168.123.100" end="192.168.123.254"/>
        </dhcp>
      </ip>
    </network>
```

When this role is executed, it will pass each item of the `libvirt_networks` list one after another as parameters to
module [`jm1.libvirt.net_xml`][jm1-libvirt-net-xml] from collection [`jm1.libvirt`][galaxy-jm1-libvirt]
[^libvirt-networks-parameter-uri]. If a libvirt network with the same name already exists, it will be updated if
necessary.

If a list item does not contain key `autostart` or if its set to `true` then module [`community.libvirt.virt_net`][
community-libvirt-virt-net] from collection [`community.libvirt`][galaxy-community-libvirt] will be used to mark that
network to be started automatically when the libvirt daemon starts.

If a list item contains key `acl` then [the capability to create TUN/TAP devices aka `cap_net_admin+ep` will be added to
`qemu-bridge-helper`][qemu-bridge-helper] and [QEMU's config file `/etc/qemu/bridge.conf` (on Debian based
distributions) or `/etc/qemu-kvm/bridge.conf` (on RHEL based distributions) will be edited to allow or deny access to
bridges (created by `qemu-bridge-helper` and implicitly invoked from libvirt daemon) for unprivileged users][qemu-acl]
[^libvirt-networks-parameter-acl].

[qemu-bridge-helper]: https://salsa.debian.org/libvirt-team/libvirt/-/blob/debian/latest/debian/libvirt-daemon.README.Debian#L45

At the end the same module will be used to stop and restart libvirt networks automatically to apply pending changes at
runtime.

If any list item in `libvirt_networks` has its key `state` set to `absent` then module [`jm1.libvirt.net_xml`][
jm1-libvirt-net-xml] will be used to stop (destroy) and delete (undefine) this network. Any line in [QEMU's config file
`/etc/qemu/bridge.conf` or `/etc/qemu-kvm/bridge.conf`][qemu-acl] which lists the bridge name of an `absent` libvirt
network will be removed to revoke access to bridges for unprivileged users [^libvirt-networks-parameter-acl].

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[community-libvirt-virt-net]: https://docs.ansible.com/ansible/latest/collections/community/libvirt/virt_net_module.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[jm1-libvirt-net-xml]: https://github.com/JM1/ansible-collection-jm1-libvirt/blob/master/plugins/modules/net_xml.py
[libvirt]: https://libvirt.org/
[libvirt-format-network]: https://libvirt.org/formatnetwork.html
[galaxy-community-libvirt]: https://galaxy.ansible.com/community/libvirt
[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS Linux 7` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS Stream 8` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS Stream 9` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collections  [`community.general`][galaxy-community-general], [`community.libvirt`][
galaxy-community-libvirt] and [`jm1.libvirt`][galaxy-jm1-libvirt]. To install these collections you may follow the steps
described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-community-general]: https://galaxy.ansible.com/community/general
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name               | Default value                 | Required | Description |
| ------------------ | ----------------------------- | -------- | ----------- |
| `distribution_id`  | *depends on operating system* | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `libvirt_networks` | `[]`                          | false    | List of parameter dictionaries for module [`jm1.libvirt.net_xml`][jm1-libvirt-net-xml] from collection [`jm1.libvirt`][galaxy-jm1-libvirt] [^libvirt-networks-parameter-acl] [^libvirt-networks-parameter-autostart] [^libvirt-networks-parameter-uri] [^libvirt-networks-parameter-xml] |
| `libvirt_uri`      | `qemu:///system`              | false    | [libvirt connection uri][libvirt-uri] |

[^libvirt-networks-parameter-acl]: Each list item in `libvirt_networks` can have an optional key `acl` which specifies
whether [unprivileged users do have access to bridges created by `qemu-bridge-helper` (implicitly invoked from libvirt
daemon)][qemu-acl]. Valid values for `acl` are `allow` and `deny`. If `acl` is present, then a line will be added to
`/etc/qemu/bridge.conf` or `/etc/qemu-kvm/bridge.conf` to allow or deny access to QEMU bridges for unprivileged users.
Details can be found in [`roles/libvirt_networks/tasks/main.yml`](tasks/main.yml). If `state` of a list item is `absent`
and key `acl` is present, then any line in `/etc/qemu/bridge.conf` or `/etc/qemu-kvm/bridge.conf` which lists the
libvirt network will be removed to revoke access to bridges for unprivileged users.

[^libvirt-networks-parameter-autostart]: If key `autostart` is present in a list item and it evaluates to `true`, then
module [`community.libvirt.virt_net`][community-libvirt-virt-net] from collection [`community.libvirt`][
galaxy-community-libvirt] will be used to mark that network to be started automatically when the libvirt daemon starts.

[^libvirt-networks-parameter-uri]: If a list item does not contain key `uri` then it will be initialized from Ansible
variables `libvirt_uri`.

[^libvirt-networks-parameter-xml]: If key `xml` is present in a list item, then it will be passed unchanged to
`jm1.libvirt.net_xml`. If `xml` is not present but `xml_file` is present in a list item, then the file path stored in
`xml_file` will be read with [Ansible's `lookup('template', item.xml_file)` plugin][template-lookup] and passed as
parameter `xml` to module `jm1.libvirt.net_xml`. If both `xml` and `xml_var` are not present in a list item but key
`xml_var` is, then the variable named by `xml_var` will be read with [Ansible's `lookup('vars', item.xml_var)` plugin][
vars-lookup] and passed as parameter `xml` to module `jm1.libvirt.net_xml`.

[qemu-acl]: https://wiki.qemu.org/Features/HelperNetworking
[libvirt-uri]: https://libvirt.org/uri.html
[template-lookup]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_lookup.html
[vars-lookup]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/vars_lookup.html

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  become: true # connection to system libvirt daemon requires root privileges
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

    # connect from Ansible controller to local libvirt daemon
    ansible_connection: local

    libvirt_networks:
    - acl: allow
      autostart: true
      xml: |
        <network>
          <name>nat</name>
          <bridge name="virbr-nat-0"/>
          <forward mode="nat"/>
          <ip address="192.168.123.1" netmask="255.255.255.0">
            <dhcp>
              <range start="192.168.123.100" end="192.168.123.254"/>
            </dhcp>
          </ip>
        </network>

  roles:
  - name: Setup libvirt virtual networks
    role: jm1.cloudy.libvirt_networks
    tags: ["jm1.cloudy.libvirt_networks"]
```

For complete examples on how to use this role, refer to hosts `lvrt-lcl-session` and `lvrt-lcl-system` from the provided
[examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
