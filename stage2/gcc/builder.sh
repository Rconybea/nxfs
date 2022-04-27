# NOTE: to debug this builder:
#
#    $ cd path/to/nxfs
#    $ nix-shell -A gcc_lfsd_stage2
#    $ source setup.sh
#

set -e
#set -x

source ${setup}   # see ./setup.sh

display_phase

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
