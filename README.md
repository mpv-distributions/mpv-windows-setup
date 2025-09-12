## Downloads
1. [Latest stable version (Recommended)](https://github.com/mpv-distributions/mpv-win-setup/releases/latest)
2. [Latest master version](https://github.com/mpv-distributions/mpv-win-setup/releases)

## About
This repository offers Windows installer for [mpv media player](https://mpv.io). The setup is built using precompiled binaries from [Shinchiro's mpv builds](https://github.com/shinchiro/mpv-winbuild-cmake). 

## Setup Features
- Install without requiring administrator privileges
- Register File Associations
- Desktop & Start Menu Shortcuts

#### Optional Features
- Automatic Updates
- Install yt-dlp
- Add mpv to system PATH

#### Supported Architectures
| Architecture | Variants            |
| ------------ | ------------------- |
| 64-bit       | x86\_64, x86\_64-v3 |
| 64-bit ARM   | aarch64             |
| 32-bit       | i686                |

## Commandline Usage
Check [Inno Setup's Docs](https://jrsoftware.org/ishelp/index.php?topic=setupcmdline) for supported paramters.

#### Configurable Tasks
| Task           | Description                     |
|----------------|---------------------------------|
| `desktopicon`  | Creates a desktop shortcut      |
| `autoupdate`   | Enables automatic updates       |
| `addtopath`    | Adds mpv.exe to the system PATH |
| `installytdlp` | Installs yt-dlp using winget    |

#### Usage Examples

- Install for all users with desktop icon, automatic updates, and yt-dlp:
```cmd
setup.exe /VERYSILENT /TASKS="desktopicon,autoupdate,installytdlp" /SUPPRESSMSGBOXES /ALLUSERS
```