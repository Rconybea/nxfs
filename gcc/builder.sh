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

# verify that /bin/sh exists
mkdir -p ${out}
file /bin/sh > ${out}/binshfile.txt
env > ${out}/build.env

display_phase
unpack_phase
patch_phase
configure_phase
compile_binutils
install_binutils
compile_gcc
install_gcc

# end builder.sh
