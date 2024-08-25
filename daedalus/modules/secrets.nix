{...}: {
  age.secrets.cloudflare-dns = {
    file = ../cloudflare-dns.age;
    owner = "caddy";
    group = "caddy";
  };

  age.secrets.duplicity-secrets.file = ../duplicity-secrets.age;
  age.secrets.toggled-secrets.file = ../toggled-secrets.age;
  age.secrets.toggled-docker-pwd.file = ../toggled-docker-pwd.age;
  age.secrets.deluge-exporter-secrets.file = ../deluge-exporter-secrets.age;
  age.secrets.wireguard-config.file = ../wireguard-config.age;

  age.secrets.sonarr-api-key = {
    file = ../sonarr-api-key.age;
    owner = "sonarr";
    group = "media";
  };

  age.secrets.radarr-api-key = {
    file = ../radarr-api-key.age;
    owner = "radarr";
    group = "media";
  };
}
