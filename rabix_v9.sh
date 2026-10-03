#!/bin/sh
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes"
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${GRN}[+]${NC} $*"; }
warn() { echo -e "${YLW}[!]${NC} $*"; }
ok()   { echo -e "${GRN}[+]${NC} $*"; }
hdr()  { printf "\n${CYN}=== %s ===${NC}\n" "$*"; }
if command -v apk >/dev/null 2>&1; then
    OS=alpine
    log "Alpine Linux (iSH)"
    sed -i 's|^#\(.*community\)|\1|g' /etc/apk/repositories 2>/dev/null
    apk update -q >/dev/null 2>&1
elif command -v apt-get >/dev/null 2>&1; then
    OS=debian
    log "Debian/Kali Linux"
    apt-get update -qq >/dev/null 2>&1
else
    OS=unknown
    warn "No known package manager"
fi
if [ "$(id -u)" = "0" ]; then S=""; PIPF="--break-system-packages -q"
else S="sudo"; PIPF="-q --user"; fi
BASE="$HOME/SocialEngineer"
mkdir -p "$BASE"
pkg() {
    if [ "$OS" = "alpine" ]; then
        $S apk add -q "$1" >/dev/null 2>&1 && ok "$1" || warn "$1 skipped"
    elif [ "$OS" = "debian" ]; then
        $S apt-get install -y -qq "$2" >/dev/null 2>&1 && ok "$2" || warn "$2 skipped"
    fi
}
clone_try() {
    NAME="$1"; shift
    if [ -d "$BASE/$NAME/.git" ]; then
        timeout 60 git -C "$BASE/$NAME" pull -q >/dev/null 2>&1 && ok "$NAME updated" || warn "$NAME pull failed"
        return
    fi
    log "$NAME: cloning..."
    for URL in "$@"; do
        timeout 60 git clone --depth=1 -q "$URL" "$BASE/$NAME" >/dev/null 2>&1 && ok "$NAME cloned" && return
    done
    warn "$NAME clone FAILED (all URLs tried)"
}
pip_req() {
    REQ="$BASE/$1/requirements.txt"
    [ -f "$REQ" ] || return 0
    # attempt 1: prefer binary wheels, skip C compilation, 30s timeout
    pip3 install --break-system-packages --prefer-binary --timeout=30 -q -r "$REQ" >/dev/null 2>&1 && return
    # attempt 2: no-deps to avoid version conflicts
    pip3 install --break-system-packages --prefer-binary --no-deps --timeout=30 -q -r "$REQ" >/dev/null 2>&1 && return
    # attempt 3: package-by-package fallback — installs whatever succeeds
    while IFS= read -r line; do
        case "$line" in ''|\#*) continue ;; esac
        pip3 install --break-system-packages --prefer-binary --timeout=20 -q "$line" >/dev/null 2>&1 || true
    done < "$REQ"
}
clear
echo "+======================================================+"
echo "| RabiX Security Toolkit v9 -- Universal              |"
echo "| OSINT  Phishing  RAT  Network  Social Engineer      |"
echo "+======================================================+"

# ── STAGE 1: System Dependencies ─────────────────────────────
hdr "STAGE 1 -- System Dependencies"
# Batch install all system packages in one call (much faster than 21 individual calls)
if [ "$OS" = "alpine" ]; then
    $S apk add -q \
        python3 py3-pip git curl wget unzip tar openssh-client nmap \
        build-base tor proxychains-ng jq whois bind-tools net-tools \
        openssl-dev curl-dev libpcap-dev sqlite go \
        >/dev/null 2>&1 && ok "system packages" || warn "some system packages skipped"
else
    $S apt-get install -y -qq \
        python3 python3-pip git curl wget unzip tar openssh-client nmap \
        build-essential tor proxychains4 jq whois dnsutils net-tools \
        libssl-dev libcurl4-openssl-dev libpcap-dev sqlite3 golang-go \
        >/dev/null 2>&1 && ok "system packages" || warn "some system packages skipped"
