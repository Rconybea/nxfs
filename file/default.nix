# file/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A coreutils_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  file_version = "5.41";

in
  mkDerivation {
    # target package name overrides here
    name = "file-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "file-${file_version}";

    file_src = fetchurl {
      url = "https://astron.com/pub/file/file-${file_version}.tar.gz";
      sha256 = "0gv027jgdr0hdkw7m9ck0nwhq583f4aa7vnz4dzdbxv4ng3k5r8k";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
