# source this to enter nix environment for doing LFS work.
#

unset PATH
unset PKG_CONFIG_PATH

for p in ${buildInputs} ${baseInputs}; do
    if [[ -d ${p}/bin ]]; then
	PATH=${p}/bin${PATH:+:}${PATH}
    fi
    if [[ -d ${p}/lib/pkgconfig ]]; then
	PKG_CONFIG_PATH="${p}/lib/pkgconfig${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
    fi
done

export PATH PKG_CONFIG_PATH

LC_ALL=POSIX

LFS=${lfs_mount}
LFS_TOOLS=${LFS}/tools
LFS_TGT=$(uname -m)${lfs_target_suffix}

CONFIG_SITE=${LFS}/usr/share/config.site

export LC_ALL LFS LFS_TOOLS LFS_TGT

home=$(pwd)

function display_phase() {
    self=display_phase
    >&2 echo "${self}: home=${home}"
    >&2 echo "${self}: LFS=${LFS}"
    >&2 echo "${self}: LFS_TGT=${LFS_TGT}"
    >&2 echo "${self}: src=${src}"
    >&2 echo "${self}: out=${out}"
    >&2 echo "${self}: PATH=${PATH}"
    >&2 echo "${self}: PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
    >&2 echo "${self}: buildInputs=${buildInputs}"
    >&2 echo "${self}: file=$(which file)"
} # ..display_phase

function unpack_phase() {
    >&2 echo "unpack_phase: curdir=$(pwd)"

    pushd ${home}

    tar -xf ${src}

    popd
} # ..unpack_phase

# patch_phase: must follow unpack_phase,
#              curdir must be in directory created by unpacking tarball
#
function patch_phase() {
    pushd ${home}/${vsubdir}

    # need to replace hardcoded /usr/bin/file with nix store path /nix/store/$hash/bin/file
    file=$(which file)

    sed -i -e "s:/usr/bin/file:${file}:g" ./configure 

    # need symlink to attr headers where configure can find it
    #ln -s ${attrDevDir}/include/attr

    popd
} # ..patch_phase

function configure_phase() {
    pushd ${home}/${vsubdir}

    #echo "home=${home}"
    #CPPFLAGS="-I${attrDevDir}/include" ./configure --prefix=${out}
    mkdir -v build
    cd build
    ../configure --prefix=${LFS_TOOLS} --target=${LFS_TGT} 

    popd
} # ..configure_phase

function compile_phase() {
   pushd ${home}/${vsubdir}/build

   make
   #echo "compile_phase: pwd=$(pwd):"
   #ls $(pwd)

   popd
} # ..compile_phase

function install_phase() {
    #echo "home=${home}"

    pushd ${home}/${vsubdir}

    # rsync:
    #   -l: preserve symlinks
    #   -r: recursive
    #   -p: preserve permissions
    #   -v: verbose
    mkdir ${out}
    cd ..
    rsync -lrpv . ${out}/

    popd
} # ..install_phase

# to run:
#   $ cd binutils
#   $ nix-shell
#   $ source setup.sh
#   $ final_install_phase
#
function final_install_phase() {
    pushd ${home}
    make -C ./result/${vsubdir}/build install
    popd
} # ..final_install_phase

function help() {
    echo "build sequence:"
    echo "$ display_phase"
    echo "$ unpack_phase"
    echo "$ patch_phase"
    echo "$ configure_phase"
    echo "$ compile_phase"
    echo "$ install_phase"
    echo "then from outside nix-build:"
    echo "$ final_install_phase"
EOF
}

# end setup.sh
