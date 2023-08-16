# Ansible Role `jm1.cloudy.openshift_ipi`

This role helps with using [OpenShift Installer-provisioned installation (IPI)][ocp-ipi] or
[ODK Installer-provisioned installation (IPI)][okd-ipi] to create [OpenShift clusters][ocp] and [OKD clusters][okd].

First, a directory for all installer related files such as `install-config.yaml` and manifests will be created, defined
in variable `openshift_ipi_config_dir`. Files insides this directory such as `install-config.yaml` will be created from
variable `openshift_ipi_config` which defines a list of tasks to be run by this role. Each task calls an Ansible module
similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as `become` and `when`
are supported.

When a [pull secret][using-image-pull-secrets] has been defined in variable `openshift_ipi_pullsecret`, then it will be
written to file `openshift_ipi_pullsecret_file`.

Next, the `openshift-baremetal-install` binary will be extracted from container image defined in
`openshift_ipi_release_image` to directory `openshift_ipi_install_dir` which defaults to `/usr/local/bin`. To aid
debugging, the version of `openshift-baremetal-install` will be printed. Afterwards `openshift-baremetal-install` will
generate the manifests for OpenShift Installer-provisioned installation (IPI) from `install-config.yaml` and other
manifests and then create the cluster.

Finally the role will wait, first, until the cluster has been bootstrapped successfully and then, second, until the
cluster installation has been completed.

[ocp]: https://openshift.com/
[ocp-ipi]: https://docs.openshift.com/container-platform/4.13/installing/installing_bare_metal_ipi/ipi-install-overview.html
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

[OpenShift Client aka `oc`][ocp-oc] is required for extracting `openshift-baremetal-install` from the release image and
managing Kubernetes resources. You may use role [`jm1.cloudy.openshift_client`](../openshift_client/README.md) to
install it.

[ocp-oc]: https://github.com/openshift/oc

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible] and collection [`jm1.pkg`][galaxy-jm1-pkg].
To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided
[`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                            | Default value       | Required | Description |
| ------------------------------- | ------------------- | -------- | ----------- |
| `openshift_ipi_config`          | *undefined*         | true     | List of tasks to run in order to create `install-config.yaml` and other manifests for `openshift-baremetal-install` in `openshift_ipi_config_dir` [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_ipi_config_dir`      | `~/clusterconfigs`  | false    | Directory where `install-config.yaml` file will be created. Defaults to `clusterconfigs` in `ansible_user`'s home |
| `openshift_ipi_install_dir`     | `/usr/local/bin`    | false    | Directory where `openshift-baremetal-install` will be installed to |
| `openshift_ipi_pullsecret`      | *undefined*         | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-ipi] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_ipi_pullsecret_file` | `~/pull-secret.txt` | false    | Path to pull secret file |
| `openshift_ipi_release_image`   | *undefined*         | true     | Container image from which `openshift-baremetal-install` will be extracted, e.g. `'quay.io/okd/scos-release:4.13.0-0.okd-scos-2023-07-20-165025'` |

[rh-console-ipi]: https://console.redhat.com/openshift/install/metal/installer-provisioned
[using-image-pull-secrets]: https://docs.openshift.com/container-platform/4.13/openshift_images/managing_images/using-image-pull-secrets.html

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. In addition, Ansible does not support free-form parameters for
arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `become`, `become_exe`, `become_flags`, `become_method`, `become_user`, `environment` and `when` only.
**NOTE:** Keywords related to `become` will not inherit values from the role's caller. For example, when `become` is
defined in a playbook it will not be passed on to a task here.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`command`][ansible-builtin-command], [`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][
ansible-builtin-lineinfile] and [`template`][ansible-builtin-template].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-command]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py

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

# Or read pull secret from file ~/pull-secret.txt residing at the Ansible controller
#openshift_ipi_pullsecret: |
#  {{ lookup('ansible.builtin.file', lookup('ansible.builtin.env', 'HOME') + '/pull-secret.txt') }}

openshift_ipi_release_image: "{{ lookup('ansible.builtin.pipe', openshift_ipi_release_image_query) }}"

openshift_ipi_release_image_query: |
  curl -s https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-4.13/release.txt \
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
