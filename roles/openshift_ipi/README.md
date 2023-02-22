# Ansible Role `jm1.cloudy.openshift_ipi`

This role helps with using [OpenShift Installer-provisioned installation (IPI)][ocp-ipi] or
[ODK Installer-provisioned installation (IPI)][okd-ipi] to create [OpenShift clusters][ocp] and [OKD clusters][okd].

First, a directory for all installer related files such as `install-config.yaml` and manifests will be created, defined
in variable `openshift_ipi_config_dir`. Insides this directory a file `install-config.yaml` for `openshift-install`
will be created and filled with contents from variable `openshift_ipi_config`. When a [pull secret][
using-image-pull-secrets] has been defined in variable `openshift_ipi_pullsecret`, then it will be written to file
`openshift_ipi_pullsecret_file`.

Next, an archive containing the OpenShift Client aka `oc` will be downloaded from `openshift_ipi_oc_url` and stored in
directory `openshift_ipi_download_dir`. Its checksum will be compared to `openshift_ipi_oc_checksum` to ensure its
integrity and then it will be extracted to `/usr/local/bin`.

With OpenShift Client aka `oc` and the container image defined in `openshift_ipi_release_image` the `openshift-install`
binary will be extracted to `/usr/local/bin`. To aid debugging the versions of `oc` and `openshift-install` will be
printed afterwards.

Finally, `openshift-install` will generate the manifests for OpenShift Installer-provisioned installation (IPI) from
`install-config.yaml` and then create the cluster.

[ocp]: https://openshift.com/
[ocp-ipi]: https://docs.openshift.com/container-platform/4.12/installing/installing_bare_metal_ipi/ipi-install-overview.html
[okd]: https://www.okd.io/
[okd-ipi]: https://docs.okd.io/latest/installing/installing_bare_metal_ipi/ipi-install-overview.html

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                            | Default value       | Required | Description |
| ------------------------------- | ------------------- | -------- | ----------- |
| `openshift_ipi_config`          | *undefined*         | true     | Contents of `install-config.yaml` file for `openshift-install` |
| `openshift_ipi_config_dir`      | `~/clusterconfigs`  | false    | Directory where `install-config.yaml` file will be created. Defaults to `clusterconfigs` in `ansible_user`'s home |
| `openshift_ipi_download_dir`    | `~`                 | false    | Directory where OpenShift Client archive will be downloaded to. Defaults to `ansible_user`'s home |
| `openshift_ipi_oc_checksum`     | *undefined*         | true     | Checksum of OpenShift Client archive, e.g. `'sha256:664362e82648a5727dce090ffd545103b9c037d18836527a1951f02b20c12725'` |
| `openshift_ipi_oc_url`          | *undefined*         | true     | URL to OpenShift Client archive, e.g. `'https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.12.4/openshift-client-linux-4.12.4.tar.gz'` |
| `openshift_ipi_pullsecret`      | *undefined*         | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-ipi] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_ipi_pullsecret_file` | `~/pull-secret.txt` | false    | Path to pull secret file |
| `openshift_ipi_release_image`   | *undefined*         | true     | Container image from which `openstack-install` will be extracted, e.g. `'registry.ci.openshift.org/origin/release-scos:scos-4.12'` |

[rh-console-ipi]: https://console.redhat.com/openshift/install/metal/installer-provisioned
[using-image-pull-secrets]: https://docs.openshift.com/container-platform/4.12/openshift_images/managing_images/using-image-pull-secrets.html

## Dependencies

| Name                | Description |
| ------------------- | ----------- |
| `jm1.libvirt.setup` | Installs `libvirtd` service which will be used to launch [IPI's bootstrap virtual machine][ocp-ipi]. This role is optional. |
| `jm1.pkg.setup`     | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

[OpenShift Installer-provisioned installation (IPI)][ocp-ipi] uses [libvirt][libvirt] (esp. [`libvirtd`][libvirtd]) to
[launch a bootstrap virtual machine][ipi-install-overview]. You can use role `jm1.libvirt.setup` from collection
[`jm1.libvirt`][galaxy-jm1-libvirt] to install necessary software packages.

[galaxy-jm1-libvirt]: https://galaxy.ansible.com/jm1/libvirt
[libvirt]: https://libvirt.org/
[libvirtd]: https://www.libvirt.org/manpages/libvirtd.html

## Example Playbook

```yml
- hosts: all
  become: true
  roles:
  - name: Create an OpenShift cluster with Installer-provisioned installation (IPI)
    role: jm1.cloudy.openshift_ipi
    tags: ["jm1.cloudy.openshift_ipi"]
```

For a complete example on how to use this role and `jm1.libvirt.setup`, refer to hosts
`lvrt-lcl-session-srv-400-okd-ipi-router` up to `lvrt-lcl-session-srv-430-okd-ipi-provisioner` from the provided
[examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

If you want to deploy OpenShift instead of OKD, download a [pull secret][using-image-pull-secrets] from [Red Hat Cloud
Console][rh-console-ipi]. It is required to authenticate with Container registries `Quay.io` and `registry.redhat.io`,
which serve the container images for OpenShift Container Platform components. Next, change the following [`host_vars` of
Ansible host `lvrt-lcl-session-srv-430-okd-ipi-provisioner`][provisioner-host-vars]:

```yml
openshift_ipi_pullsecret: |
  {"auths":{"xxxxxxx": {"auth": "xxxxxx","email": "xxxxxx"}}}

openshift_ipi_release_image: "{{ lookup('ansible.builtin.pipe', openshift_ipi_release_image_query) }}"

openshift_ipi_release_image_query: |
  curl -s https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-4.12/release.txt \
    | grep 'Pull From: quay.io' \
    | awk -F ' ' '{print $3}'
```

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml
[provisioner-host-vars]: ../../inventory/host_vars/lvrt-lcl-session-srv-430-okd-ipi-provisioner.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))