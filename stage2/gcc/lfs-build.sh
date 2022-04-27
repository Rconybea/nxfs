# build and install gcc to /mnt/lfs.
#
# Use:
#   path/to/nxfs/stage2/gcc/lfs-build.sh
#

self_dir=$(dirname ${BASH_SOURCE[0]})

echo "lfs-build: self_dir=[${self_dir}]"
pushd ${self_dir}/..
nix-shell -A gcc_lfsd_stage2 --run "cd ${self_dir} && ./builder.sh"
popd



