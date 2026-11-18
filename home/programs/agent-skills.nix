{
  programs.agent-skills = {
    enable = true;
    sources.nix-cache = {
      input = "nix-cache-skills";
      subdir = "skills";
    };
    skills.enable = [ "nix-cache-optimize" ];
    targets.agents = {
      enable = true;
      dest = ".agents/skills";
      structure = "link";
    };
  };
}
