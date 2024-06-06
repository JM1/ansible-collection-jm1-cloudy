# Ansible Role `jm1.cloudy.openshift_sno`

This role helps with provisioning [single-node][ocp-sno] [OpenShift clusters][ocp] and [single-node][ocp-sno]
[OKD clusters][okd].


First, this role will install tools such as [curl][curl], [jq][jq], [Podman][podman] and [PyYAML][pyyaml] which will be
used to identify, download and patch the live image for installing the single-node cluster.

When dependencies have been satisfied, a directory for all configuration files such as `install-config.yaml` and other
manifests for `openshift-install` will be created from variable `openshift_sno_config_dir`. Files insides this directory
such as `install-config.yaml` will be created from variable `openshift_sno_config` which defines a list of tasks to be
run by this role. Each task calls an Ansible module similar to tasks in roles or playbooks except that only few
[keywords][playbooks-keywords] such as `become` and `when` are supported.

When a [pull secret][using-image-pull-secrets] has been defined in variable `openshift_sno_pullsecret`, then it will be
written to file `openshift_sno_pullsecret_file`.

Next, the `openshift-install` binary will be extracted from container image defined in `openshift_sno_release_image` to
directory `openshift_sno_install_dir` which defaults to `/usr/local/bin`. To aid debugging, the version of
`openshift-install` will be printed.

Afterwards, `openshift-install` will be queried for the CoreOS live image which will be used to boot and install the
single-node cluster. The image will be downloaded to `openshift_sno_config_dir`. `openshift-install` will also generate
the single-node [Ignition][ignition] config `bootstrap-in-place-for-live-iso.ign` from the files in
`openshift_sno_config_dir`. The Ignition config file will be embedded into the live image using [CoreOS Installer][
coreos-installer] which will be run inside a [Podman][podman] container. The resulting live image will be stored as
`coreos-live-sno-installer.iso` in `openshift_sno_config_dir`.

To boot and install the single-node cluster with the live image, this role relies on the tasks defined in
`openshift_sno_boot_code`. The latter defines a list of tasks which will run by this role, similar to variable
`openshift_sno_config`, in order to insert the live image as virtual media in the cluster node and then (re)boot the
node with the live image.

Next, the role will then wait until:
1. the single-node OpenShift installation has been completed,
2. the number of nodes matches the number of machines,
3. all nodes are ready, because follow-up roles might require workload capacity, and
4. [cluster operators][ocp-cluster-operators] have finished progressing to ensure that the configuration which had been
   specified at installation time has been achieved.

Finally, this role will execute all tasks defined in variable `openshift_sno_cleanup_code` which defines a list of tasks
to eject the live image from the single-node cluster.

[coreos-installer]: https://coreos.github.io/coreos-installer/
[curl]: https://curl.se/
[ignition]: https://coreos.github.io/ignition/
[jq]: https://jqlang.github.io/jq/
[ocp]: https://openshift.com/
[ocp-cluster-operator]: https://docs.openshift.com/container-platform/4.13/operators/operator-reference.html
[ocp-sno]: https://docs.openshift.com/container-platform/4.13/installing/installing_sno/install-sno-preparing-to-install-sno.html
[okd]: https://www.okd.io/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html
[podman]: https://podman.io/
[pyyaml]: https://pyyaml.org/

