# Ansible Role `jm1.cloudy.openshift_client`

This role helps with downloading and installing [OpenShift Client aka `oc`][ocp-oc]. OpenShift Client is based on
[kubectl][kubectl] and allows to manage [OpenShift][ocp], [OKD][okd] as well as Kubernetes resources and applications.

First, an archive containing the OpenShift Client aka `oc` will be downloaded from `openshift_client_url` to a temporary
directory. Its checksum will be compared to `openshift_client_checksum` to ensure its integrity. The `oc` binary will
then be extracted to `openshift_client_install_dir` which defaults to `/usr/local/bin`. Finally, the version of `oc`
will be printed to aid debugging.

[kubectl]: https://kubernetes.io/docs/reference/kubectl/
[ocp]: https://openshift.com/
[ocp-oc]: https://github.com/openshift/oc
[okd]: https://www.okd.io/

**Tested OS images**
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/buster/daily/) of Debian 10 (Buster)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bullseye/daily/) of Debian 11 (Bullseye)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bookworm/daily/) of Debian 12 (Bookworm)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/trixie/daily/) of Debian 13 (Trixie)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/7/images/) of CentOS 7 (Core)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/8-stream/x86_64/images/) of CentOS 8 (Stream)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/9-stream/x86_64/images/) of CentOS 9 (Stream)
- [Cloud image (`amd64`)](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/) of Fedora Cloud Base 40
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/bionic/current/) of Ubuntu 18.04 LTS (Bionic Beaver)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/focal/) of Ubuntu 20.04 LTS (Focal Fossa)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/jammy/) of Ubuntu 22.04 LTS (Jammy Jellyfish)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/noble/) of Ubuntu 24.04 LTS (Noble Numbat)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

None.

## Variables

| Name                           | Default value     | Required | Description |
| ------------------------------ | ----------------- | -------- | ----------- |
| `openshift_client_checksum`    | *undefined*       | true     | Checksum of OpenShift Client archive, e.g. `'sha256:59cfdc9161c4d86ad1d0fe8789ae4c28aba64f2bbdf1cf748747694b54ff005b'` |
| `openshift_client_install_dir` | `/usr/local/bin/` | false    | Directory where OpenShift Client will be installed to. |
| `openshift_client_url`         | *undefined*       | true     | URL to OpenShift Client archive, e.g. `'https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.13.7/openshift-client-linux-4.13.7.tar.gz'` |

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  become: true
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    openshift_client_checksum: 'sha256:59cfdc9161c4d86ad1d0fe8789ae4c28aba64f2bbdf1cf748747694b54ff005b'
    openshift_client_url: 'https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.13.7/openshift-client-linux-4.13.7.tar.gz'

  roles:
  - name: Install OpenShift Client
    role: jm1.cloudy.openshift_client
    tags: ["jm1.cloudy.openshift_client"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
