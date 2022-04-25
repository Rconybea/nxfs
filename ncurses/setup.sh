# source this to enter nix environment for doing LFS work.
# see ./default.nix
#
# in that file, attributes passed to mkDerivation appear here as environment variables:
#  name
#  args
#  setup
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
    tar -xf ${ncurses_src}

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

    # ensure gawk used even if mawk present
    sed -i -e "s:mawk::" ./configure
    sed -i -e "s:/usr/bin/file:${files}:g" ./configure

    popd
} # ..patch_phase

function configure_tic() {
    #>&2 echo "configure_phase: curdir=$(pwd)"
    #echo "home=${home}"
    
    pushd ${home}/${vsubdir}

    mkdir -pv build

    pushd build
    # note: configure step here will use regular gcc from the build machine,
    #       not the the LFS cross-compiler
    ../configure

    popd
    popd
} # ..configure_tic

function compile_tic() {
    pushd ${home}/${vsubdir}/build
    
    # note:  this creates a version of tic that runs on the build host
    #        (i.e. it's not cross-compiled)
    #        we need this to be runnable on the build host so we can create terminfo
    #        database.
    #        We will not be installing this version
    #
    make -C include
    make -C progs tic

    popd
} # ..compile_tic

function configure_ncurses() {
    pushd ${home}/${vsubdir}

    # note: build will prefix ${INSTALL_PREFIX} that was used when gcc was installed.
    #       see nxfs/gcc/setup.sh
    #
    # --prefix                 we will install to /mnt/lfs/usr,   but executables will
    #                          eventually run in environment where /mnt/lfs/usr is mounted
    #                          as /usr
    # --host                   use the cross-compiler we previously built (in nxfs/gcc)
    # --build                  infer a bunch of configuration options by inspecting this host
    # --mandir                 directory root for manual pages
    # --with-manpage-format    prevent installing compressed man pages
    # --with-shared            build shared libraries
    # --without-debug          build without debug features (really?)
    # --without-ada            disable ADA language support.
    # --without-normal         disable static libraries
    # --disable-stripping      don't use strip to remove debug symbols;
    #                          not to be relied on when using a cross-compiler
    # --enable-widec           build wide-character libraries instead of 8-bit-encoding-only ones
    #
    ./configure --prefix=/usr                \
		--host=${LFS_TGT}            \
		--build=$(./config.guess)    \
		--mandir=/usr/share/man      \
		--with-manpage-format=normal \
		--with-shared                \
		--without-debug              \
		--without-ada                \
		--without-normal             \
		--disable-stripping          \
		--enable-widec               
#          	--with-gxx-include-dir=/tools/${LFS_TGT}/include/c++/${gcc_version}

    popd
} # ..configure_ncurses

function compile_ncurses() {
    >&2 echo "compile_ncurses: curdir=$(pwd)"

    pushd ${home}/${vsubdir}
    make -C build
    popd
} # ..compile_ncurses

function install_phase() {
    >&2 echo "install_phase: curdir=$(pwd)"

    pushd ${home}/${vsubdir}

    if [[ ${lfsdirect} -eq 1 ]]; then
        make DESTDIR=${LFS} TIC_PATH=$(pwd)/build/progs/tic install
	# I think this makes '-lncurses' the same as '-lncursesw'
        echo "INPUT(-lncursesw)" > ${LFS}/usr/lib/libncurses.so
    else
	mkdir -pv ${out}

	>&2 echo "install_phase: not implemented yet for pure nix build"
        exit 1
	#make -C build DESTDIR=${INSTALL_PREFIX} install
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
    echo "$ configure_tic"
    echo "$ compile_tic"
    echo "$ configure_ncurses"
    echo "$ compile_ncurses"
    echo "$ install_phase"
}

# end setup.sh
