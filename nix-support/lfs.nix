attrs:

let defaultAttrs = {

  # mount:  preparing LFS partition,  mounted at /mnt/lfs
  # targetSuffix:  target architecture will be $(uname -m)$targetSuffix
  #
  lfs = { mount = "/mnt/lfs";
          targetSuffix = "-lfs-linux-gnu"; };
};
in (defaultAttrs // attrs)
  