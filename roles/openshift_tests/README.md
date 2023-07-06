# Ansible Role `jm1.cloudy.openshift_tests`

This role helps with running [OpenShift's conformance test suite][ocp-tests] against [OpenShift clusters][ocp] and
[OKD clusters][okd].

First, [Podman][podman] will be installed because it will be used later to run the [OpenShift's conformance test suite][
ocp-tests] container. A directory, defined in variable `openshift_tests_artifact_dir`, will be created to store
artifacts such as logs and test results. When a [pull secret][using-image-pull-secrets] has been defined in variable
`openshift_tests_pullsecret`, then it will be written to file `openshift_tests_pullsecret_file`.

An archive containing the OpenShift Client aka `oc` will be downloaded from `openshift_tests_oc_url` and stored in
directory `openshift_tests_download_dir`. Its checksum will be compared to `openshift_tests_oc_checksum` to ensure its
integrity and then it will be extracted to `/usr/local/bin`. To aid debugging the version of `oc` will be printed
afterwards.

With OpenShift Client aka `oc` being available, it will be waited until:
- the number of nodes matches the number of machines,
- all nodes are ready, because the tests might require workload capacity, and
- clusteroperators have finished progressing to ensure that the configuration which had been specified at installation
  time has been achieved.

When the cluster is ready for testing, the image for OpenShift's conformance test suite will be read from the release
image defined in `openshift_tests_release_image`. Finally, the former container image will be used to run the test suite
defined in `openshift_tests_suite` in a [Podman][podman] container. Its output will be written to file `e2e.log` in
directory `openshift_tests_artifact_dir` and test results will be written to its subdirectory `junit`.

[ocp]: https://openshift.com/
[ocp-tests]: https://github.com/openshift/origin
[okd]: https://www.okd.io/
[podman]: https://podman.io/
[using-image-pull-secrets]: https://docs.openshift.com/container-platform/4.12/openshift_images/managing_images/using-image-pull-secrets.html

**Tested OS images**
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Cloud image of [`Debian 12 (Bookworm)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bookworm/)
- Generic cloud image of [`CentOS 8 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/8-stream/x86_64/images/)
- Generic cloud image of [`CentOS 9 (Stream)` \[`amd64`\]](https://cloud.centos.org/centos/9-stream/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 22.04 LTS (Jammy Jellyfish)` \[`amd64`\]](https://cloud-images.ubuntu.com/jammy/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

This role uses module(s) from collection [`jm1.pkg`][galaxy-jm1-pkg]. To install this collection you may follow the
steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][jm1-cloudy-requirements].

[galaxy-jm1-pkg]: https://galaxy.ansible.com/jm1/pkg
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                              | Default value                    | Required | Description |
| --------------------------------- | -------------------------------- | -------- | ----------- |
| `openshift_tests_artifact_dir`    | `~/tests`                        | false    | Directory where logs and test results will be stored. Defaults to `tests` in `ansible_user`'s home |
| `openshift_tests_download_dir`    | `~`                              | false    | Directory where OpenShift Client archive will be downloaded to. Defaults to `ansible_user`'s home |
| `openshift_tests_kubeconfig_file` | *undefined*                      | true     | Path to a [kubeconfig][kubeconfig] file which contains cluster details, certificates, authentication tokens etc. |
| `openshift_tests_oc_checksum`     | *undefined*                      | true     | Checksum of OpenShift Client archive, e.g. `'sha256:664362e82648a5727dce090ffd545103b9c037d18836527a1951f02b20c12725'` |
| `openshift_tests_oc_url`          | *undefined*                      | true     | URL to OpenShift Client archive, e.g. `'https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.12.4/openshift-client-linux-4.12.4.tar.gz'` |
| `openshift_tests_pullsecret`      | *undefined*                      | false    | [Pull secret][using-image-pull-secrets] downloaded from [Red Hat Cloud Console][rh-console-ipi] which will be used to authenticate with Container registries `Quay.io` and `registry.redhat.io`, which serve the container images for OpenShift Container Platform components. A pull secret is required for OpenShift deployments only, but not for OKD deployments. |
| `openshift_tests_pullsecret_file` | `~/pull-secret.txt`              | false    | Path to pull secret file |
| `openshift_tests_release_image`   | *undefined*                      | true     | Container image from which `openstack-install` will be extracted, e.g. `'registry.ci.openshift.org/origin/release-scos:scos-4.12'` |
| `openshift_tests_suite`           | `openshift/conformance/parallel` | false    | The test suite to run.  Use `openshift-tests run --help` to list available suites. [Defaults to OpenShift CI's default test suite][ocp-e2e-test-step] |

[kubeconfig]: https://www.redhat.com/sysadmin/kubeconfig
[rh-console-ipi]: https://console.redhat.com/openshift/install/metal/installer-provisioned
[ocp-e2e-test-step]: https://steps.ci.openshift.org/reference/openshift-e2e-test

## Dependencies

| Name                | Description |
| ------------------- | ----------- |
| `jm1.pkg.setup`     | Installs necessary software for module `jm1.pkg.meta_pkg` from collection `jm1.pkg`. This role is called automatically, manual execution is *NOT* required. |

[Podman][podman] is required to run [OpenShift's conformance test suite][ocp-tests] container but it will be installed
automatically upfront.

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