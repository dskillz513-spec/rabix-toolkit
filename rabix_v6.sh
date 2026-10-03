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
    log "Alpine Linux"
    sed -i 's|^#\(.*community\)|\1|g' /etc/apk/repositories 2>/dev/null
    apk update -q 2>/dev/null
elif command -v apt-get >/dev/null 2>&1; then
    OS=debian
    log "Debian/Kali"
    apt-get update -qq 2>/dev/null
else
    OS=unknown
    warn "No known package manager"
fi
if [ "$(id -u)" = "0" ]; then
    S=""
    PIPF="--break-system-packages -q"
else
    S="sudo"
    PIPF="-q --user"
fi
BASE="$HOME/SocialEngineer"
mkdir -p "$BASE"
pkg() {
    if [ "$OS" = "alpine" ]; then
        $S apk add -q "$1" >/dev/null 2>&1 && ok "$1" || warn "$1 skipped"
    elif [ "$OS" = "debian" ]; then
        $S apt-get install -y -qq "$2" >/dev/null 2>&1 && ok "$2" || warn "$2 skipped"
    fi
}
clone_tool() {
    if [ -d "$BASE/$1/.git" ]; then
        git -C "$BASE/$1" pull -q 2>/dev/null && ok "$1 updated" || warn "$1 pull failed"
    else
        log "$1: cloning..."
        git clone --depth=1 -q "$2" "$BASE/$1" 2>/dev/null && ok "$1 cloned" || warn "$1 clone FAILED"
    fi
}
clone_try() {
    NAME="$1"; shift
    if [ -d "$BASE/$NAME/.git" ]; then
        git -C "$BASE/$NAME" pull -q 2>/dev/null && ok "$NAME updated" || warn "$NAME pull failed"
        return
    fi
    log "$NAME: cloning..."
    for URL in "$@"; do
        git clone --depth=1 -q "$URL" "$BASE/$NAME" 2>/dev/null && ok "$NAME cloned" && return
    done
    warn "$NAME clone FAILED (all URLs tried)"
}
pip_req() {
    REQ="$BASE/$1/requirements.txt"
    [ -f "$REQ" ] || return 0
    pip3 install $PIPF -r "$REQ" 2>/dev/null || pip3 install --break-system-packages -q -r "$REQ" 2>/dev/null || warn "$1 pip failed"
}
clear
echo "+======================================================+"
echo "| RabiX Security Toolkit v6 -- Universal              |"
echo "| OSINT  Phishing  RAT  Recon  Social Engineer        |"
echo "+======================================================+"
hdr "STAGE 1 -- System Dependencies"
pkg python3 python3
pkg py3-pip python3-pip
pkg git git
pkg curl curl
pkg wget wget
pkg unzip unzip
pkg openssh-client openssh-client
pkg nmap nmap
pkg build-base build-essential
pkg tor tor
pkg proxychains-ng proxychains4
pkg jq jq
pkg whois whois
pkg bind-tools dnsutils
pkg net-tools net-tools
pkg openssl-dev libssl-dev
pkg curl-dev libcurl4-openssl-dev
pkg libpcap-dev libpcap-dev
if [ "$OS" = "alpine" ]; then
    apk add -q php83 >/dev/null 2>&1 || apk add -q php82 >/dev/null 2>&1 || apk add -q php8 >/dev/null 2>&1 || warn "php skipped"
    ok "php"
else
    $S apt-get install -y -qq php >/dev/null 2>&1 && ok "php" || warn "php skipped"
fi
if [ "$OS" = "alpine" ]; then
    command -v masscan >/dev/null 2>&1 && ok "masscan" || {
        log "Building masscan..."
        apk add -q gcc make libpcap-dev linux-headers >/dev/null 2>&1
        git clone -q --depth=1 https://github.com/robertdavidgraham/masscan /tmp/_mc >/dev/null 2>&1 && make -C /tmp/_mc -j2 -s >/dev/null 2>&1 && install -m755 /tmp/_mc/bin/masscan /usr/local/bin/ >/dev/null 2>&1 && ok "masscan built" || warn "masscan failed"
        rm -rf /tmp/_mc
    }
else
    $S apt-get install -y -qq masscan >/dev/null 2>&1 && ok "masscan" || warn "masscan skipped"
fi
ok "Stage 1 done"
hdr "STAGE 2 -- OSINT Tools"
clone_try Aliens_eye \
    https://github.com/ItsMeALX/Aliens-Eye \
    https://github.com/HusnainAslam/aliens-eye \
    https://github.com/Prithiviraajan/Aliens-Eye
pip_req Aliens_eye
clone_try Mr.Holmes \
    https://github.com/Lucksi/Mr.Holmes
