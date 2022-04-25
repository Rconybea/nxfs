# build and install make to /mnt/lfs.
#
# Use:
#   path/to/nxfs/make/lfs-build.sh
#

self_dir=$(dirname ${BASH_SOURCE[0]})

echo "lfs-build: self_dir=[${self_dir}]"
pushd ${self_dir}/..
nix-shell -A patch_lfsd_stage1 --run "cd ${self_dir} && ./builder.sh"
popd

# end lfs-build.sh