fi
# Alpine: pre-install common py3 apk packages (avoids pip C compilation on iSH)
if [ "$OS" = "alpine" ]; then
    $S apk add -q \
        py3-requests py3-beautifulsoup4 py3-colorama py3-lxml py3-pillow \
        py3-dnspython py3-pysocks py3-tqdm py3-flask py3-werkzeug \
        >/dev/null 2>&1 && ok "py3 apk packages" || true
fi
# Global pip pre-install -- satisfies most tool requirements before cloning begins
pip3 install --break-system-packages --prefer-binary --timeout=30 -q \
    requests colorama beautifulsoup4 lxml pillow \
    dnspython paramiko pycryptodome flask werkzeug \
    tqdm fake-useragent phonenumbers python-whois \
    pysocks urllib3 certifi >/dev/null 2>&1 && ok "pip pre-install" || true
# PHP auto-detect on Alpine (try 83 -> 82 -> 8)
if [ "$OS" = "alpine" ]; then
    apk add -q php83 >/dev/null 2>&1 || apk add -q php82 >/dev/null 2>&1 || apk add -q php8 >/dev/null 2>&1 || warn "php skipped"
    ok "php"
else
    $S apt-get install -y -qq php >/dev/null 2>&1 && ok "php" || warn "php skipped"
fi
# masscan: apk on Debian, build from source on Alpine
if [ "$OS" = "alpine" ]; then
    command -v masscan >/dev/null 2>&1 && ok "masscan" || {
        log "Building masscan from source..."
        apk add -q gcc make libpcap-dev linux-headers >/dev/null 2>&1
        git clone -q --depth=1 https://github.com/robertdavidgraham/masscan /tmp/_mc >/dev/null 2>&1 && \
        make -C /tmp/_mc -j2 -s >/dev/null 2>&1 && \
        install -m755 /tmp/_mc/bin/masscan /usr/local/bin/ >/dev/null 2>&1 && ok "masscan built" || warn "masscan failed"
        rm -rf /tmp/_mc
    }
else
    $S apt-get install -y -qq masscan >/dev/null 2>&1 && ok "masscan" || warn "masscan skipped"
fi
ok "Stage 1 done"

# ── STAGE 2: OSINT Tools ─────────────────────────────────────
hdr "STAGE 2 -- OSINT Tools"
# Aliens_eye -- 840+ social media username OSINT (FIXED: BLINKING-IDIOT is the active repo)
clone_try Aliens_eye \
    https://github.com/BLINKING-IDIOT/Aliens_eye \
    https://github.com/arxhr007/Aliens_eye \
    https://github.com/osintambition/Aliens-Eye
pip_req Aliens_eye

# Mr.Holmes -- OSINT aggregator
clone_try Mr.Holmes \
    https://github.com/Lucksi/Mr.Holmes \
    https://github.com/Mr-LynX/Mr.Holmes
pip_req Mr.Holmes

# Osintgram -- Instagram OSINT
clone_try Osintgram \
    https://github.com/Datalux/Osintgram
pip_req Osintgram

# sherlock -- username search 300+ sites
clone_try sherlock \
    https://github.com/sherlock-project/sherlock
pip_req sherlock

# nexfil -- username OSINT
clone_try nexfil \
    https://github.com/thewhiteh4t/nexfil \
    https://github.com/takito1812/nexfil
pip_req nexfil

# maigret -- username + graph OSINT
clone_try maigret \
    https://github.com/soxoj/maigret
pip_req maigret

# SIGIT -- social intelligence toolkit
clone_try SIGIT \
    https://github.com/termuxhackers-id/SIGIT \
    https://github.com/SIGIT/sigit
pip_req SIGIT

# holehe -- email to social media accounts OSINT
clone_try holehe \
    https://github.com/megadose/holehe
pip_req holehe

# X-osint -- full OSINT suite (phone, email, VIN, subdomain, reverse lookup)
clone_try X-osint \
    https://github.com/TermuxHackz/X-osint \
    https://github.com/AnonyminHack5/X-osint
pip_req X-osint

# GhostTrack -- phone number + location tracker
clone_try GhostTrack \
    https://github.com/HunxByts/GhostTrack \
    https://github.com/Theadvocate-bit/GhostTrack \
    https://github.com/Rintu-chowdory/GhostTrack
