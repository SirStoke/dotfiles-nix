{ config, pkgs, lib, ... }:
{
  security.wrappers.noisetorch = {
    owner = "sandro";
    group = "users";
    source = "${pkgs.noisetorch}/bin/noisetorch";
    capabilities = "cap_sys_resource=+ep";
  };
}
