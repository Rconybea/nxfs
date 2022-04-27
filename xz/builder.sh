# NOTE: to debug this builder:
#
#    $ cd path/to/nxfs
#    $ nix-shell -A xz_lfsd_stage1
#    $ source builder.sh
#
# nix-shell runs nix expression for this directory, see ./default.nix

set -e
#set -x

source ${setup}   # see ./setup.sh

if [[ ${lfsdirect} -eq 1 ]]; then
    :
else
    # verify that /bin/sh exists
    mkdir -p ${out}
    file /bin/sh > ${out}/binshfile.txt
    env > ${out}/build.env
fi

do_all_phases

# end builder.sh