pip_req GhostTrack

# r4ven -- GPS location tracker + photo + IP capture
clone_try r4ven \
    https://github.com/spyboy-productions/r4ven \
    https://github.com/tupsonik/r4ven
pip_req r4ven

# seeker -- high accuracy location phishing/tracking
clone_try seeker \
    https://github.com/thewhiteh4t/seeker
pip_req seeker

# PhoneInfoga -- phone number OSINT (advanced)
clone_try PhoneInfoga \
    https://github.com/sundowndev/phoneinfoga \
    https://github.com/sundowndev/PhoneInfoga
pip_req PhoneInfoga

# CloakQuest3r -- Cloudflare origin IP finder
clone_try CloakQuest3r \
    https://github.com/spyboy-productions/CloakQuest3r
pip_req CloakQuest3r

# geo-recon -- GeoIP recon
clone_try geo-recon \
    https://github.com/radioactivetobi/geo-recon
pip_req geo-recon

# DIGI-NETRA -- digital footprint recon
clone_try DIGI-NETRA \
    https://github.com/TechnicalUserX/DIGI-NETRA \
    https://github.com/rly0nheart/octosuite
pip_req DIGI-NETRA

# Mohini -- Instagram recon
clone_try Mohini \
    https://github.com/termuxhackers-id/Mohini
pip_req Mohini

# OPRecon -- open source recon
clone_try OPRecon \
    https://github.com/Srevin/OPRecon \
    https://github.com/forrest-orr/OPRecon
pip_req OPRecon

ok "Stage 2 done"

# ── STAGE 3: Phishing / Social Engineering ───────────────────
hdr "STAGE 3 -- Phishing / Social Engineering"
# BlackEye -- multi-page phishing kit
clone_try BlackEye \
    https://github.com/KasRoudra/BlackEye-Phishing \
    https://github.com/thelinuxchoice/blackeye \
    https://github.com/An0nUD4Y/blackeye
pip_req BlackEye

# PyPhisher -- advanced phishing framework
clone_try PyPhisher \
    https://github.com/KasRoudra/PyPhisher
pip_req PyPhisher

# MaxPhisher -- max phishing pages
clone_try MaxPhisher \
    https://github.com/KasRoudra/MaxPhisher
pip_req MaxPhisher

# zphisher -- 30+ page phishing (most active)
clone_try zphisher \
    https://github.com/htr-tech/zphisher \
    https://github.com/HTR-Tech/zphisher
pip_req zphisher

# CamPhish -- camera phishing via fake page
clone_try CamPhish \
    https://github.com/techworm21/CamPhish \
    https://github.com/Raunaksplanet/CamPhish \
    https://github.com/ful1e5/CamPhish
pip_req CamPhish

# CiLocks -- location + camera phishing
clone_try CiLocks \
    https://github.com/tegal1337/CiLocks \
    https://github.com/darshannn10/CiLocks
pip_req CiLocks

# HiddenEye -- advanced phishing with live data
clone_try HiddenEye \
    https://github.com/DarkSecDevelopers/HiddenEye \
    https://github.com/DarkSecDevelopers/HiddenEye-Legacy
pip_req HiddenEye

# pwneye -- multi-platform phishing
clone_try pwneye \
    https://github.com/pwneye/pwneye \
    https://github.com/v0lk3N/pwneye
pip_req pwneye

# SocialPhish -- phishing toolkit
clone_try SocialPhish \
    https://github.com/UndeadSec/SocialPhish \
    https://github.com/aZtecSec/SocialPhish
pip_req SocialPhish

# GoPhish -- professional phishing framework
clone_try GoPhish \
    https://github.com/gophish/gophish
pip_req GoPhish

# instainsane -- Instagram brute force
clone_try instainsane \
    https://github.com/thelinuxchoice/instainsane \
    https://github.com/Ha3MrX/InstaBrute
pip_req instainsane

# SMSBomber -- SMS flooding (testing)
clone_try SMSBomber \
    https://github.com/TheSpeedX/TBomb \
    https://github.com/AvinashReddy3108/TBomb
pip_req SMSBomber

