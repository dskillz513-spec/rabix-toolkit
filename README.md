# RabiX Security Toolkit v6

Universal security toolkit installer for **iSH on iPhone** (Alpine Linux / busybox ash) and **Kali Linux** (Debian).

## Install

```sh
sh rabix_v6.sh
```

## Tools Included

### OSINT
| # | Tool | Description |
|---|------|-------------|
| 1 | Aliens_eye | Location tracking via phone/IP |
| 2 | Mr.Holmes | OSINT aggregator |
| 3 | Osintgram | Instagram OSINT |
| 4 | hound | Phone/email OSINT |
| 5 | geo-recon | GeoIP recon |
| 6 | SIGIT | Social intelligence toolkit |
| 7 | DIGI-NETRA | Digital footprint recon |
| 8 | Mohini | Instagram recon |
| 9 | sherlock | Username search across 300+ sites |
| 10 | nexfil | Username OSINT |
| 11 | maigret | Username OSINT with graph |

### Phishing / Social Engineering
| # | Tool | Description |
|---|------|-------------|
| 20 | BlackEye | Multi-page phishing kit |
| 21 | PyPhisher | Advanced phishing framework |
| 22 | MaxPhisher | Max phishing pages |
| 23 | CamPhish | Camera phishing |
| 24 | seeker | Location phishing |
| 25 | CiLocks | Location + camera phishing |
| 26 | instainsane | Instagram brute |
| 27 | pwneye | Multi-platform phishing |
| 28 | HiddenEye | Advanced phishing |
| 29 | zphisher | 30+ page phishing |

### Network / Scanning
| # | Tool | Description |
|---|------|-------------|
| 40 | Nettacker | Network attack/scan |
| 41 | evilwaf | WAF detection/bypass |
| 42 | SARA | Automated recon |
| 43 | katana | Web crawling |

### Android / RAT
| # | Tool | Description |
|---|------|-------------|
| 50 | Evil-Droid | Android payload builder |
| 51 | CamXploit | Camera exploitation |
| 52 | PhantomDroid | Android RAT |
| 53 | PAGASUS-PRO | Android remote access |

## After Install

```sh
sh ~/SocialEngineer/menu.sh
```

## Compatibility

- **iPhone / iSH**: Alpine Linux, busybox ash — fully supported
- **Kali Linux**: Debian apt — fully supported
- POSIX sh only — no bash required
- Runs as root (Kali) or user (iSH)

## Features

- Auto-detects Alpine vs Debian
- `clone_try` with multiple fallback URLs — dead repos don't break the install
- PHP version auto-detection (php83 → php82 → php8)
- masscan built from source on Alpine
- rockyou.txt linked or downloaded automatically
- Interactive menu launcher
