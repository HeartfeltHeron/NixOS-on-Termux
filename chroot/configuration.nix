{ config, pkgs, lib, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports =
  [
    ./nixos-init-freedom/s6-init.nix
  ];

  # Disables systemd init since systemd doesn't work in proot/chroot/Termux.
  services.s6-init.enable = true;

  # proot/chroot uses the system kernel, so we disable starting this one.
  boot.kernel.enable = false;

  # Normally this would be in the hardware-config, but we don't have one of those.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Ultimately I want the system to be buildable with a flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # I just really prefer zsh
  users.defaultUserShell = pkgs.zsh;

  # Set the root password to ensure we have one if we need it.
  # This should be changed using the passwd command before
  # being used for more than just testing.
  users.users.root = {
    initialPassword = "Password";
    packages = with pkgs; [
    ];
  };

  # Turn on zsh
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
  };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Needed for cloning a repo and building flakes
    git
    # Needed because I don't like nano
    neovim
  ];

  # Android has it's own firewall, we don't need NixOS to also firewall.
  networking.firewall.enable = false;

  # Don't touch. Don't do it. REALLY don't do it.
  system.stateVersion = "24.05";
}
