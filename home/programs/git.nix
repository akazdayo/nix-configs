{...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "akazdayo";
        email = "82073147+akazdayo@users.noreply.github.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
}
