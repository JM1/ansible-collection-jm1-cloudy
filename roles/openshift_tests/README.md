# Ansible Role `jm1.cloudy.openshift_tests`

This role helps with running [OpenShift's conformance test suite][ocp-tests] against [OpenShift clusters][ocp] and
[OKD clusters][okd].

First, [Podman][podman] will be installed because it will be used later to run the [OpenShift's conformance test suite][
ocp-tests] container. A directory, defined in variable `openshift_tests_artifact_dir`, will be created to store
artifacts such as logs and test results. When a [pull secret][using-image-pull-secrets] has been defined in variable
`openshift_tests_pullsecret`, then it will be written to file `openshift_tests_pullsecret_file`.

[OpenShift Client aka `oc`][ocp-oc] will wait until:
1. the number of nodes matches the number of machines,
2. all nodes are ready, because the tests might require workload capacity, and
3. [cluster operators][ocp-cluster-operators] have finished progressing to ensure that any outstanding configuration
   has been achieved.

When the cluster is ready for testing, the image for OpenShift's conformance test suite will be read from the release
image defined in `openshift_tests_release_image`. Finally, the former container image will be used to run the test suite
defined in `openshift_tests_suite` in a [Podman][podman] container. Its output will be written to file `e2e.log` in
directory `openshift_tests_artifact_dir` and test results will be written to its subdirectory `junit`.

[ocp]: https://openshift.com/
[ocp-cluster-operator]: https://docs.openshift.com/container-platform/4.13/operators/operator-reference.html
[ocp-tests]: https://github.com/openshift/origin
[okd]: https://www.okd.io/
[podman]: https://podman.io/
[using-image-pull-secrets]: https://docs.openshift.com/container-platform/4.13/openshift_images/managing_images/using-image-pull-secrets.html

**Tested OS images**
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS Stream 8` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS Stream 9` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

[OpenShift Client aka `oc`][ocp-oc] is required for waiting until the cluster is ready and for identifying the container
image which contains the `openshift-tests` binary. You may use role [`jm1.cloudy.openshift_client`](
../openshift_client/README.md) to install it.

[ocp-oc]: https://github.com/openshift/oc

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

[Podman][podman] is required to run [OpenShift's conformance test suite][ocp-tests] container but it will be installed
automatically upfront.

## Variables

| Name                              | Default value                    | Required | Description |
| --------------------------------- | -------------------------------- | -------- | ----------- |
| `openshift_tests_artifact_dir`    | `~/tests`                        | false    | Directory where logs and test results will be stored. Defaults to `tests` in `ansible_user`'s home |
| `openshift_tests_kubeconfig_file` | *undefined*                      | true     | Path to a [kubeconfig][kubeconfig] file which contains cluster details, certificates, authentication tokens etc. |
| `openshift_tests_pullsecret`      | *undefined*                      | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-ipi] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_tests_pullsecret_file` | `~/pull-secret.txt`              | false    | Path to pull secret file |
| `openshift_tests_release_image`   | *undefined*                      | true     | Container image from which `openstack-install` will be extracted, e.g. `'quay.io/okd/scos-release:4.13.0-0.okd-scos-2023-07-20-165025'` |
| `openshift_tests_suite`           | `openshift/conformance/parallel` | false    | The test suite to run.  Use `openshift-tests run --help` to list available suites. [Defaults to OpenShift CI's default test suite][ocp-e2e-test-step] |

[kubeconfig]: https://www.redhat.com/sysadmin/kubeconfig
[rh-console-ipi]: https://console.redhat.com/openshift/install/metal/installer-provisioned
[ocp-e2e-test-step]: https://steps.ci.openshift.org/reference/openshift-e2e-test

## Dependencies

| Name                | Description |
| ------------------- | ----------- |
| `jm1.pkg.setup`     | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

## Example Playbook

```yml
- hosts: all
  become: true
  roles:
  - name: Run OpenShift's conformance test suite
    role: jm1.cloudy.openshift_tests
    tags: ["jm1.cloudy.openshift_tests"]
```

For a complete example on how to use this role and `jm1.cloudy.openshift_ipi`, refer to hosts
`lvrt-lcl-session-srv-400-okd-ipi-router` up to `lvrt-lcl-session-srv-430-okd-ipi-provisioner` from the provided
[examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how these hosts can be
provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

If you want to run tests for OpenShift instead of OKD, download a [pull secret][using-image-pull-secrets] from [Red Hat
Cloud Console][rh-console-ipi]. It is required to authenticate with Container registries `Quay.io` and
`registry.redhat.io`, which serve the container images for OpenShift Container Platform components. Next, change the
following [`host_vars` of Ansible host `lvrt-lcl-session-srv-430-okd-ipi-provisioner`][provisioner-host-vars]:

```yml
openshift_tests_pullsecret: |
  {"auths":{"xxxxxxx": {"auth": "xxxxxx","email": "xxxxxx"}}}

# Or read pull secret from file ~/pull-secret.txt residing at the Ansible controller
#openshift_tests_pullsecret: |
#  {{ lookup('ansible.builtin.file', lookup('ansible.builtin.env', 'HOME') + '/pull-secret.txt') }}

openshift_tests_release_image: "{{ lookup('ansible.builtin.pipe', openshift_tests_release_image_query) }}"

openshift_tests_release_image_query: |
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
