#!/bin/sh
# vim:set tabstop=8 shiftwidth=4 expandtab:
# kate: space-indent on; indent-width 4;
#
# Copyright (c) 2022-2023 Jakob Meng, <jakobmeng@web.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# NOTE: declare local variables first and initialize them later because return code of "local ..." is always 0

set -eu

# Environment variables
DEBUG=${DEBUG:=no}
DEBUG_SHELL=${DEBUG_SHELL:=no}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-}

if [ "$DEBUG" = "yes" ] || [ "$DEBUG" = "true" ]; then
    set -x
fi

error() {
    echo "ERROR: $*" 1>&2
}

warn() {
    echo "WARNING: $*" 1>&2
}

if [ "$(id -u)" -ne 0 ]; then
    error "Please run as root"
    exit 125
fi

# kill process group including child processes such as libvirtd
# shellcheck disable=SC2064
trap "trap - TERM && kill -- -$$" INT TERM EXIT

(
    set -eu

    if [ "$DEBUG" = "yes" ] || [ "$DEBUG" = "true" ]; then
        set -x
    fi

    # Ensure user cloudy has full access to mounted directories
    chown -v cloudy.cloudy /home/cloudy/.local/share/libvirt/images/ /home/cloudy/.ssh/

    # Ansible requires SSH keys to be able to connect to virtual machines
    sudo -u cloudy --set-home sh -c '[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'

    # Ansible uses SSH agent forwarding for accessing nested virtual machines
    if [ -z "$SSH_AUTH_SOCK" ]; then
        # Using SSH_AUTH_SOCK instead of SSH_AGENT_PID
        # because ssh-agent is running on the container host
        eval "$(sudo -u cloudy --set-home ssh-agent)"
        sudo -u cloudy --set-home --preserve-env=SSH_AUTH_SOCK ssh-add
    fi

    cd /home/cloudy/project/

    if [ ! -e "ansible.cfg" ]; then
        error "ansible.cfg not found"
        exit 123
    fi

    [ -e "/usr/share/ansible/collections/ansible_collections/jm1/cloudy" ] \
        || sudo -u cloudy ansible-galaxy collection install jm1.cloudy

    # Sorted in ascending order of priority
    for dir in \
        "/usr/share/ansible/collections/ansible_collections/jm1/cloudy" \
        "/home/cloudy/.ansible/collections/ansible_collections/jm1/cloudy" \
        "/home/cloudy/project";
    do
        [ -e "$dir/playbooks/setup.yml" ] && playbook_setup="$dir/playbooks/setup.yml"
        [ -e "$dir/playbooks/site.yml" ] && playbook_site="$dir/playbooks/site.yml"
        [ -e "$dir/requirements.yml" ] && requirements="$dir/requirements.yml"
    done

    if [ -z "$playbook_setup" ]; then
        error "Ansible playbook setup.yml not found"
        exit 122
    fi

    if [ -z "$playbook_site" ]; then
        error "Ansible playbook site.yml not found"
        exit 121
    fi

    if [ -z "$requirements" ]; then
        error "Ansible Galaxy's requirements.yml not found"
        exit 120
    fi

    if ! python3 -c \
         "import ansible; import sys; from packaging import version;"\
         "sys.exit(0 if version.parse(ansible.release.__version__) >= version.parse('2.9') else 1);"
    then
        error "Ansible 2.9 or newer is required"
        exit 119
    fi

    # Use older Ansible collections for compatibility with older Ansible releases
    if python3 -c \
         "import ansible; import sys; from packaging import version;"\
         "sys.exit(0 if version.parse(ansible.release.__version__) < version.parse('2.11') else 1);"
    then
        sudo -u cloudy ansible-galaxy collection install 'community.general:<5.0.0'
    elif python3 -c \
         "import ansible; import sys; from packaging import version;"\
         "sys.exit(0 if version.parse(ansible.release.__version__) < version.parse('2.13') else 1);"
    then
        sudo -u cloudy ansible-galaxy collection install 'community.general:<8.0.0'
    fi

    sudo -u cloudy ansible-galaxy collection install --requirements-file "$requirements"
    sudo -u cloudy ansible-galaxy role install --role-file "$requirements"

    sudo -u cloudy --set-home \
        ansible-playbook "$playbook_setup" \
            --limit lvrt-lcl-system

    sudo -u cloudy --set-home \
        ansible-playbook "$playbook_site" \
            --limit lvrt-lcl-system \
            --skip-tags "jm1.kvm_nested_virtualization" \
            --skip-tags "jm1.cloudy.libvirt_pools" \
            --skip-tags "jm1.cloudy.libvirt_images" \
            --skip-tags "jm1.cloudy.libvirt_networks"

    # Change container's gid for group kvm to match host's gid
    # else cloudy will not have access to /dev/kvm
    if [ -e /dev/kvm ] && \
    [ "$(getent group kvm | cut -d: -f3)" != "$(stat -c '%g' /dev/kvm)" ]; then
        groupmod --gid "$(stat -c '%g' /dev/kvm)" kvm
    fi

    # Start libvirt system daemon
    (
        set -eu

        # Exit subshell if libvirtd is already running
        { pgrep --uid "$(id -u)" libvirtd && exit; } || true

        # Ref.: /lib/systemd/system/libvirtd.service

        # shellcheck disable=SC1091
        [ -e /etc/default/libvirtd ] && . /etc/default/libvirtd
        # shellcheck disable=SC1091
        [ -e /etc/sysconfig/libvirtd ] && . /etc/sysconfig/libvirtd

        # shellcheck disable=SC2086
        /usr/sbin/libvirtd --daemon ${LIBVIRTD_ARGS:-}
    )

    # Disable libvirt tls transport, enable unauthenticated libvirt tcp transport and bind
    # to all network interfaces for connectivity from container host and virtual machines.
    if [ ! -e /home/cloudy/.config/libvirt/libvirtd.conf ]; then
        sudo -u cloudy mkdir -p /home/cloudy/.config/libvirt/
        cp -av /etc/libvirt/libvirtd.conf /home/cloudy/.config/libvirt/libvirtd.conf
        chown cloudy.cloudy /home/cloudy/.config/libvirt/libvirtd.conf
        sed -i \
            -e 's/^[#]*listen_tls = .*/listen_tls = 0/g' \
            -e 's/^[#]*listen_tcp = .*/listen_tcp = 1/g' \
            -e 's/^[#]*listen_addr = .*/listen_addr = "0.0.0.0"/g' \
            -e 's/^[#]*auth_tcp = .*/auth_tcp = "none"/g' \
            /home/cloudy/.config/libvirt/libvirtd.conf
    fi

    sudo -u cloudy --set-home \
        ansible-playbook "$playbook_site" \
            --limit lvrt-lcl-system \
            --skip-tags "jm1.kvm_nested_virtualization"

    # Enable masquerading for internet connectivity from libvirt domains on networks route-0-dhcp and route-1-no-dhcp
    nft --file - << '____EOF'
    table ip nat {
        chain POSTROUTING {
            type nat hook postrouting priority srcnat

            meta l4proto tcp ip saddr 192.168.157.0/24 ip daddr != 192.168.157.0/24 masquerade to :1024-65535
            meta l4proto udp ip saddr 192.168.157.0/24 ip daddr != 192.168.157.0/24 masquerade to :1024-65535
            ip saddr 192.168.157.0/24 ip daddr != 192.168.157.0/24 masquerade

            meta l4proto tcp ip saddr 192.168.158.0/24 ip daddr != 192.168.158.0/24 masquerade to :1024-65535
            meta l4proto udp ip saddr 192.168.158.0/24 ip daddr != 192.168.158.0/24 masquerade to :1024-65535
            ip saddr 192.168.158.0/24 ip daddr != 192.168.158.0/24 masquerade
        }
    }
____EOF

    if ! groups cloudy | grep -q -w kvm; then
        sudo -u cloudy killall libvirtd || true
        usermod --append --groups kvm cloudy
    fi

    # Start libvirt session daemon
    sudo -u cloudy --set-home \
        sh -c 'pgrep --uid "$(id -u)" libvirtd || /usr/sbin/libvirtd --daemon --listen'

    sudo -u cloudy --set-home \
        ansible-playbook "$playbook_site" \
            --limit lvrt-lcl-session \
            --skip-tags "jm1.kvm_nested_virtualization"

    if [ $# -eq 0 ]; then
        sudo -u cloudy --set-home --preserve-env=SSH_AUTH_SOCK bash --login
    else
        sudo -u cloudy --set-home --preserve-env=SSH_AUTH_SOCK env -- "$@"

        # wait for libvirtd daemon
        tail "--pid=$(cat /var/run/libvirtd.pid)" -f /dev/null
    fi
)
# shellcheck disable=SC2181
# else 'set -e' in subshell is ignored
if [ $? -ne 0 ]; then
    if [ "$DEBUG_SHELL" = "yes" ] || [ "$DEBUG_SHELL" = "true" ]; then
        bash
        exit
    fi
    exit 255
fi
