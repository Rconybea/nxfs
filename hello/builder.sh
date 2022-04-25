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

display_phase
unpack_phase
patch_phase
configure_phase
compile_phase
install_phase

# end builder.sh