ok "Stage 3 done"

# ── STAGE 4: Network / Scanning ──────────────────────────────
hdr "STAGE 4 -- Network / Scanning"
# Nettacker -- network attack + scan framework
clone_try Nettacker \
    https://github.com/OWASP/Nettacker
pip_req Nettacker

# sqlmap -- SQL injection scanner
clone_try sqlmap \
    https://github.com/sqlmapproject/sqlmap
pip_req sqlmap

# evilwaf -- WAF detection and bypass
clone_try evilwaf \
    https://github.com/m4ll0k/evilwaf \
    https://github.com/Mister7F/evilwaf
pip_req evilwaf

# SARA -- automated recon assistant
clone_try SARA \
    https://github.com/termuxhackers-id/SARA \
    https://github.com/termuxhackers-id/sara
pip_req SARA

# XSStrike -- XSS scanner
clone_try XSStrike \
    https://github.com/s0md3v/XSStrike
pip_req XSStrike

# Striker -- offensive info + vulnerability scanner
clone_try Striker \
    https://github.com/s0md3v/Striker \
    https://github.com/BullsEye0/google_dork_list
pip_req Striker

# Sublist3r -- subdomain enumeration
clone_try Sublist3r \
    https://github.com/aboul3la/Sublist3r \
    https://github.com/hailsatan/Sublist3r
pip_req Sublist3r

# RouterSploit -- router exploitation framework
clone_try RouterSploit \
    https://github.com/threat9/routersploit \
    https://github.com/reverse-shell/routersploit
pip_req RouterSploit

# DNSx -- fast DNS toolkit
clone_try DNSx \
    https://github.com/projectdiscovery/dnsx
pip_req DNSx

ok "Stage 4 done"

# ── STAGE 5: Android / RAT ───────────────────────────────────
hdr "STAGE 5 -- Android / RAT"
# Evil-Droid -- Android payload + backdoor builder
clone_try Evil-Droid-master \
    https://github.com/M4sc3r4n0/Evil-Droid \
    https://github.com/itsMeALX/Evil-Droid
chmod +x "$BASE/Evil-Droid-master/evil-droid" >/dev/null 2>&1

# PhantomDroid -- Android RAT
clone_try PhantomDroid \
    https://github.com/phantom-droid/PhantomDroid \
    https://github.com/AngelSecurityTeam/PhantomDroid
pip_req PhantomDroid

# CamXploit -- camera exploitation
clone_try CamXploit \
    https://github.com/AngelSecurityTeam/Cam-Hackers \
    https://github.com/AngelSecurityTeam/CamXploit
pip_req CamXploit

# CAM-ACCE -- remote camera access
clone_try CAM-ACCE \
    https://github.com/AngelSecurityTeam/CAM-ACCE
pip_req CAM-ACCE

# PAGASUS-PRO -- Android remote access
clone_try PAGASUS-PRO \
    https://github.com/TechnicalUserX/PAGASUS-PRO \
    https://github.com/TechnicalUserX/PAGASUS
pip_req PAGASUS-PRO

# AhMyth -- Android RAT with GUI builder
clone_try AhMyth \
    https://github.com/AhMyth/AhMyth-Android-RAT \
    https://github.com/cybervaca/AhMyth-Android-RAT
pip_req AhMyth

# ghost -- multi-platform C2 / backdoor
clone_try ghost \
    https://github.com/EntySec/Ghost \
    https://github.com/entynetproject/ghost
pip_req ghost

ok "Stage 5 done"

# ── STAGE 6: Binary Tools ────────────────────────────────────
hdr "STAGE 6 -- Binary Tools"
# katana -- fast web crawler (pre-built binary)
if [ ! -x "$BASE/katana/katana" ]; then
    mkdir -p "$BASE/katana"
    if [ "$OS" = "alpine" ]; then
        KATA_URL="https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
    else
        KATA_URL="https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
    fi
    wget -q --timeout=30 -O /tmp/_katana.zip "$KATA_URL" >/dev/null 2>&1 && \
    unzip -q -o /tmp/_katana.zip -d "$BASE/katana" >/dev/null 2>&1 && \
    chmod +x "$BASE/katana/katana" >/dev/null 2>&1 && ok "katana ready" || warn "katana failed"
    rm -f /tmp/_katana.zip
