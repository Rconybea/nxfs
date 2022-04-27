# build and install xz to /mnt/lfs.
#
# Use:
#   path/to/nxfs/xz/lfs-build.sh
#

self_dir=$(dirname ${BASH_SOURCE[0]})

echo "lfs-build: self_dir=[${self_dir}]"
pushd ${self_dir}/..
nix-shell -A xz_lfsd_stage1 --run "cd ${self_dir} && ./builder.sh"
popd

# end lfs-build.sh
