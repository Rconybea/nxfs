# source this to enter nix environment for doing LFS work.
# see ./default.nix
#
# in that file, attributes passed to mkDerivation appear here as environment variables:
#  name
#  args
#  setup
#  glibc_version
#  vsubdir
#  binutils_vsubdir
#  binutils_src
#  ...
#

unset PATH
unset PKG_CONFIG_PATH

# ${out}/bin:  in LFS,  this would be /mnt/lfs/tools/bin
#
PATH=$(pwd)/bin:${out}/bin

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

LFS=/mnt/lfs
LFS_TOOLS=${LFS}/tools
LFS_TGT=$(uname -m)-lfs-linux-gnu

CONFIG_SITE=${LFS}/usr/share/config.site

export LC_ALL LFS LFS_TOOLS LFS_TGT

#INSTALL_PREFIX=${LFS_TOOLS}  # install to /mnt/lfs/tools
if [[ ${lfsdirect} -eq 1 ]]; then
    # if installing to LFS directly,   then we need /mnt/lfs/tools/bin content to be in path,
    # in place of upstream nix dependencies
    #
    PATH=${LFS_TOOLS}/bin:${PATH}

    INSTALL_PREFIX=${LFS_TOOLS}
else
    INSTALL_PREFIX=${out}         # install to nix store
fi

# will put /bin/sh here.   Note that we need established build PATH before
# we use mkdir :)
#
# BTW we could just use /bin on nixos,  since then /bin contains only /bin/sh;
# however if running on non-nixos computer /bin may have other content, that we don't want in PATH
#
mkdir -p bin
(cd bin && ln -sf /bin/sh)

home=$(pwd)

function display_phase() {
    self=display_phase
    >&2 echo "${self}: home=${home}"
    >&2 echo "${self}: src=${binutils_src}"
    >&2 echo "${self}: out=${out}"
    >&2 echo "${self}: PATH=${PATH}"
    >&2 echo "${self}: PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
    >&2 echo "${self}: lfsdirect=${lfsdirect}"
    >&2 echo "${self}: buildInputs=${buildInputs}"
    >&2 echo "${self}: file=$(which file)"
    >&2 echo "${self}: /bin/sh=$(file /bin/sh)"
    >&2 echo "${self}: LFS=${LFS}"
    >&2 echo "${self}: file(\$LFS)=$(file ${LFS})"
} # ..display_phase

function unpack_phase() {
    >&2 echo "unpack_phase: curdir=$(pwd)"

    pushd ${home}

    # creates ${home}/${binutils_vsubdir}
    tar -xf ${binutils_src}

    popd
} # ..unpack_phase

# patch_phase: must follow unpack_phase,
#              curdir must be in directory created by unpacking tarball
#
function patch_phase() {
    >&2 echo "patch_phase: curdir=$(pwd)"

    # need to replace hardcoded /usr/bin/file with nix store path /nix/store/$hash/bin/file
    file=$(which file)

    pushd ${home}/${binutils_vsubdir}

    # binutils ships an outdated libtool copy.
    # it doesn't implement the sysroot feature,  which mean mistakenly links to libraries
    # from the host OS.
    #
    sed -i -e '6009s/$add_dir//' ./ltmain.sh

    sed -i -e "s:/usr/bin/file:${files}:g" ./*/configure

    popd
} # ..patch_phase

function configure_phase() {
    >&2 echo "configure_phase: curdir=$(pwd)"
    #echo "home=${home}"
    
    pushd ${home}/${binutils_vsubdir}

    mkdir -pv build
    cd build

    #
    # --prefix:       executables expect to run from this destination
    # --build:        infer configuration
    # --host:         target architeture name, e.g. x86_64-lfs-linux-gnu
    #
    ../configure \
	--prefix=/usr \
        --build=$(../config.guess) \
        --host=${LFS_TGT} \
	--disable-nls \
	--disable-werror \
        --enable-shared \
        --enable-64-bit-bfd

    popd
} # ..configure_phase

function compile_binutils() {
    >&2 echo "compile_binutils: curdir=$(pwd)"

    pushd ${home}/${binutils_vsubdir}/build
    make
    popd
} # ..compile_binutils

function install_binutils() {
    >&2 echo "install_binutils: curdir=$(pwd)"

    pushd ${home}/${binutils_vsubdir}/build

    if [[ ${lfsdirect} -eq 1 ]]; then
	make DESTDIR=${LFS} install

	# rsync:
	#   -l: preserve symlinks
	#   -r: recursive
	#   -p: preserve permissions
	#   -v: verbose
	#rsync -lrpv . ${out}/binutils
    else
	>&2 echo "install_binutils: TODO: implement for pure nix build"
	exit 1

	#mkdir -pv ${out}
	#make -C build install
    fi

    popd
} # ..install_binutils

function cleanup_phase() {
    pushd ${home}
    rm -rf bin
    rm -rf ${binutils_vsubdir}
    popd
} # ..cleanup_phase

function do_all_phases() {
    display_phase
    unpack_phase
    patch_phase
    configure_phase
    compile_binutils
    install_binutils
    cleanup_phase
} # ..do_all_phases

function help() {
    echo "build sequence:"
    echo "$ do_all_phases"
    echo "or:"
    echo "$ display_phase"
    echo "$ unpack_phase"
    echo "$ patch_phase"
    echo "$ configure_phase"
    echo "$ compile_binutils"
    echo "$ install_binutils"
    echo "$ cleanup_phase"
}

# end setup.sh
