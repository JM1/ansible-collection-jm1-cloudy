# Ansible Role `jm1.cloudy.debconf`

This role helps with populating the [debconf][debconf-man] database from Ansible variables. It allows to insert new
values into the debconf database and to (re)configure packages with variable `debconf_config` which is defined as a list
where each list item is a dictionary of parameters that will be passed to Ansible's [debconf][ansible-module-debconf]
module. For example, to select time zone `UTC` on Debian or Ubuntu, define variable `debconf_config` in `group_vars` or
`host_vars` as such:

```yml
debconf_config:
- # select geographic area
  name: 'tzdata'
  question: 'tzdata/Areas'
  value: 'Etc'
  vtype: 'select'
- # select city or region corresponding to time zone
  name: 'tzdata'
  question: 'tzdata/Zones/Etc'
  value: 'UTC'
  vtype: 'select'
```

Once Ansible's [debconf][ansible-module-debconf] module has been called and if anything has changed (and if
`debconf_reconfigure` is true), then package `tzdata` will automatically be reconfigured with
[`dpkg-reconfigure`][dpkg-reconfigure-man].

:warning: **WARNING:**
> Only use this command to seed debconf values for packages that will be or are installed. Otherwise you can end up with
> values in the database for uninstalled packages that will not go away, or with worse problems involving shared values.
> It is recommended that this only be used to seed the database if the originating machine has an identical install.

Ref.: [`man debconf-set-selections`][debconf-set-selections-man]
:warning:

:warning: **WARNING:**
> Existing configurations such as those of openssh-server and unattended-upgrades cannot be changed using
> dpkg-reconfigure with noninteractive frontend. "It is by design of debconf that settings on the system take precedence
> over any values set in the debconf database. There is a valid use case for being able to preseed the set of modules
> that you want to install, but it is difficult to implement this while maintaining the requirement to respect any local
> changes to the config files.

Ref.: [bugs.launchpad.net][launchpad-bug-682662]

Same holds for the [postfix package][postfix-debconf].

For example, suppose that unattended-upgrades are disabled:

```sh
export DEBCONF_DEBUG=developer
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades
   debconf (developer): starting /var/lib/dpkg/info/unattended-upgrades.config reconfigure 2.8
   debconf (developer): <-- SET unattended-upgrades/enable_auto_updates false
   debconf (developer): --> 0 value set
   debconf (developer): <-- INPUT low unattended-upgrades/enable_auto_updates
   debconf (developer): --> 30 question skipped
   debconf (developer): <-- GO
   debconf (developer): --> 0 ok
   debconf (developer): starting /var/lib/dpkg/info/unattended-upgrades.postinst configure 2.8
   debconf (developer): <-- GET unattended-upgrades/enable_auto_updates
   debconf (developer): --> 0 false
   debconf (developer): <-- X_LOADTEMPLATEFILE /var/lib/dpkg/info/ucf.templates ucf
   debconf (developer): --> 0
   debconf (developer): <-- X_LOADTEMPLATEFILE /var/lib/dpkg/info/ucf.templates ucf
   debconf (developer): --> 0
```

When using dpkg-reconfigure with noninteractive frontend, debconf will load answers to debconf questions from
`/var/lib/dpkg/info/*.config` files which are scripts that generate debconf answers based on the actual system
configuration. With an interactive frontend, debconf would now show questions to users and allow them to change the
debconf answers. With noninteractive frontend, debconf will skip these questions (`30 question skipped`) and use the
answers from `/var/lib/dpkg/info/*.config` scripts based on the current configuration instead and then update answers
from the debconf database to these generated settings later (in `/var/lib/dpkg/info/*.postinst` scripts, not shown 
above). Workarounds using [`DEBCONF_DB_OVERRIDE`][debconf-db-override] do not work, so this won't help:

```sh
DEBCONF_DB_OVERRIDE='File {/var/cache/debconf/config.dat}' dpkg-reconfigure -f noninteractive unattended-upgrades
```
The only valid workaround with noninteractive frontend is to change config files directly and then call

```sh
dpkg-reconfigure -f noninteractive unattended-upgrades
```

to update the debconf database with the new values. Unfortunately how to change the configuration files depends
on the packages, details can be found in the `/var/lib/dpkg/info/*.postinst` scripts.
:warning:

[ansible-module-debconf]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debconf_module.html
[debconf-db-override]: https://github.com/zecrazytux/ansible-library-extra/issues/1#issuecomment-99636309
[debconf-man]: https://manpages.debian.org/stable/debconf-doc/debconf.7.de.html
[debconf-set-selections-man]: https://manpages.debian.org/bullseye/debconf/debconf-set-selections.1.en.html
[dpkg-reconfigure-man]: https://manpages.debian.org/stable/debconf/dpkg-reconfigure.8.en.html
[launchpad-bug-682662]: https://bugs.launchpad.net/ubuntu/+source/pam/+bug/682662/comments/1
[postfix-debconf]: https://serverfault.com/a/914012/373320

**Tested OS images**
- Cloud image of [`Debian 10 (Buster)` \[`amd64`\]](https://cdimage.debian.org/cdimage/openstack/current/)
- Cloud image of [`Debian 11 (Bullseye)` \[`amd64`\]](https://cdimage.debian.org/images/cloud/bullseye/latest/)
- Generic cloud image of [`CentOS 7 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/7/images/)
- Generic cloud image of [`CentOS 8 (Core)` \[`amd64`\]](https://cloud.centos.org/centos/8/x86_64/images/)
- Ubuntu cloud image of [`Ubuntu 18.04 LTS (Bionic Beaver)` \[`amd64`\]](https://cloud-images.ubuntu.com/bionic/current/)
- Ubuntu cloud image of [`Ubuntu 20.04 LTS (Focal Fossa)` \[`amd64`\]](https://cloud-images.ubuntu.com/focal/)

Available on Ansible Galaxy in Collection [jm1.cloudy](https://galaxy.ansible.com/jm1/cloudy).

## Requirements

None.

## Variables

| Name                  | Default value | Required | Description                               |
| --------------------- | ------------- | -------- | ----------------------------------------- |
| `debconf_config`      | `[]`          | no       | List of parameter dictionaries or a single parameter dictionary for Ansible's [debconf][ansible-module-debconf] module |
| `debconf_reconfigure` | `yes`         | no       | Run [`dpkg-reconfigure`][dpkg-reconfigure-man] once the debconf database has been updated                              |

## Dependencies

None.

## Example Playbook

```yml
- hosts: all
  vars:
    # Variables are listed here for convenience and illustration.
    # In a production setup, variables would be defined e.g. in
    # group_vars and/or host_vars of an Ansible inventory.
    # Ref.:
    # https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
    # https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
    debconf_config:
    - # select geographic area
      name: 'tzdata'
      question: 'tzdata/Areas'
      value: 'Etc'
      vtype: 'select'
    - # select city or region corresponding to time zone
      name: 'tzdata'
      question: 'tzdata/Zones/Etc'
      value: 'UTC'
      vtype: 'select'
  roles:
  - name: Change debconf database
    role: jm1.cloudy.debconf
    tags: ["jm1.cloudy.debconf"]
```

For instructions on how to run Ansible playbooks have look at Ansible's
[Getting Started Guide](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html).

## License

GNU General Public License v3.0 or later

See [LICENSE.md](../../LICENSE.md) to see the full text.

## Author

Jakob Meng
@jm1 ([github](https://github.com/jm1), [galaxy](https://galaxy.ansible.com/jm1), [web](http://www.jakobmeng.de))