pip_req Mr.Holmes
clone_try Osintgram \
    https://github.com/Datalux/Osintgram
pip_req Osintgram
clone_try hound \
    https://github.com/Ryuzakixiao/hound \
    https://github.com/kaiiyer/hound
pip_req hound
clone_tool geo-recon https://github.com/radioactivetobi/geo-recon
pip_req geo-recon
clone_try SIGIT \
    https://github.com/termuxhackers-id/SIGIT
pip_req SIGIT
clone_tool OPRecon https://github.com/Srevin/OPRecon
pip_req OPRecon
clone_try DIGI-NETRA \
    https://github.com/TechnicalUserX/DIGI-NETRA \
    https://github.com/rly0nheart/octosuite
pip_req DIGI-NETRA
clone_try Mohini \
    https://github.com/termuxhackers-id/Mohini
pip_req Mohini
clone_try sherlock \
    https://github.com/sherlock-project/sherlock
pip_req sherlock
clone_try nexfil \
    https://github.com/thewhiteh4t/nexfil
pip_req nexfil
clone_try maigret \
    https://github.com/soxoj/maigret
pip_req maigret
ok "Stage 2 done"
hdr "STAGE 3 -- Phishing / SE"
clone_try BlackEye \
    https://github.com/KasRoudra/BlackEye-Phishing \
    https://github.com/thelinuxchoice/blackeye \
    https://github.com/An0nUD4Y/blackeye
pip_req BlackEye
clone_try PyPhisher \
    https://github.com/KasRoudra/PyPhisher \
    https://github.com/KasRoudra/MaxPhisher
pip_req PyPhisher
clone_try MaxPhisher \
    https://github.com/KasRoudra/MaxPhisher
pip_req MaxPhisher
clone_try CamPhish \
    https://github.com/techworm21/CamPhish \
    https://github.com/Raunaksplanet/CamPhish \
    https://github.com/ful1e5/CamPhish
pip_req CamPhish
clone_try seeker \
    https://github.com/thewhiteh4t/seeker
pip_req seeker
clone_try CiLocks \
    https://github.com/tegal1337/CiLocks
pip_req CiLocks
clone_try instainsane \
    https://github.com/thelinuxchoice/instainsane \
    https://github.com/Ha3MrX/InstaBrute
pip_req instainsane
clone_try pwneye \
    https://github.com/pwneye/pwneye
pip_req pwneye
clone_try HiddenEye \
    https://github.com/DarkSecDevelopers/HiddenEye \
    https://github.com/DarkSecDevelopers/HiddenEye-Legacy
pip_req HiddenEye
clone_try zphisher \
    https://github.com/htr-tech/zphisher
pip_req zphisher
ok "Stage 3 done"
hdr "STAGE 4 -- Network / Scanning"
clone_tool Nettacker https://github.com/OWASP/Nettacker
pip_req Nettacker
clone_tool evilwaf https://github.com/m4ll0k/evilwaf
pip_req evilwaf
clone_try SARA \
    https://github.com/termuxhackers-id/SARA
pip_req SARA
clone_try port-scanner \
    https://github.com/Buildbyallan/port-scanner \
    https://github.com/danrobe/port-scanner
clone_tool RabiX-Port-Scanner https://github.com/rabixsecurity/RabiX-Port-Scanner
ok "Stage 4 done"
hdr "STAGE 5 -- Android / RAT"
clone_try Evil-Droid-master \
    https://github.com/M4sc3r4n0/Evil-Droid \
    https://github.com/itsMeALX/Evil-Droid
chmod +x "$BASE/Evil-Droid-master/evil-droid" 2>/dev/null
clone_try PhantomDroid \
    https://github.com/phantom-droid/PhantomDroid \
    https://github.com/AngelSecurityTeam/PhantomDroid
pip_req PhantomDroid
clone_try CamXploit \
    https://github.com/AngelSecurityTeam/Cam-Hackers \
    https://github.com/AngelSecurityTeam/CamXploit
pip_req CamXploit
clone_try CAM-ACCE \
    https://github.com/AngelSecurityTeam/CAM-ACCE \
    https://github.com/AngelSecurityTeam/CamXploit
pip_req CAM-ACCE
clone_try PAGASUS-PRO \
    https://github.com/TechnicalUserX/PAGASUS-PRO \
    https://github.com/TechnicalUserX/PAGASUS
pip_req PAGASUS-PRO
ok "Stage 5 done"
hdr "STAGE 6 -- katana"
if [ ! -x "$BASE/katana/katana" ]; then
    mkdir -p "$BASE/katana"
    wget -q --timeout=30 -O /tmp/_katana.zip "https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip" && unzip -q -o /tmp/_katana.zip -d "$BASE/katana" && chmod +x "$BASE/katana/katana" && ok "katana ready" && rm -f /tmp/_katana.zip || warn "katana failed"
