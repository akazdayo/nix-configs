{ hostMeta, ... }:
{
  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    # this makes system auth etc. work properly
    polkitPolicyOwners = [ hostMeta.primaryUser ];
  };
}
