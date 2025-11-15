# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modular NixOS configuration using Flakes and Home Manager for user "akazdayo". The configuration is structured with a clear separation between system-level (`modules/`) and user-level (`home/`) settings.

## Common Commands

### Build and Apply Configuration
```bash
# Apply configuration and switch (most common)
sudo nixos-rebuild switch --flake .#nixos

# Test configuration without making it default boot option
sudo nixos-rebuild test --flake .#nixos

# Dry build to check for errors without applying
nixos-rebuild dry-build --flake .#nixos

# Check flake for issues
nix flake check
```

### Updating Dependencies
```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

## Architecture

### Flake Structure
- Uses multiple nixpkgs inputs: `nixpkgs` (unstable), `nixpkgs-stable` (25.05), and `nixpkgs-xr` (for VR packages)
- The flake passes `pkgs-stable` and `pkgs-xr` as `specialArgs` to both NixOS modules and Home Manager
- Single host configuration named "nixos"

### Module Organization
The configuration follows a modular pattern where:

1. **Entry Point**: `configuration.nix` imports `hosts/nixos/default.nix`
2. **Host Configuration**: `hosts/nixos/default.nix` imports all system modules from `modules/`
3. **System Modules** (`modules/`): Feature-based organization
   - `audio/` - PipeWire configuration
   - `boot/` - Bootloader settings
   - `desktop/` - X11/GNOME desktop environment
   - `gaming/` - Steam and VR (WiVRn) with CUDA support
   - `hardware/` - NVIDIA drivers (open source), swap configuration
   - `locale/` - Locale, fonts, input methods
   - `networking/` - Network configuration
   - `users/` - User account definitions

4. **Home Manager** (`home/`): User-specific settings for `akazdayo`
   - Configured via flake's `home-manager.nixosModules.home-manager`
   - `home/default.nix` imports programs from `home/programs/`
   - Programs: git, files, packages, gnome (dconf settings)

5. **Custom Packages** (`packages/default.nix`): Overlays for custom package builds
   - Currently contains WiVRn overlay from external source

### Special Configurations
- **WiVRn**: Custom package overlay with CUDA support enabled for VR streaming
- **NVIDIA**: Uses open-source drivers with modesetting and nvidia-uvm kernel module
- **Multiple nixpkgs**: System modules can access stable packages via `pkgs-stable` argument

## Adding New Modules

### System Module
1. Create `modules/new-feature/default.nix`
2. Add to imports in `hosts/nixos/default.nix`
3. Module receives `pkgs`, `pkgs-stable`, `pkgs-xr`, and `self` as available arguments

### Home Manager Module
1. Create `home/programs/new-program.nix`
2. Add to imports in `home/default.nix`
3. Module receives `pkgs`, `pkgs-stable`, and `pkgs-xr` as available arguments

## Important Notes

- System state version: 25.05
- Experimental features enabled: `nix-command`, `flakes`
- `allowUnfree = true` is set for both system and stable packages
- User: `akazdayo`
- Architecture: `x86_64-linux`
