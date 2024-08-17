{...}:
{
  age.secrets.cloudflare-dns = {
    file = ../cloudflare-dns.age;
    owner = "caddy";
    group = "caddy";
  };


  age.secrets.duplicity-secrets = {
    file = ../duplicity-secrets.age;
  };
}
