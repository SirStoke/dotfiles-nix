let
  keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy0lqXPx72NlzPU2GMfmioHSnLQR7pjSdyO+teG02Wi9gAuEep1vNjv1F6NeSRqd3GywB9f0YydsmMSq4o+zG/HK/xnYPHA1gC+9jTWFuao3X31K5nNf3Escw6MAT5aCRqGB1QfbbsZBfAI9wrugNWR0WMZYXP7+TrXfqLJdVZd3Dy6k89thsA92NQshCiacYthSVL3HZuD8wrCcQ9Z/K+N8Pr9gfGOzRY8vvaqXcBdPfgD//1k1ccQqO796gXbjEF897le4biPdAU6slQ3rAyWvOGsJzKjLleEo5HkBNCgbAR+Vf756Ai1D4GStO0iAktMWMdyHwgjHyvPjjluj7d" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBxYYx5n6ViZDTn1WpzXJ7fw7e7wW4JjnIAZ3w+Dpy7 root@daedalus" ];
in {
  "namecheap-dns.age".publicKeys = keys;
  "cloudflare-dns.age".publicKeys = keys;
  "duplicity-secrets.age".publicKeys = keys;
  "toggled-secrets.age".publicKeys = keys;
  "toggled-docker-pwd.age".publicKeys = keys;
  "wireguard-config.age".publicKeys = keys;
}
