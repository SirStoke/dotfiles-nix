{...}: {
  services.duplicity = {
    enable = true;
    root = /var/data;
    targetUrl = "s3://daedalus-bkp";
    fullIfOlderThan = "1M";
    extraFlags = [
      "--s3-endpoint-url"
      "https://s3.eu-central-003.backblazeb2.com"
      "--progress"
      "--progress-rate"
      "60"
    ];
    secretFile = /run/agenix/duplicity-secrets;
    cleanup.maxFull = 1;
  };
}
