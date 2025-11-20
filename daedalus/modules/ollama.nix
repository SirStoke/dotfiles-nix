{pkgs, ...}: {
  services.ollama = {
    enable = true;

    loadModels = ["qwen3:0.6b"];
  };
}
