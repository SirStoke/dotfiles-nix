{...}:
{
  age.secrets.namecheap-dns= {
    file = ../namecheap-dns.age;
    owner = "caddy";
    group = "caddy";
  };


  age.secrets.duplicity-secrets = {
    file = ../duplicity-secrets.age;
  };
}