else
    ok "katana present"
fi
# nuclei -- vulnerability scanner (binary)
if [ ! -x "$BASE/nuclei/nuclei" ]; then
    mkdir -p "$BASE/nuclei"
    NUCL_URL="https://github.com/projectdiscovery/nuclei/releases/download/v3.2.4/nuclei_3.2.4_linux_amd64.zip"
    wget -q --timeout=45 -O /tmp/_nuclei.zip "$NUCL_URL" >/dev/null 2>&1 && \
    unzip -q -o /tmp/_nuclei.zip -d "$BASE/nuclei" >/dev/null 2>&1 && \
    chmod +x "$BASE/nuclei/nuclei" >/dev/null 2>&1 && ok "nuclei ready" || warn "nuclei failed"
    rm -f /tmp/_nuclei.zip
else
    ok "nuclei present"
fi
ok "Stage 6 done"

# ── STAGE 7: Wordlists ───────────────────────────────────────
hdr "STAGE 7 -- Wordlists"
if [ ! -f "$BASE/rockyou.txt" ]; then
    if [ -f /usr/share/wordlists/rockyou.txt ]; then
        ln -sf /usr/share/wordlists/rockyou.txt "$BASE/rockyou.txt" && ok "rockyou linked"
    else
        log "Downloading rockyou.txt..."
        wget -q --timeout=60 -O "$BASE/rockyou.txt" \
            "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" >/dev/null 2>&1 && \
            ok "rockyou done" || warn "rockyou failed"
    fi
else
    ok "rockyou present"
fi
# SecLists -- common wordlists for fuzzing
if [ ! -d "$BASE/SecLists/.git" ]; then
    log "SecLists: cloning (partial -- common dirs only)..."
    git clone --depth=1 --filter=blob:none --sparse -q \
        https://github.com/danielmiessler/SecLists "$BASE/SecLists" >/dev/null 2>&1 && \
    git -C "$BASE/SecLists" sparse-checkout set Passwords/Common-Credentials Discovery/Web-Content >/dev/null 2>&1 && \
    ok "SecLists done" || warn "SecLists failed"
else
    ok "SecLists present"
fi
ok "Stage 7 done"

