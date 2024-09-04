{pkgs, ...}: let
  targetUrl = "s3://daedalus-bkp";
  secretFile = /run/agenix/duplicity-secrets;
  endpointUrl = "https://s3.eu-central-003.backblazeb2.com";
in {
  services.duplicity = {
    inherit targetUrl;
    inherit secretFile;

    enable = true;
    root = /var/data;
    fullIfOlderThan = "1M";
    extraFlags = [
      "--s3-endpoint-url"
      endpointUrl
      "--progress"
      "--progress-rate"
      "60"
    ];
    cleanup.maxFull = 1;
  };
}
