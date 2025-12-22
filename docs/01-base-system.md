# Base System Setup

Initial Fedora Workstation configuration.

## Fresh Installation

Download Fedora Workstation from: https://getfedora.org/

## Initial Update

```bash
sudo dnf update -y
```

## ThinkPad Power Management

### TLP (Battery & Thermal)

```bash
sudo dnf install -y tlp tlp-rdw
sudo systemctl enable --now tlp
```

### Power Profiles

```bash
sudo dnf install -y power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
powerprofilesctl set balanced
```

### Temperature Monitoring

```bash
sudo dnf install -y lm_sensors
sudo sensors-detect  # Answer YES to all
sensors
```

## Essential Tools

```bash
sudo dnf install -y \
    vim \
    tmux \
    htop \
    tree \
    wget \
    curl
```

## Optional: Additional Utilities

```bash
# Modern CLI tools (install if you want them)
sudo dnf install -y bat fzf ripgrep fd-find
```

## GNOME Tweaks

```bash
sudo dnf install -y gnome-tweaks
```

Use GNOME Tweaks to:
- Configure touchpad settings
- Set up keyboard shortcuts
- Customize appearance


## Tips:
`sudo` privilege are short lived - 15 min on Fedora and 5 min on Ubuntu. To extend:
- step 1:
```bash
#-- Run the visual sudo editor
sudo visudo
```  
- step 2: Find the line that starts with Defaults. Add timestamp_timeout=60 to it. It should look like this:
```
Defaults    env_reset, timestamp_timeout=60
```
## Next Steps

Proceed to [Development Fundamentals](02-development-fundamentals.md)

---

**Status:** ✅ Completed
