# linux/default.nix
# nix derivation for linux kernel headers
# to build:  in parent directory:
#   $ nix-build -A linux_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball)
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl }:

mkDerivation {
  # target package name overrides here
  name = "linux-lfsx-stage1";

  lfsdirect = lfs-direct;

  args = [ ./builder.sh ];
  setup = ./setup.sh;

  #glibc_version = "2.35";

  vsubdir = "linux-5.16.9";

  linux_src = fetchurl {
    url = "https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz";
    sha256 = "0kvlidg7qgj49in9h92sw0dnnzyrvqax2fcpq63w36f2iqiffq0n";
  };

  buildInputs = [
    #pkg-config
    #(pkgs.lib.getLib attr)
    #(pkgs.lib.getDev attr)
  ];
}

