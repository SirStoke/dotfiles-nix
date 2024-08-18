{...}:
{
  age.secrets.cloudflare-dns = {
    file = ../cloudflare-dns.age;
    owner = "caddy";
    group = "caddy";
  };


  age.secrets.duplicity-secrets.file = ../duplicity-secrets.age;
  age.secrets.toggled-secrets.file = ../toggled-secrets.age;
  age.secrets.toggled-docker-pwd.file = ../toggled-docker-pwd.age;
  age.secrets.wireguard-config.file = ../wireguard-config.age;
}
