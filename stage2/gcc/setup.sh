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
#  mpfr_vsubdir
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
    >&2 echo "${self}: src=${gcc_src}"
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
    #tar -xf ${binutils_src}

    # creates ${home}/${vsubdir}
    tar -xf ${gcc_src}

    pushd ${vsubdir}

    # now unpack the supporting tarballs
    rm -rf ./mpfr # ocd hygiene
    # creates ${home}/${gcc_vsubdir}/${mpfr_vsubdir}
    tar -xf ${mpfr_src}
    mv -v ${mpfr_vsubdir} mpfr

    rm -rf ./gmp
    # creates ${home}/${gcc_vsubdir}/${gmp_vsubdir}
    tar -xf ${gmp_src}
    mv -v ${gmp_vsubdir} gmp

    rm -rf ./mpc
    # creates ${home}/${gcc_vsubdir}/${mpc_vsubdir}
    tar -xf ${mpc_src}
    mv -v ${mpc_vsubdir} mpc

    popd
    popd
} # ..unpack_phase

# patch_phase: must follow unpack_phase,
#              curdir must be in directory created by unpacking tarball
#
function patch_phase() {
    >&2 echo "patch_phase: curdir=$(pwd)"

    # need to replace hardcoded /usr/bin/file with nix store path /nix/store/$hash/bin/file
    file=$(which file)

    #pushd ${home}/${binutils_vsubdir}
    #sed -i -e "s:/usr/bin/file:${files}:g" ./*/configure
    #popd

    pushd ${home}/${vsubdir}
    # lots of these to fix
    sed -i -e "s:/usr/bin/file:${file}:g" ./configure ./*/configure

    # NOTE: might be tempting to replace /bin/sh with nix-store paths;
    #       however it's not obvious exactly which files to patch to limit
    #       effects to build on host computer.   we want to use nix store
    #       bash on host,  but will want /bin/sh on LFS destination.

    # we're not attempting a multiarch build;
    # prefer ${prefix}/lib to ${prefix}/lib64
    #
    case $(uname -m) in
	x86_64)
	    sed -e '/m64=/s:lib64:lib:' -i.orig gcc/config/i386/t-linux64
	    ;;
    esac

    popd
} # ..patch_phase

function configure_phase() {
    >&2 echo "configure_phase: curdir=$(pwd)"
    #echo "home=${home}"
    
    pushd ${home}/${vsubdir}

    mkdir -pv build
    cd build

    # create symlink to allow building libgcc with posix thread support
    mkdir -pv ${LFS_TGT}/libgcc
    ln -sf ../../../libgcc/gthr-posix.h ${LFS_TGT}/libgcc/gthr-default.h

    # --prefix                will eventually be installed to this directory
    #                         (/mnt/lfs/tools or nix store location)
    # --target                target architecture (x86_64-lfs-linux-gnu)
    # --enable-initfini-array 'magic spell' need this for a cross compiler
    # --disable-multilib      we're only building 64-bit libraries
    # --disable-XXX           disable a bunch of things that won't work,  and that we don't need ye
    #
    # NOTE: in stage1,  we were preparing cross-compiler, using host compiler to build it.
    #       in stage2,  we use the stage1 cross-compiler to prepare LFS gcc
    #       now we can enable threads and shared libs,  and can rely on libc, kernel headers.
    #
    ../configure \
         --build=$(../config.guess) \
         --host=${LFS_TGT} \
	 --prefix=/usr \
	 CC_FOR_TARGET=${LFS_TGT}-gcc \
         CXX_FOR_TARGET=${LFS_TGT}-g++ \
	 GCC_FOR_TARGET=${LFS_TGT}-gcc \
         --with-build-sysroot=${LFS} \
	 --enable-initfini-array \
	 --disable-nls \
	 --disable-multilib \
	 --disable-decimal-float \
	 --disable-libatomic \
	 --disable-libgomp \
	 --disable-libquadmath \
	 --disable-libssp \
	 --disable-libvtv \
	 --disable-libstdcxx \
	 --enable-languages=c,c++

    popd
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

    pushd ${home}/${vsubdir}

    if [[ ${lfsdirect} -eq 1 ]]; then
	make -C build DESTDIR=${LFS} install

	# convenience symlink cc -> gcc
	ln -sv gcc ${LFS}/usr/bin/cc

	# TODO: limits.h rewrite will have to be deferred until final_install_phase()
    else
	>&2 echo "install_phase: TODO: solution for pure net build"
	exit 1

	mkdir -pv ${out}

	make -C build install

	# see notes in LFS chapter 5 'compiling a cross toolchain':
	# normally limits.h would include LFS system limits.h
	# ($LFS/usr/include/limits.h).
	# however,  at this point the LFS system limits.h file doesn't
	# exist, which causes install to fallback to a partial self-contained file.
	#
        # generate full header here,  in the same way gcc install would later
        #
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h \
	    > $(dirname $(${out}/bin/${LFS_TGT}-gcc -print-libgcc-file-name))/install-tools/include/limits.h
    fi

    popd
} # ..install_phase

function cleanup_phase() {
    pushd ${home}
    rm -rf bin
    #rm -rf ${binutils_vsubdir}
    rm -rf ${vsubdir}
    popd
} # ..cleanup_phase

function do_all_phases() {
    display_phase
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
    echo "$ unpack_phase"
    echo "$ patch_phase"
    echo "$ configure_phase"
    echo "$ compile_phase"
    echo "$ install_phase"
    echo "$ cleanup_phase"
}

# end setup.sh
