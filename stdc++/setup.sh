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
PATH=$(pwd)/bin
#PATH=$(pwd)/bin:${out}/bin

for p in ${buildInputs} ${baseInputs}; do
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

#INSTALL_PREFIX=${LFS_TOOLS}  # install to /mnt/lfs/tools
if [[ ${lfsdirect} -eq 1 ]]; then
    # if installing to LFS directly,   then we need /mnt/lfs/tools/bin content to be in path,
    # in place of upstream nix dependencies
    PATH=${LFS_TOOLS}/bin:${PATH}
    
    INSTALL_PREFIX=${LFS}
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
    >&2 echo "${self}: src=${gcc_src}"
    >&2 echo "${self}: out=${out}"
    >&2 echo "${self}: gcc_version=${gcc_version}"
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

    # creates ${home}/${vsubdir}
    tar -xf ${gcc_src}

#    pushd ${vsubdir}

#    # now unpack the supporting tarballs
#    rm -rf ./mpfr # ocd hygiene
#    # creates ${home}/${gcc_vsubdir}/${mpfr_vsubdir}
#    tar -xf ${mpfr_src}
#    mv -v ${mpfr_vsubdir} mpfr

#    rm -rf ./gmp
#    # creates ${home}/${gcc_vsubdir}/${gmp_vsubdir}
#    tar -xf ${gmp_src}
#    mv -v ${gmp_vsubdir} gmp

#    rm -rf ./mpc
#    # creates ${home}/${gcc_vsubdir}/${mpc_vsubdir}
#    tar -xf ${mpc_src}
#    mv -v ${mpc_vsubdir} mpc

#    popd
    popd
} # ..unpack_phase

# patch_phase: must follow unpack_phase,
#              curdir must be in directory created by unpacking tarball
#
function patch_phase() {
    >&2 echo "patch_phase: curdir=$(pwd)"

    # need to replace hardcoded /usr/bin/file with nix store path /nix/store/$hash/bin/file
    file=$(which file)

    pushd ${home}/${vsubdir}

    sed -i -e "s:/usr/bin/file:${files}:g" ./*/configure

    popd
} # ..patch_phase

function configure_phase() {
    #>&2 echo "configure_phase: curdir=$(pwd)"
    #echo "home=${home}"
    
    pushd ${home}/${vsubdir}

    mkdir -pv build
    cd build

    # note: build will prefix ${INSTALL_PREFIX} that was used when gcc was installed.
    #       see nxfs/gcc/setup.sh
    #
    # --host                   use the cross-compiler we previously built (in nxfs/gcc)
    # --disable-libstdcxx-pch  disable construction of precompiled headers,   we don't need these yet.
    # --with-gxx-include-dir   this needs to be the location where ${LFS_TGT}-gcc would search
    #                          for c++ header files.   compiler will prepend the sysroot path
    #                          (see --with-sysroot option to gcc stage1 configure in nxfs/gcc/setup.sh)
    #                          to come up with full path
    # --disable-multilib       we're only building 64-bit libraries
    # --disable-nls            need to disable this here since we disabled it when building gcc stage 1
    # --build                  infer a bunch of configuration options by inspecting this host
    #
    ../libstdc++-v3/configure           \
	--host=${LFS_TGT}               \
	--build=$(../config.guess)      \
	--prefix=/usr                   \
	--disable-multilib              \
	--disable-nls                   \
	--disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/${LFS_TGT}/include/${gcc_version}
#	--with-gxx-include-dir=/tools/${LFS_TGT}/include/c++/${gcc_version}
    popd
} # ..configure_phase

function compile_phase() {
    >&2 echo "compile_phase: curdir=$(pwd)"

    pushd ${home}/${vsubdir}
    make -C build
    popd
} # ..compile_gcc

function install_phase() {
    >&2 echo "install_phase: curdir=$(pwd)"

    pushd ${home}/${vsubdir}

    if [[ ${INSTALL_PREFIX} = ${LFS_TOOLS} ]]; then
	make -C build install
    else
	mkdir -pv ${out}

	make -C build DESTDIR=${INSTALL_PREFIX} install
    fi

    popd
} # ..install_phase

function do_all_phases() {
    display_phase
    unpack_phase
    patch_phase
    configure_phase
    compile_phase
    install_phase
} # ..do_all_phases

function help() {
    echo "build sequence:"
    echo "$ display_phase"
    echo "$ unpack_phase"
    echo "$ patch_phase"
    echo "$ configure_phase"
    echo "$ compile_phase"
    echo "$ install_phase"
}

# end setup.sh
