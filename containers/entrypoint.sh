#!/bin/sh
# vim:set tabstop=8 shiftwidth=4 expandtab:
# kate: space-indent on; indent-width 4;
#
# Copyright (c) 2022 Jakob Meng, <jakobmeng@web.de>
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
DEBUG=${DEBUG:-}
DEBUG_SHELL=${DEBUG_SHELL:-}

if [ "$DEBUG" = "yes" ] || [ "$DEBUG" = "true" ]; then
    set -x
fi

stderr() {
    while read -r _msg
    do
        echo "$_msg" 1>&2
    done
}

error() {
    stderr << ____EOF
ERROR: $*
____EOF
}

warn() {
    stderr << ____EOF
WARN: $*
____EOF
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

    # Ansible requires SSH keys to be able to connect to virtual machines
    sudo -u cloudy --set-home sh -c '[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'

    cd /home/cloudy/project/

    if [ ! -e "ansible.cfg" ]; then
        error "ansible.cfg not found"
        exit 123
    fi

    sudo -u cloudy make install-requirements

    ansible-playbook -vvv playbooks/setup.yml

    sudo -u cloudy --set-home \
        ansible-playbook playbooks/site.yml \
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
        pgrep --uid "$(id -u)" libvirtd && exit || true

        # Ref.: /lib/systemd/system/libvirtd.service
        [ -e /etc/default/libvirtd ] && . /etc/default/libvirtd
        [ -e /etc/sysconfig/libvirtd ] && . /etc/sysconfig/libvirtd

        # shellcheck disable=SC2086
        /usr/sbin/libvirtd --daemon ${LIBVIRTD_ARGS:-}
    )

    sudo -u cloudy --set-home \
        ansible-playbook playbooks/site.yml \
            --limit lvrt-lcl-system \
            --skip-tags "jm1.kvm_nested_virtualization" \

    if [ -z "$(groups cloudy | grep -w kvm)" ]; then
        sudo -u cloudy killall libvirtd || true
        usermod --append --groups kvm cloudy
    fi

    # Start libvirt session daemon
    sudo -u cloudy --set-home \
        sh -c 'pgrep --uid "$(id -u)" libvirtd || /usr/sbin/libvirtd --daemon'

    sudo -u cloudy --set-home \
        ansible-playbook playbooks/site.yml \
            --limit lvrt-lcl-session \
            --skip-tags "jm1.kvm_nested_virtualization"

    if [ $# -eq 0 ]; then
        sudo -u cloudy --set-home bash --login
    else
        sudo -u cloudy --set-home env -- "$@"

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
