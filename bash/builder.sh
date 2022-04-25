# NOTE: to debug this builder:
#
#    $ cd path/to/nxfs
#    $ nix-shell -A bash_lfsd_stage1
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

display_phase
unpack_phase
patch_phase
compile_phase
install_phase

# end builder.sh