else
    ok "katana present"
fi
hdr "STAGE 7 -- Wordlists"
if [ ! -f "$BASE/rockyou.txt" ]; then
    if [ -f /usr/share/wordlists/rockyou.txt ]; then
        ln -sf /usr/share/wordlists/rockyou.txt "$BASE/rockyou.txt" && ok "rockyou linked"
    else
        log "Downloading rockyou.txt..."
        wget -q --timeout=60 -O "$BASE/rockyou.txt" "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" && ok "rockyou done" || warn "rockyou failed"
    fi
else
    ok "rockyou present"
fi
hdr "STAGE 8 -- Menu"
cat > "$BASE/menu.sh" << 'MENUEOF'
#!/bin/sh
B="$HOME/SocialEngineer"
CYN='\033[0;36m'; YLW='\033[1;33m'; NC='\033[0m'
run() {
    [ -d "$B/$1" ] || { echo "not found: $1"; sleep 2; return; }
    cd "$B/$1" && eval "$2"; cd "$B"
}
while true; do
    clear
    printf "${CYN}+=====================================+\n|  RabiX Security Toolkit v6 Menu    |\n+=====================================${NC}\n"
    printf "${YLW}-- OSINT --------${NC}\n"
    echo " [1] Aliens_eye  [2] Mr.Holmes   [3] Osintgram"
    echo " [4] hound       [5] geo-recon   [6] SIGIT"
    echo " [7] DIGI-NETRA  [8] Mohini      [9] sherlock"
    echo " [10] nexfil     [11] maigret"
    printf "${YLW}-- Phishing -----${NC}\n"
    echo " [20] BlackEye   [21] PyPhisher  [22] MaxPhisher"
    echo " [23] CamPhish   [24] seeker     [25] CiLocks"
    echo " [26] instainsane [27] pwneye    [28] HiddenEye"
    echo " [29] zphisher"
    printf "${YLW}-- Network ------${NC}\n"
    echo " [40] Nettacker  [41] evilwaf    [42] SARA"
    echo " [43] katana"
    printf "${YLW}-- RAT ----------${NC}\n"
    echo " [50] Evil-Droid [51] CamXploit  [52] PhantomDroid"
    echo " [53] PAGASUS-PRO"
    echo " [0] Exit"
    printf ">> "; read OPT
    case "$OPT" in
        1)  run Aliens_eye "python3 aliens_eye.py" ;;
        2)  run Mr.Holmes "python3 holmes.py" ;;
        3)  run Osintgram "python3 main.py" ;;
        4)  run hound "python3 hound.py" ;;
        5)  run geo-recon "python3 geo-recon.py" ;;
        6)  run SIGIT "python3 sigit.py" ;;
        7)  run DIGI-NETRA "python3 digi-netra.py" ;;
        8)  run Mohini "python3 mohini.py" ;;
        9)  run sherlock "python3 sherlock" ;;
        10) run nexfil "python3 nexfil.py" ;;
        11) run maigret "python3 -m maigret" ;;
        20) run BlackEye "sh blackeye.sh" ;;
        21) run PyPhisher "python3 pyphisher.py" ;;
        22) run MaxPhisher "python3 maxphisher.py" ;;
        23) run CamPhish "sh camphish.sh" ;;
        24) run seeker "python3 seeker.py" ;;
        25) run CiLocks "python3 cilocks.py" ;;
        26) run instainsane "sh instainsane.sh" ;;
        27) run pwneye "python3 pwneye.py" ;;
        28) run HiddenEye "python3 HiddenEye.py" ;;
        29) run zphisher "sh zphisher.sh" ;;
        40) run Nettacker "python3 nettacker.py" ;;
        41) run evilwaf "python3 evilwaf.py" ;;
        42) run SARA "python3 sara.py" ;;
        43) [ -x "$B/katana/katana" ] && "$B/katana/katana" -h || echo "not installed"; sleep 2 ;;
        50) run Evil-Droid-master "sh evil-droid" ;;
        51) run CamXploit "python3 camxploit.py" ;;
        52) run PhantomDroid "python3 phantomdroid.py" ;;
        53) run PAGASUS-PRO "python3 pagasus.py" ;;
        0)  exit 0 ;;
        *)  echo "invalid"; sleep 1 ;;
    esac
done
MENUEOF
chmod +x "$BASE/menu.sh"
ok "menu.sh ready"
echo ""
echo "Done. Run: sh ~/SocialEngineer/menu.sh"
