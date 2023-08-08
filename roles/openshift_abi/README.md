# Ansible Role `jm1.cloudy.openshift_abi`

This role helps with running [OpenShift Agent-based Installer][ocp-abi] to create [OpenShift clusters][ocp] and
[OKD clusters][okd].

First, a directory for all installer related files such as `install-config.yaml`, `agent-config.yaml` and other
manifests for `openshift-install` will be created from variable `openshift_abi_config_dir`. Files insides this
directory such as `install-config.yaml` will be created from variable `openshift_abi_config` which defines a list of
tasks to be run by this role. Each task calls an Ansible module similar to tasks in roles or playbooks except that only
few [keywords][playbooks-keywords] such as `become` and `when` are supported.

When a [pull secret][using-image-pull-secrets] has been defined in variable `openshift_abi_pullsecret`, then it will be
written to file `openshift_abi_pullsecret_file`.

Next, the `openshift-install` binary will be extracted from container image defined in `openshift_abi_release_image` to
directory `openshift_abi_install_dir` which defaults to `/usr/local/bin`. To aid debugging, the version of
`openshift-install` will be printed.

Afterwards, `openshift-install` will generate the cluster manifests and the agent image for OpenShift Agent-based
Installer from the files in `openshift_abi_config_dir`. To boot all cluster nodes with the agent image, this role relies
on the tasks defined in `openshift_abi_boot_code`. The latter defines a list of tasks which will run by this role,
similar to variable `openshift_abi_config`, in order to insert the agent image as virtual media in each cluster node and
then reboot the node with the agent image.

The role will then wait, first, until the rendezvous host (bootstrap host) has been bootstrapped successfully and then,
second, until the cluster installation has been completed.

Finally, this role will execute all tasks defined in variable `openshift_abi_cleanup_code` which defines a list of tasks
to eject the agent image from all cluster nodes.

[ocp]: https://openshift.com/
[ocp-abi]: https://docs.openshift.com/container-platform/4.13/installing/installing_with_agent_based_installer/preparing-to-install-with-agent-based-installer.html
[okd]: https://www.okd.io/

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

[OpenShift Client aka `oc`][ocp-oc] is required for extracting `openshift-install` from the release image and managing
Kubernetes resources. You may use role [`jm1.cloudy.openshift_client`](../openshift_client/README.md) to install it.

Agent-based Installer, i.e. `openshift-install`, requires [nmstate][nmstate] during generating manifests when
`agent-config.yaml` has any host in `hosts` that defines a `networkConfig` entry. Debian 12 (Bookworm), Ubuntu 22.04 LTS
(Jammy Jellyfish) and older releases do not provide packages for [nmstate][nmstate], use CentOS 9 (Stream) instead.

[nmstate]: https://nmstate.io
[ocp-oc]: https://github.com/openshift/oc

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                            | Default value       | Required | Description |
| ------------------------------- | ------------------- | -------- | ----------- |
| `openshift_abi_boot_code`       | *undefined*         | true     | List of tasks to run in order to insert and boot the agent image on all cluster nodes [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_abi_cleanup_code`    | *undefined*         | true     | List of tasks to run in order to eject the agent image from all cluster nodes [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_abi_config`          | *undefined*         | true     | List of tasks to run in order to create `install-config.yaml`, `agent-config.yaml` and other manifests for `openshift-install` in `openshift_abi_config_dir` [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_abi_config_dir`      | `~/clusterconfigs`  | false    | Directory where `install-config.yaml`, `agent-config.yaml` and other manifests will be stored. Defaults to `clusterconfigs` in `ansible_user`'s home |
| `openshift_abi_install_dir`     | `/usr/local/bin`    | false    | Directory where `openshift-install` will be installed to |
| `openshift_abi_pullsecret`      | *undefined*         | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-abi] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_abi_pullsecret_file` | `~/pull-secret.txt` | false    | Path to pull secret file |
| `openshift_abi_release_image`   | *undefined*         | true     | Container image from which `openshift-install` will be extracted, e.g. `'quay.io/okd/scos-release:4.13.0-0.okd-scos-2023-07-20-165025'` |

[rh-console-abi]: https://console.redhat.com/openshift/install/metal/agent-based
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

None.

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Create an OpenShift cluster with Agent-based Installer
    role: jm1.cloudy.openshift_abi
    tags: ["jm1.cloudy.openshift_abi"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-500-okd-abi-ha-router` up to
`lvrt-lcl-session-srv-530-okd-abi-ha-provisioner` from the provided [examples inventory][inventory-example]. The
top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be provisioned with playbook
[`playbooks/site.yml`][playbook-site-yml].

If you want to deploy OpenShift instead of OKD, download a [pull secret][using-image-pull-secrets] from [Red Hat Cloud
Console][rh-console-abi]. It is required to authenticate with Container registries `Quay.io` and `registry.redhat.io`,
which serve the container images for OpenShift Container Platform components. Next, change the following [`host_vars` of
Ansible host `lvrt-lcl-session-srv-530-okd-abi-ha-provisioner`][provisioner-host-vars]:

```yml
openshift_abi_pullsecret: |
  {"auths":{"xxxxxxx": {"auth": "xxxxxx","email": "xxxxxx"}}}

# Or read pull secret from file ~/pull-secret.txt residing at the Ansible controller
#openshift_abi_pullsecret: |
#  {{ lookup('ansible.builtin.file', lookup('ansible.builtin.env', 'HOME') + '/pull-secret.txt') }}

openshift_abi_release_image: "{{ lookup('ansible.builtin.pipe', openshift_abi_release_image_query) }}"

openshift_abi_release_image_query: |
  curl -s https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-4.13/release.txt \
    | grep 'Pull From: quay.io' \
    | awk -F ' ' '{print $3}'
```

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml
[provisioner-host-vars]: ../../inventory/host_vars/lvrt-lcl-session-srv-530-okd-abi-ha-provisioner.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
