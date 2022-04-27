# NOTE: to debug this builder:
#
#    $ cd step1   # or cd ~/proj/nxfs/step1
#    $ nix-shell
#    $ source builder.sh
#
# nix-shell runs nix expression for this directory, see ./default.nix

set -e
#set -x

source ${setup}   # see ./setup.sh

#display_phase

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
