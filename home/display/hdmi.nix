# Configuration for the HDMI-1 display monitor
{ config, lib, pkgs, stdenv, nur, ... }:

let
  hdmiOn = true;

  base = pkgs.callPackage ../home.nix { inherit config lib pkgs stdenv; };

  browser = pkgs.callPackage ../programs/browsers/firefox.nix {
    inherit config pkgs nur hdmiOn;
  };

  hdmiBar = pkgs.callPackage ../services/polybar/bar.nix { };

  spotify = import ../programs/spotify/default.nix {
    inherit pkgs hdmiOn;
  };

  statusBar = import ../services/polybar/default.nix {
    inherit config pkgs;
    mainBar = hdmiBar;
    openCalendar = "${pkgs.xfce.orage}/bin/orage";
  };

  terminal = import ../programs/alacritty/default.nix { fontSize = 10; inherit pkgs; };

  wm = import ../programs/xmonad/default.nix {
    inherit config pkgs lib hdmiOn;
  };
in
{
  imports = [
    ../home.nix
    statusBar
    terminal
    wm
  ];

  programs.firefox = browser.programs.firefox;

  home.packages = base.home.packages ++ [ spotify ];
}