**Tested OS images**
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bullseye/daily/) of Debian 11 (Bullseye)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/bookworm/daily/) of Debian 12 (Bookworm)
- [Cloud image (`amd64`)](https://cdimage.debian.org/images/cloud/trixie/daily/) of Debian 13 (Trixie)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/8-stream/x86_64/images/) of CentOS 8 (Stream)
- [Cloud image (`amd64`)](https://cloud.centos.org/centos/9-stream/x86_64/images/) of CentOS 9 (Stream)
- [Cloud image (`amd64`)](https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/) of Fedora Cloud Base 40
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/jammy/) of Ubuntu 22.04 LTS (Jammy Jellyfish)
- [Cloud image (`amd64`)](https://cloud-images.ubuntu.com/noble/) of Ubuntu 24.04 LTS (Noble Numbat)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

[OpenShift Client aka `oc`][ocp-oc] is required for extracting `openshift-install` from the release image and managing
Kubernetes resources. You may use role [`jm1.cloudy.openshift_client`](../openshift_client/README.md) to install it.

[ocp-oc]: https://github.com/openshift/oc

[curl][curl], [jq][jq], [Podman][podman] and [PyYAML][pyyaml] are required to identify, download and patch the live
image for installing the single-node cluster but these tools will be installed automatically upfront.

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible] and collection [`jm1.pkg`][galaxy-jm1-pkg].
To install these collections you may follow the steps described in [`README.md`][jm1-cloudy-readme] using the provided
[`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                            | Default value                  | Required | Description |
| ------------------------------- | ------------------------------ | -------- | ----------- |
| `distribution_id`               | *depends on operating system*  | false    | List which uniquely identifies a distribution release, e.g. `[ 'Debian', '10' ]` for `Debian 10 (Buster)` |
| `openshift_sno_boot_code`       | *undefined*                    | true     | List of tasks to run in order to insert and boot the live image on the single-node cluster [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_sno_cleanup_code`    | *undefined*                    | true     | List of tasks to run in order to eject the live image from the single-node cluster [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_sno_config`          | *undefined*                    | true     | List of tasks to run in order to create `install-config.yaml` and other manifests for `openshift-install` in `openshift_sno_config_dir` [^example-modules] [^supported-keywords] [^supported-modules] |
| `openshift_sno_config_dir`      | `~/clusterconfigs`             | false    | Directory where `install-config.yaml` and other manifests will be stored. Defaults to `clusterconfigs` in `ansible_user`'s home |
| `openshift_sno_install_dir`     | `/usr/local/bin`               | false    | Directory where `openshift-install` will be installed to |
| `openshift_sno_pullsecret`      | *undefined*                    | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-pull-secret] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_sno_pullsecret_file` | `~/pull-secret.txt`            | false    | Path to pull secret file |
| `openshift_sno_release_image`   | *undefined*                    | true     | Container image from which `openshift-install` will be extracted, e.g. `'quay.io/okd/scos-release:4.13.0-0.okd-scos-2023-07-20-165025'` |

[rh-console-pull-secret]: https://console.redhat.com/openshift/install/pull-secret
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
| `jm1.pkg.setup`     | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Create a single-node OpenShift cluster
    role: jm1.cloudy.openshift_sno
    tags: ["jm1.cloudy.openshift_sno"]
```

For a complete example on how to use this role, refer to hosts `lvrt-lcl-session-srv-700-okd-sno-router` up to
`lvrt-lcl-session-srv-730-okd-sno-provisioner` from the provided [examples inventory][inventory-example]. The
top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be provisioned with playbook
[`playbooks/site.yml`][playbook-site-yml].

If you want to deploy OpenShift instead of OKD, download a [pull secret][using-image-pull-secrets] from [Red Hat Cloud
Console][rh-console-pull-secret]. It is required to authenticate with Container registries `Quay.io` and
`registry.redhat.io`, which serve the container images for OpenShift Container Platform components. Next, change the
following [`host_vars` of Ansible host `lvrt-lcl-session-srv-730-okd-sno-provisioner`][provisioner-host-vars]:

```yml
openshift_sno_pullsecret: |
  {"auths":{"xxxxxxx": {"auth": "xxxxxx","email": "xxxxxx"}}}

# Or read pull secret from file ~/pull-secret.txt residing at the Ansible controller
#openshift_sno_pullsecret: |
#  {{ lookup('ansible.builtin.file', lookup('ansible.builtin.env', 'HOME') + '/pull-secret.txt') }}

openshift_sno_release_image: "{{ lookup('ansible.builtin.pipe', openshift_sno_release_image_query) }}"

openshift_sno_release_image_query: |
  curl -s https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/stable-4.13/release.txt \
    | grep 'Pull From: quay.io' \
    | awk -F ' ' '{print $3}'
```

[inventory-example]: ../../inventory/
[playbook-site-yml]: ../../playbooks/site.yml
[provisioner-host-vars]: ../../inventory/host_vars/lvrt-lcl-session-srv-730-okd-sno-provisioner.yml

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
