# RabiX Security Toolkit v9

Universal security toolkit installer for **iSH on iPhone** (Alpine Linux / busybox ash) and **Kali Linux** (Debian).

## Install

```sh
sh rabix_v9.sh
```

## Tools Included

### OSINT (18 tools)
| # | Tool | Description |
|---|------|-------------|
| 1 | Aliens_eye | 840+ platform username/social media OSINT (FIXED) |
| 2 | Mr.Holmes | OSINT aggregator |
| 3 | Osintgram | Instagram OSINT |
| 4 | sherlock | Username search across 300+ sites |
| 5 | nexfil | Username OSINT |
| 6 | maigret | Username OSINT with relationship graph |
| 7 | SIGIT | Social intelligence toolkit |
| 8 | holehe | Email to social media accounts OSINT |
| 9 | X-osint | Full OSINT suite — phone, email, VIN, subdomain |
| 10 | GhostTrack | Phone number + GPS location tracker |
| 11 | r4ven | GPS location + photo + IP capture |
| 12 | seeker | High-accuracy location phishing/tracking |
| 13 | PhoneInfoga | Advanced phone number OSINT |
| 14 | CloakQuest3r | Cloudflare origin IP finder |
| 15 | geo-recon | GeoIP recon |
| 16 | DIGI-NETRA | Digital footprint recon |
| 17 | Mohini | Instagram recon |
| 18 | OPRecon | Open source recon |

### Phishing / Social Engineering (12 tools)
| # | Tool | Description |
|---|------|-------------|
| 20 | BlackEye | Multi-page phishing kit |
| 21 | PyPhisher | Advanced phishing framework |
| 22 | MaxPhisher | Max phishing pages |
| 23 | zphisher | 30+ page phishing (most active) |
| 24 | CamPhish | Camera phishing via fake page |
| 25 | CiLocks | Location + camera phishing |
| 26 | HiddenEye | Advanced phishing with live data |
| 27 | pwneye | Multi-platform phishing |
| 28 | SocialPhish | Social media phishing toolkit |
| 29 | GoPhish | Professional phishing campaign framework |
| 30 | instainsane | Instagram brute force |
| 31 | SMSBomber | SMS flood testing |

### Network / Scanning (10 tools)
| # | Tool | Description |
|---|------|-------------|
| 40 | Nettacker | Network attack/scan framework |
| 41 | sqlmap | SQL injection scanner |
| 42 | evilwaf | WAF detection and bypass |
| 43 | SARA | Automated recon assistant |
| 44 | XSStrike | XSS scanner |
| 45 | Striker | Offensive info + vuln scanner |
| 46 | Sublist3r | Subdomain enumeration |
| 47 | RouterSploit | Router exploitation framework |
| 48 | katana | Fast web crawler (binary) |
| 49 | nuclei | Vulnerability scanner (binary) |

### Android / RAT (7 tools)
| # | Tool | Description |
|---|------|-------------|
| 50 | Evil-Droid | Android payload/backdoor builder |
| 51 | CamXploit | Camera exploitation |
| 52 | PhantomDroid | Android RAT |
| 53 | CAM-ACCE | Remote camera access |
| 54 | PAGASUS-PRO | Android remote access |
| 55 | AhMyth | Android RAT with GUI builder |
| 56 | ghost | Multi-platform C2 / backdoor |

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

- **Fixed Aliens_eye** — now clones from `BLINKING-IDIOT/Aliens_eye` (840+ platforms, active)
- Auto-detects Alpine vs Debian
- `clone_try` with multiple fallback URLs — dead repos don't break the install
- PHP version auto-detection (php83 → php82 → php8)
- masscan built from source on Alpine
- rockyou.txt + SecLists (partial sparse clone)
- nuclei + katana binary pre-built downloaders
- Interactive numbered menu launcher
- 47 total tools across 4 categories

## Changelog

### v9
- **Stage 1 batched**: all system packages now installed in one `apk add` / `apt-get install` call (was 21 separate calls) — cuts install time significantly on Alpine/iSH
- **Global pip pre-install**: installs 13 common packages (requests, colorama, bs4, lxml, pillow, dnspython, paramiko, pycryptodome, flask, werkzeug, tqdm, phonenumbers, python-whois) before any tool clones, so per-tool `pip_req()` is fast
- **pip timeouts**: all pip3 calls now include `--timeout=30` / `--timeout=20` — no more hanging on a stuck package
- **holehe replaces hound**: `hound` repo dead (all 3 URLs archived/removed); replaced with `holehe` (megadose/holehe) — active email-to-social OSINT tool, works via `python3 -m holehe`
- **geo-recon fixed**: removed bad Osintgram fallback URL (different tool)
- **README install command fixed**: was `sh rabix_v7.sh` — now correctly `sh rabix_v9.sh`

### v8
- Bulletproof pip installs: `--prefer-binary` avoids C compilation failures on iSH Alpine
- `pip_req()` now tries 3 strategies: bulk binary → no-deps binary → per-package fallback loop
- Alpine Stage 1: pre-installs `py3-requests py3-beautifulsoup4 py3-colorama py3-lxml py3-pillow` via apk
- Eliminates `[!] pip failed` warnings on iSH — partial installs succeed instead of dying

### v7
- Fixed `Aliens_eye` — replaced 3 dead URLs with `BLINKING-IDIOT/Aliens_eye` + fallbacks
- Added OSINT: X-osint, GhostTrack, r4ven, PhoneInfoga, CloakQuest3r
- Added Phishing: zphisher (moved up), SocialPhish, GoPhish, SMSBomber
- Added Network: sqlmap, XSStrike, Striker, Sublist3r, RouterSploit, nuclei
- Added RAT: AhMyth, ghost
- Added Stage 1 packages: sqlite, go, tar
- Added SecLists (sparse clone)
- Menu expanded to 57 entries

### v6
- POSIX sh / ash fully compatible
- `GIT_TERMINAL_PROMPT=0` prevents credential prompts blocking clone loop
- OS detection inline (ash function body truncation bug fixed)
- All `&>/dev/null` replaced with `>/dev/null 2>&1`
