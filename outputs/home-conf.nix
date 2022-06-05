{ system, nixpkgs, nurpkgs, home-manager, tex2nix, ... }:

let
  username = "james";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    config.xdg.configHome = configHome;

    overlays = [
      nurpkgs.overlay
      (f: p: { tex2nix = tex2nix.defaultPackage.${system}; })
      (import ../home/overlays/md-toc)
      (import ../home/overlays/nheko)
      (import ../home/overlays/ranger)
    ];
  };

  nur = import nurpkgs {
    inherit pkgs;
    nurpkgs = pkgs;
  };

  mkHome = conf: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs system username homeDirectory;

      stateVersion = "21.03";
      configuration = conf;
    });

  edpConf = import ../home/display/edp.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
  };

  hdmiConf = import ../home/display/hdmi.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
  };
in
{
  james-edp = mkHome edpConf;
  james-hdmi = mkHome hdmiConf;
}
