# glibc/default.nix
# nix derivation for LFS glibc step1
# to build:  in parent directory:
#   $ nix-build -A glibc_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# patch                :: storepath (gnu patch)
# pkg-config           :: storepath 
# bison                :: storepath
# python3              :: storepath
# gcc_lfsx_stage1      :: storepath (gcc+binutils)
# linux_lfsx_stage1    :: storepath (linux kernel API)
#
{ mkDerivation,
  lfs-direct,
  fetchurl,
  patch,
  pkg-config,
  bison,
  python3,
  gcc_lfsx_stage1,
  linux_lfsx_stage1 }:

mkDerivation {
  # note: attributes here propagate to builder.sh as shell environment variables
  
  name = "glibc-lfsx-stage1";

  lfsdirect = lfs-direct;

  args = [ ./builder.sh ];
  setup = ./setup.sh;

  vsubdir = "glibc-2.35";

  glibc_src = fetchurl {
    url = "https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.xz";
    sha256 = "0bpm1kfi09dxl4c6aanc5c9951fmf6ckkzay60cx7k37dcpp68si";
  };

  glibc_patch_src = fetchurl {
    url = "https://www.linuxfromscratch.org/patches/lfs/11.1/glibc-2.35-fhs-1.patch";
    sha256 = "03bvq857ajfvxdb0wbjayfmkyggqyph5ixg4zmzjsbqf0gdm4db4";
  };

  linux_lfsx_stage1 = linux_lfsx_stage1;

  # (see ./setup.sh)
  #
  buildInputs = [
    bison
    python3
    patch
    pkg-config
    gcc_lfsx_stage1
    linux_lfsx_stage1
    #(pkgs.lib.getLib attr)
    #(pkgs.lib.getDev attr)
  ];
}