# ── STAGE 8: Menu ────────────────────────────────────────────
hdr "STAGE 8 -- Menu"
cat > "$BASE/menu.sh" << 'MENUEOF'
#!/bin/sh
B="$HOME/SocialEngineer"
CYN='\033[0;36m'; YLW='\033[1;33m'; GRN='\033[0;32m'; NC='\033[0m'
run() {
    [ -d "$B/$1" ] || { echo "not found: $1"; sleep 2; return; }
    cd "$B/$1" && eval "$2"; cd "$B"
}
while true; do
    clear
    printf "${CYN}+==========================================+\n|  RabiX Security Toolkit v9 Menu        |\n+==========================================${NC}\n"
    printf "${YLW}-- OSINT ----------------------------------${NC}\n"
    echo " [1]  Aliens_eye   [2]  Mr.Holmes    [3]  Osintgram"
    echo " [4]  sherlock     [5]  nexfil       [6]  maigret"
    echo " [7]  SIGIT        [8]  holehe       [9]  X-osint"
    echo " [10] GhostTrack   [11] r4ven        [12] seeker"
    echo " [13] PhoneInfoga  [14] CloakQuest3r [15] geo-recon"
    echo " [16] DIGI-NETRA   [17] Mohini       [18] OPRecon"
    printf "${YLW}-- Phishing / SE --------------------------${NC}\n"
    echo " [20] BlackEye     [21] PyPhisher    [22] MaxPhisher"
    echo " [23] zphisher     [24] CamPhish     [25] CiLocks"
    echo " [26] HiddenEye    [27] pwneye       [28] SocialPhish"
    echo " [29] GoPhish      [30] instainsane  [31] SMSBomber"
    printf "${YLW}-- Network / Scanning ---------------------${NC}\n"
    echo " [40] Nettacker    [41] sqlmap       [42] evilwaf"
    echo " [43] SARA         [44] XSStrike     [45] Striker"
    echo " [46] Sublist3r    [47] RouterSploit [48] katana"
    echo " [49] nuclei"
    printf "${YLW}-- Android / RAT --------------------------${NC}\n"
    echo " [50] Evil-Droid   [51] CamXploit    [52] PhantomDroid"
    echo " [53] CAM-ACCE     [54] PAGASUS-PRO  [55] AhMyth"
    echo " [56] ghost"
    printf "${YLW}-------------------------------------------${NC}\n"
    echo " [0] Exit"
    printf ">> "; read OPT
    case "$OPT" in
        1)  run Aliens_eye "python3 aliens_eye.py" ;;
        2)  run Mr.Holmes "python3 holmes.py" ;;
        3)  run Osintgram "python3 main.py" ;;
        4)  run sherlock "python3 sherlock" ;;
        5)  run nexfil "python3 nexfil.py" ;;
        6)  run maigret "python3 -m maigret" ;;
        7)  run SIGIT "python3 sigit.py" ;;
        8)  run holehe "python3 -m holehe" ;;
        9)  run X-osint "python3 xosint.py" ;;
        10) run GhostTrack "python3 GhostTR.py" ;;
        11) run r4ven "python3 r4ven.py" ;;
        12) run seeker "python3 seeker.py" ;;
        13) run PhoneInfoga "python3 -m phoneinfoga" ;;
        14) run CloakQuest3r "python3 CloakQuest3r.py" ;;
        15) run geo-recon "python3 geo-recon.py" ;;
        16) run DIGI-NETRA "python3 digi-netra.py" ;;
        17) run Mohini "python3 mohini.py" ;;
        18) run OPRecon "python3 oprecon.py" ;;
        20) run BlackEye "sh blackeye.sh" ;;
        21) run PyPhisher "python3 pyphisher.py" ;;
        22) run MaxPhisher "python3 maxphisher.py" ;;
        23) run zphisher "sh zphisher.sh" ;;
        24) run CamPhish "sh camphish.sh" ;;
        25) run CiLocks "python3 cilocks.py" ;;
        26) run HiddenEye "python3 HiddenEye.py" ;;
        27) run pwneye "python3 pwneye.py" ;;
        28) run SocialPhish "python3 SocialPhish.py" ;;
        29) run GoPhish "sh build.sh" ;;
        30) run instainsane "sh instainsane.sh" ;;
        31) run SMSBomber "python3 TBomb.py" ;;
        40) run Nettacker "python3 nettacker.py" ;;
        41) run sqlmap "python3 sqlmap.py" ;;
        42) run evilwaf "python3 evilwaf.py" ;;
        43) run SARA "python3 sara.py" ;;
        44) run XSStrike "python3 xsstrike.py" ;;
        45) run Striker "python3 striker.py" ;;
        46) run Sublist3r "python3 sublist3r.py" ;;
        47) run RouterSploit "python3 rsf.py" ;;
        48) [ -x "$B/katana/katana" ] && "$B/katana/katana" -h || echo "not installed"; sleep 2 ;;
        49) [ -x "$B/nuclei/nuclei" ] && "$B/nuclei/nuclei" -h || echo "not installed"; sleep 2 ;;
        50) run Evil-Droid-master "sh evil-droid" ;;
        51) run CamXploit "python3 camxploit.py" ;;
        52) run PhantomDroid "python3 phantomdroid.py" ;;
        53) run CAM-ACCE "python3 cam-acce.py" ;;
        54) run PAGASUS-PRO "python3 pagasus.py" ;;
        55) run AhMyth "python3 AhMyth.py" ;;
        56) run ghost "python3 ghost.py" ;;
        0)  exit 0 ;;
        *)  echo "invalid option"; sleep 1 ;;
    esac
done
MENUEOF
chmod +x "$BASE/menu.sh"
ok "menu.sh ready"

echo ""
echo "+======================================================+"
echo "| RabiX v9 install complete!                          |"
echo "| Run: sh ~/SocialEngineer/menu.sh                   |"
echo "+======================================================+"
