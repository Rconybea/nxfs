# build and install binutils to /mnt/lfs/usr
#
# Use:
#   path/to/nxfs/stage2/binutils/lfs-build.sh
#

self_dir=$(dirname ${BASH_SOURCE[0]})

echo "lfs-build: self_dir=[${self_dir}]"
pushd ${self_dir}/..
nix-shell -A binutils_lfsd_stage2 --run "cd ${self_dir} && ./builder.sh"
popd



