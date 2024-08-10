{lib, ...}: {
  disko.devices = {
    disk = {
      a = {
        type = "disk";
        device = "/dev/sdd";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
      b = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
      d = {
        type = "disk";
        device = "/dev/sdc";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "data";
              };
            };
          };
        };
      };
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "64M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "root";
              };
            };
          };
        };
      };
    };
    zpool = {
      data = {
        type = "zpool";
        mode = "raidz";
        rootFsOptions = {
          compression = "lz4";
          encryption = "on";
          keyformat = "hex";
          keylocation = "file:///dev/disk/by-partuuid/346ff82a-8e16-4d01-ba99-b676b8e4d7ab";
          mountpoint = "none";
          acltype = "posixacl";
          xattr = "sa";
          recordsize = "1M";
          atime = "off";
        };

        options.ashift = "12";

        datasets = {
          data = {
            type = "zfs_fs";
            options = {
              acltype = "posixacl";
              compression = "lz4";
              xattr = "sa";
              recordsize = "1M";
              atime = "off";
              mountpoint = "legacy";
            };
          };
        };
      };
      root = {
        type = "zpool";
        rootFsOptions = {
          compression = "lz4";
          encryption = "on";
          keyformat = "hex";
          keylocation = "file:///dev/disk/by-partuuid/346ff82a-8e16-4d01-ba99-b676b8e4d7ab";
          mountpoint = "none";
          acltype = "posixacl";
          xattr = "sa";
          recordsize = "1M";
          atime = "off";
        };

        options.ashift = "12";

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options.mountpoint = "legacy";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
