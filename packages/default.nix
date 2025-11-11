{...}: {
  nixpkgs.overlays = [
    (final: prev: {
      wivrn = final.callPackage (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/ImSapphire/nixpkgs/a508998d55ad202e8ba4df45e5e65c28def48bc9/pkgs/by-name/wi/wivrn/package.nix";
        sha256 = "02h8avy04fml71gcnm016bjd52gb6bpnwfqzp43q9sd4l6yw7xvm";
      }) {};
    })
  ];
}
