# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Exclude unwanted packages
  services.xserver.excludePackages = with pkgs; [ xterm ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable virtualization services for QEMU/KVM
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.kirus = {
    isNormalUser = true;
    description = "kirus";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kirus";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Enable dconf for GNOME settings
  programs.dconf.enable = true;
  
  # Set up environment variables for dark theme
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
  };

  # Systemd service to apply GNOME settings including dark mode and dash-to-panel config
  systemd.user.services.gnome-settings = {
    description = "Apply GNOME Settings";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      # Apply dark mode
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      
      # Enable window controls (minimize, maximize, close buttons)
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'"
      
      # Enable dash-to-panel extension
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/enabled-extensions "['dash-to-panel@jderose9.github.com', 'arcmenu@arcmenu.com']"
      
      # Configure dash-to-panel favorite apps (pinned apps)
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Settings.desktop']"
      
      # Dash-to-panel specific settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/panel-positions '"{\"0\":\"BOTTOM\"}"'
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/panel-sizes '"{\"0\":48}"'
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/appicon-margin 8
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/appicon-padding 4
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/show-favorites true
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/dash-to-panel/show-running-apps true
      
      # Custom keyboard shortcuts using old GNOME Screenshot tool
      # Interactive area screenshot with Alt+S
      ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Alt>s'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'gnome-screenshot --area'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Screenshot Area'"
      
      # Set custom keybindings list
      ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
      
      # Lock screen with Alt+L
      ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Alt>l']"
      
      # Clear default conflicting shortcuts if they exist
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/keybindings/panel-main-menu "@as []"
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/keybindings/open-application-menu "@as []"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flatpak
  services.flatpak.enable = true;
  
  # Enable Tailscale VPN service
  services.tailscale.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    git
    firefox
    google-chrome
    gnome-tweaks
    gnomeExtensions.dash-to-panel
    gnomeExtensions.arcmenu
    vscode
    jetbrains.pycharm-community
    qemu
    qemu_kvm
    virt-manager
    virt-viewer
    docker-compose
    github-desktop
    gnome-screenshot  # Old GNOME screenshot tool for interactive screenshots
    dbeaver-bin       # Universal database tool
    nextcloud-client  # Nextcloud desktop client
    gnome-software    # GNOME Software store with Flatpak integration
    tailscale         # Tailscale VPN client
    tailscale-systray # Tailscale system tray GUI
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
