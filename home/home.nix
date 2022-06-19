{ config, lib, pkgs, stdenv, ... }:

let
  # workaround to open a URL in a new tab in the specific firefox profile
  work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    any-nix-shell        # fish support for nix shell
    arandr               # simple GUI for xrandr
    bottom               # alternative to htop & ytop
    cachix               # nix caching
    dconf2nix            # dconf (gnome) files to nix converter
    dmenu                # application launcher
    docker-compose       # docker manager
    dive                 # explore docker layers
    insomnia             # rest client with graphql support
    jitsi-meet-electron  # open source video calls and chat
    jmtpfs               # mount mtp devices
    killall              # kill processes by name
    libnotify            # notify-send command
    multilockscreen      # fast lockscreen based on i3lock
    nix-index            # locate packages containing certain nixpkgs
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pgcli                # modern postgres client
    prettyping           # a nicer ping
    pulsemixer           # pulseaudio mixer
    ripgrep              # fast grep
    rnix-lsp             # nix lsp server
    slack                # messaging client
    tdesktop             # telegram messaging client
    tex2nix              # texlive expressions for documents
    tldr                 # summary of a man page
    tree                 # display files in a tree view
    vlc                  # media player
    xsel                 # clipboard support (also for neovim)

    # work stuff
    work-browser

    # fixes the `ar` error required by cabal
    binutils-unwrapped
  ];

  gitPkgs = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];

  gnomePkgs = with pkgs.gnome3; [
    eog            # image viewer
    evince         # pdf reader
    nautilus       # file manager
  ];

  haskellPkgs = with pkgs.haskellPackages; [
    brittany                # code formatter
    cabal2nix               # convert cabal projects to nix
    cabal-install           # package manager
    ghc                     # compiler
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle                  # documentation
    nix-tree                # visualize nix dependencies
  ];

  polybarPkgs = with pkgs; [
    font-awesome          # awesome fonts
    material-design-icons # fonts with glyphs
    xfce.orage            # lightweight calendar
  ];

  scripts = pkgs.callPackage ./scripts/default.nix { inherit config pkgs; };

  yubiPkgs = with pkgs; [
    yubikey-manager  # yubikey manager cli
    yubioath-desktop # yubikey OTP manager (gui)
  ];

  xmonadPkgs = with pkgs; [
    networkmanager_dmenu   # networkmanager on dmenu
    networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
  ];

in
{
  programs.home-manager.enable = true;

  nixpkgs.overlays = [
    (import ./overlays/beauty-line)
    (import ./overlays/coc-nvim)
  ];

  imports = (import ./programs) ++ (import ./services) ++ [(import ./themes)];

  xdg.enable = true;

  home = {
    packages = defaultPkgs ++ gitPkgs ++ gnomePkgs ++ haskellPkgs ++ polybarPkgs ++ scripts ++ xmonadPkgs ++ yubiPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "silent";

  programs = {
    bat.enable = true;

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    gpg.enable = true;

    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    jq.enable = true;

    obs-studio = {
      enable = true;
      plugins = [];
    };

    ssh.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [];
    };
  };

  services = {
    flameshot.enable = true;
  };

}
