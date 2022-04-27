# source this to enter nix environment for doing LFS work.
# see ./default.nix
#
# in that file, attributes passed to mkDerivation appear here as environment variables:
#  name
#  args
#  setup
#  glibc_version
#  binutils_vsubdir
#  binutils_src
#  mpfr_vsubdir
#  ...
#

unset PATH
unset PKG_CONFIG_PATH

# ${out}/bin:  in LFS,  this would be /mnt/lfs/tools/bin
#
PATH=$(pwd)/bin:${out}/bin

# for packages listed as input dependencies (in ./default.nix),
# make sure corresponding binaries are in $PATH, $PKG_CONFIG.
#
# ^ deps that appear later intercept earlier-listed deps
#
for p in ${baseInputs} ${buildInputs}; do
    if [[ -d ${p}/bin ]]; then
	PATH=${p}/bin${PATH:+:}${PATH}
    fi
    if [[ -d ${p}/lib/pkgconfig ]]; then
	PKG_CONFIG_PATH="${p}/lib/pkgconfig${PKG_CONFIG_PATH:+:}${PKG_CONFIG_PATH}"
    fi
done

export PKG_CONFIG_PATH

LC_ALL=POSIX

LFS=/mnt/lfs
LFS_TOOLS=${LFS}/tools
LFS_TGT=$(uname -m)-lfs-linux-gnu

CONFIG_SITE=${LFS}/usr/share/config.site

export LC_ALL LFS LFS_TOOLS LFS_TGT

#INSTALL_PREFIX=${LFS}        # install to /mnt/lfs (note: not LFS_TOOLS.  Differs from gcc)
if [[ ${lfsdirect} -eq 1 ]]; then
    INSTALL_PREFIX=${LFS}

    PATH=${LFS_TOOLS}/bin:${PATH}
else
    INSTALL_PREFIX=${out}         # install to nix store
fi

export PATH

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
    >&2 echo "${self}: src=${glibc_src}"
    >&2 echo "${self}: out=${out}"
    >&2 echo "${self}: linux_lfsx_stage1=${linux_lfsx_stage1}"
    >&2 echo "${self}: PATH=${PATH}"
    >&2 echo "${self}: PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
    >&2 echo "${self}: buildInputs=${buildInputs}"
    >&2 echo "${self}: file=$(which file)"
    >&2 echo "${self}: bison=$(which bison)"
    >&2 echo "${self}: /bin/sh=$(file /bin/sh)"
    >&2 echo "${self}: LFS=${LFS}"
    >&2 echo "${self}: file(\$LFS)=$(file ${LFS})"
} # ..display_phase

function check_phase() {
    >&2 echo "check_phase: enter"
    if [[ ${lfsdirect} -eq 1 ]]; then
	# will take headers from /mnt/lfs/usr
	linux_lfsx_stage1=${LFS}/usr
    else
	# will take headers from nix store
	[[ -n ${linux_lfsx_stage1} ]] || exit 1
    fi
}

function unpack_phase() {
    >&2 echo "unpack_phase: curdir=$(pwd)"

    pushd ${home}

    # creates ${home}/${glibc_vsubdir}
    tar -xf ${glibc_src}

    popd
} # ..unpack_phase

# patch_phase: must follow unpack_phase,
#
#
function patch_phase() {
    >&2 echo "patch_phase: curdir=$(pwd)"

    # need to replace hardcoded /usr/bin/file with nix store path /nix/store/$hash/bin/file
    file=$(which file)

    pushd ${home}/${vsubdir}

    # some of the Glibc programs use the non-FHS compliant /var/db directory to store their runtime data.
    # Apply the following patch to make such programs store their runtime data in the FHS-compliant locations
    #
    patch -Np1 -i ${glibc_patch_src}

    #sed -i -e "s:/usr/bin/file:${files}:g" ./*/configure

    popd
} # ..patch_phase

