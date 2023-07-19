# Ansible Role `jm1.cloudy.kubernetes_resources`

This role helps with managing Kubernetes workloads and applications from Ansible variables. For example, it allows to
create, update and delete Kubernetes API objects such as `Deployment`, `ConfigMap`, `Secret`, `DaemonSet` and other
objects with [kubectl][kubectl] or [OpenShift Client aka `oc`][ocp-oc] or modules from Ansible collection
[kubernetes.core][galaxy-kubernetes-core].

[galaxy-kubernetes-core]: https://galaxy.ansible.com/kubernetes/core

Variable `kubernetes_resources_config` defines a list of tasks which will be run by this role. Each task calls an
Ansible module similar to tasks in roles or playbooks except that only few [keywords][playbooks-keywords] such as
`become` and `when` are supported.

For example, to deploy [Apache HTTP Server][httpd] aka `httpd` on a Kubernetes cluster, define variable
`kubernetes_resources_config` in [`group_vars` or `host_vars`][ansible-inventory] as such:

[kubectl]: https://kubernetes.io/docs/reference/kubectl/
[ocp-oc]: https://github.com/openshift/oc

```yml
kubernetes_resources_config:
- # Create a Kubernetes Deployment object for running Apache HTTP server
  kubernetes.core.k8s:
    definition:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: httpd-deployment
      spec:
        selector:
          matchLabels:
            app: httpd
        minReadySeconds: 5
        template:
          metadata:
            labels:
              app: httpd
          spec:
            containers:
            - name: httpd
              image: httpd:latest
              ports:
              - containerPort: 80
    state: present
    wait: true
```

This role will run all tasks listed in `kubernetes_resources_config`. Once all tasks have finished and if anything has
changed, then special task variable `handlers` will be evaluated for any changed tasks and all tasks defined in
`handlers` will be run.

**NOTE:** Ansible module [`kubernetes.core.k8s`][kubernetes-core-k8s] from collection [kubernetes.core][
galaxy-kubernetes-core] requires Python modules `jsonpatch`, `kubernetes` and `PyYAML` to be installed at the host that
executes the module. On Debian 11 (Bullseye), Debian 12 (Bookworm) and Ubuntu 22.04 LTS (Jammy Jellyfish) use
`apt install python3-jsonpatch python3-kubernetes python3-yaml` to install these modules. On CentOS 8 / 9 or Red Hat
Enterprise Linux (RHEL) 8 / 9 enable [EPEL][epel] and then run
`dnf install python3-jsonpatch python3-kubernetes python3-pyyaml`.

[ansible-inventory]: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
[epel]: https://fedoraproject.org/wiki/EPEL
[httpd]: https://httpd.apache.org/
[playbooks-keywords]: https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

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

This role uses module(s) from collection [`jm1.ansible`][galaxy-jm1-ansible]. To install this collection you may follow
the steps described in [`README.md`][jm1-cloudy-readme] using the provided [`requirements.yml`][
jm1-cloudy-requirements].

[galaxy-jm1-ansible]: https://galaxy.ansible.com/jm1/ansible
[jm1-cloudy-readme]: ../../README.md
[jm1-cloudy-requirements]: ../../requirements.yml

## Variables

| Name                          | Default value                  | Required | Description |
| ----------------------------- | ------------------------------ | -------- | ----------- |
| `kubernetes_resources_config` | `[]`                           | false    | List of tasks to run [^example-modules] [^supported-keywords] [^supported-modules], e.g. to declaratively manage Kubernetes workloads and applications with [kubectl][kubectl] or [OpenShift Client aka `oc`][ocp-oc] |

[^supported-modules]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports modules and action plugins only. Some Ansible modules such as [`ansible.builtin.meta`][ansible-builtin-meta]
and `ansible.builtin.{include,import}_{playbook,role,tasks}` are core features of Ansible, in fact not implemented as
modules and thus cannot be called from `jm1.ansible.execute_module`. Doing so causes Ansible to raise errors such as
`MODULE FAILURE\nSee stdout/stderr for the exact error`. (Only exception is [`meta: flush_handlers`][
ansible-builtin-meta] which is fully supported). In addition, Ansible does not support free-form parameters for
arbitrary modules, so for example, change from `- debug: msg=""` to `- debug: { msg: "" }`.

[^supported-keywords]: Tasks will be executed with [`jm1.ansible.execute_module`][jm1-ansible-execute-module] which
supports keywords `become`, `become_exe`, `become_flags`, `become_method`, `become_user`, `environment`, `when` and
special keyword `handlers` only. Task keyword `handlers` defines a list of handlers which will be notified and run when
a task has changed anything. Handlers will also be executed with [`jm1.ansible.execute_module`][
jm1-ansible-execute-module] and thus only keywords `become`, `become_exe`, `become_flags`, `become_method`,
`become_user`, `environment` and `when` are supported. **NOTE:** Keywords related to `become` will not inherit values
from the role's caller. For example, when `become` is defined in a playbook it will not be passed on to a task or
handler here.

[^example-modules]: Useful Ansible modules in this context could be [`blockinfile`][ansible-builtin-blockinfile],
[`command`][ansible-builtin-command], [`copy`][ansible-builtin-copy], [`file`][ansible-builtin-file], [`lineinfile`][
ansible-builtin-lineinfile], [`template`][ansible-builtin-template] and modules from Ansible collection
[kubernetes.core][galaxy-kubernetes-core] such as [`kubernetes.core.k8s`][kubernetes-core-k8s].

[ansible-builtin-blockinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html
[ansible-builtin-command]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html
[ansible-builtin-copy]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html
[ansible-builtin-file]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html
[ansible-builtin-lineinfile]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
[ansible-builtin-meta]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/meta_module.html
[ansible-builtin-template]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
[jm1-ansible-execute-module]: https://github.com/JM1/ansible-collection-jm1-ansible/blob/master/plugins/modules/execute_module.py
[kubernetes-core-k8s]: https://docs.ansible.com/ansible/latest/collections/kubernetes/core/k8s_module.html

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  roles:
  - name: Manage Kubernetes resources
    role: jm1.cloudy.kubernetes_resources
    tags: ["jm1.cloudy.kubernetes_resources"]
```

For a complete example on how to use this role, refer to host `lvrt-lcl-session-srv-430-okd-ipi-provisioner` from the
provided [examples inventory][inventory-example]. The top-level [`README.md`][jm1-cloudy-readme] describes how this host
can be provisioned with playbook [`playbooks/site.yml`][playbook-site-yml].

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