function configure_phase() {
    >&2 echo "configure_phase: curdir=$(pwd)"
    #echo "home=${home}"
    
    pushd ${home}/${vsubdir}

    mkdir -pv build
    cd build

    # expect to install ldconfig, sln utilities to /usr/sbin
    echo "rootsbindir=/usr/sbin" > configparams

    # note: configure will be using ${gcc_lfsx_stage1}/bin/${LFS_TGT}-gcc.
    #       Thought that might mean we could prepare nix build with nix {gcc, binutils}
    #       excluded.  This doesn't work,   configure complains that there's no gcc in ${PATH}
    #
    # --prefix:         ultimate install location
    # --host:           target architecture name (e.g. x86_64-lfs-linux-gnu)
    # --build:          along with --host,  tells glibc build system to cross-compile.
    #                   want to use gcc from nix package gcc_lfsx_stage1
    # --enable-kernel:  don't bother supporting kernels older than this value
    # --with-headers:   use kernel headers from this location.
    #                   LFS asks for ${LFS}/usr/include here;  we want to take them from nix
    #                   substituting nix store location,  and crossing fingers
    # libc_cv_slibdir:  install to /usr/lib instead of /usr/lib64
    #
    ../configure \
	--prefix=/usr \
	--host=${LFS_TGT} \
        --build=$(../scripts/config.guess) \
        --enable-kernel=3.2 \
        --with-headers=${linux_lfsx_stage1}/include \
        libc_cv_slibdir=/usr/lib

    popd

    pushd ${home}/${vsubdir}
} # ..configure_phase

function compile_phase() {
    >&2 echo "compile_phase: curdir=$(pwd)"

    pushd ${home}/${vsubdir}/build
    make
    #echo "compile_phase: pwd=$(pwd):"
    #ls $(pwd)
    popd
} # ..compile_phase

function install_phase() {
    >&2 echo "install_phase: curdir=$(pwd)"

    mkdir -pv ${out}

    pushd ${home}/${vsubdir}

    # code here intended to be used with both
    #   INSTALL_PREFIX=${LFS}
    # and
    #   INSTALL_PREFIX=${out}

    # i'm a  bit confused about instructions from LFS book here.
    # It wants us to create compatibility symlinks to ld-linux-x86-64.so.2
    # in /mnt/lfs/lib64/
    #
    # Since build installs to ${out}/usr,
    # and ${out}/usr/lib/ld-linux-x86-64.so.2 exists,
    # I expected we really want these links in ${out}/usr/lib64/.
    #
    # However a later step truncates /usr/lib paths in ${out}/usr/bin/ldd,
    # so I think we're moving things later.
    #
    mkdir -pv ${INSTALL_PREFIX}/lib64

    # the two symbolic links below will be broken at install time.
    # looking for something in the LFS book that undangles them.
    #
    ln -sfv ../lib/ld-linux-x86-64.so.2 ${INSTALL_PREFIX}/lib64/

    # compatibility link for linux standard base (LSB)
    #
    ln -sfv ../lib/ld-linux-x86-64.so.2 ${INSTALL_PREFIX}/lib64/ld-lsb-x86-64.so.3

    # note: this installs to ${INSTALL_PREFIX}/usr/lib
    #       (perhaps because of --prefix=/usr in configure step?)
    #       
    make DESTDIR=${INSTALL_PREFIX} -C build install
    
    if [[ ${lfsdirect} -eq 1 ]]; then
	>&2 echo "${self}: mkheaders for gcc version [$gcc_version]"
	${LFS_TOOLS}/libexec/gcc/${LFS_TGT}/${gcc_version}/install-tools/mkheaders
    else
	>&2 echo "${self}: TODO: decide how to do this for nix store build"
    fi

    # replace
    #   RTDLIST="/usr/lib/ld-linux.so.2 /usr/lib64/ld-linux-x86-64.so.2 ..."
    # with
    #   RTDLIST="/lib/ld-linux.so.2 /lib64/ld-linux-x86-64.so.2 ..."
    #
    sed '/RTLDLIST=/s:/usr::g' -i ${INSTALL_PREFIX}/usr/bin/ldd

    popd
} # ..install_phase

function cleanup_phase() {
    pushd ${home}
    rm -rf bin
    rm -rf ${vsubdir}
    popd
} # ..cleanup_phase

function do_all_phases() {
    display_phase
    check_phase
    unpack_phase
    patch_phase
    configure_phase
    compile_phase
    install_phase
    cleanup_phase
} # ..do_all_phases

function help() {
    echo "build sequence:"
    echo "$ do_all_phases"
    echo "or:"
    echo "$ display_phase"
    echo "$ check_phase"
    echo "$ unpack_phase"
    echo "$ patch_phase"
    echo "$ configure_phase"
    echo "$ compile_phase"
    echo "$ install_phase"
    echo "$ cleanup_phase"
} # ..help

# end setup.sh
