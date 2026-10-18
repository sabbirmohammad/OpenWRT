# 🛡️ ArcherGuard — OpenWrt Enterprise Management & Captive Portal Ecosystem

<div align="center">

[![OpenWrt](https://img.shields.io/badge/OpenWrt-23.05+-00B2EE?logo=openwrt&logoColor=white)](https://openwrt.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Vercel](https://img.shields.io/badge/Vercel-Serverless-black?logo=vercel&logoColor=white)](https://vercel.com/)
[![Upstash Redis](https://img.shields.io/badge/Upstash-Redis-red?logo=redis&logoColor=white)](https://upstash.com/)
[![Telegram Bot](https://img.shields.io/badge/Telegram-Bot%20API-2CA5E0?logo=telegram&logoColor=white)](https://core.telegram.org/bots/api)
[![WireGuard](https://img.shields.io/badge/VPN-WireGuard-88171A?logo=wireguard&logoColor=white)](https://www.wireguard.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**A high-performance, production-grade network control suite connecting OpenWrt routers with an interactive Telegram Bot authorization bridge, a serverless command queue, and a Flutter mobile management dashboard.**

[Overview](#-system-overview) • [Architecture](#-system-architecture) • [Mobile App](#-archerguard-mobile-dashboard) • [Quick Start](#-quick-start--deployment-guide) • [Router Setup](#-openwrt-router-configuration) • [Security](#-security-hardening) • [License](#-license)

</div>

---

## 🌟 System Overview

ArcherGuard transforms an OpenWrt router (specifically optimized for MediaTek MT7621 / TP-Link Archer C6 v3/v4 and generic OpenWrt 23.05+ hardware) into a centrally managed network hub with three interconnected pillars:

1. **⚡ OpenWrt Router Core (`router/`)**
   - **openNDS Captive Portal with FAS:** Intercepts untrusted Wi-Fi clients and forwards them for authorization.
   - **Instant Layer-2 Disconnect:** Radio kick hooks (`ubus call hostapd.* del_client`) force client devices to drop Wi-Fi instantly when expired or revoked.
   - **Microservice Shell API (`router/lib/`):** Lightweight POSIX shell CGI endpoints for real-time telemetry, CAKE SQM QoS, MediaTek hardware NAT offloading, and dynamic iptables firewall rules.
   - **Automated WireGuard VPN:** On-router Curve25519 cryptographic key generation and QR-code client config creator for secure remote administration.

2. **☁️ Serverless Cloud Bridge (`api/` & `public/`)**
   - **Telegram Bot Control Center:** Interactive approval prompts with custom durations (30m, 1h, 3h, unlimited), bandwidth throttling, device aliasing, and Bengali/English command parsing.
   - **Web Admin Console (`/admin`):** Responsive web interface for desktop network oversight and manual device whitelisting.
   - **Upstash Redis Queue:** High-throughput serverless command queue decoupling router polling from webhook executions.

3. **📱 ArcherGuard Mobile Dashboard (`mobile_app/`)**
   - **Cyberpunk Glossy Dark UI:** Responsive Flutter dashboard with custom hardware gauges and live sparkline traffic monitors.
   - **Network Acceleration Tuning:** 1-tap toggles for CAKE SQM queue disciplines, Flow Offloading, and DoH (DNS over HTTPS).
   - **Wi-Fi Radio Inspector:** Detailed 2.4GHz / 5GHz channels, Fast Roaming (802.11r), PMF (802.11w), and Router LED Stealth Mode.

---

## 🏗 System Architecture

```
                    ┌─────────────────────────┐
                    │      Client Device      │
                    │   (Connects to Wi-Fi)   │
                    └────────────┬────────────┘
                                 │ 1. Intercept & Redirect to Portal
                                 ▼
                    ┌─────────────────────────┐
                    │   OpenWrt Captive Portal│
                    │      (openNDS FAS)      │
                    └────────────┬────────────┘
                                 │ 2. Opens Portal URL (?fas=<base64>)
                                 ▼
                    ┌─────────────────────────┐
                    │     Vercel Cloud App    │
                    │   public/index.html     │
                    └────────────┬────────────┘
                                 │ 3. POST /api/request { name, mac }
                                 ▼
           ┌───────────────────────────────────────┐
           │                                       │
           ▼                                       ▼
┌─────────────────────────┐             ┌─────────────────────────┐
│    Telegram Bot API     │             │    Admin Web Console    │
│  (Interactive Prompt)   │             │  /admin (Browser UI)    │
└────────────┬────────────┘             └────────────┬────────────┘
             │                                       │
     4a. Admin Clicks Button                 4b. Admin Clicks Accept
   [30m] [1h] [Unlimited] [Reject]         [30m] [1h] [3h] [Unlimited]
             │                                       │
             ▼                                       ▼
┌─────────────────────────┐             ┌─────────────────────────┐
│    Telegram Webhook     │             │    Admin API Handler    │
│       api/webhook       │             │       api/admin.js      │
└────────────┬────────────┘             └────────────┬────────────┘
             │ 5a. RPUSH ndsctl command              │ 5b. RPUSH ndsctl command
             └───────────────────┬───────────────────┘
                                 ▼
                    ┌─────────────────────────┐
                    │   Upstash Redis Queue   │
                    │   [pending_commands]    │
                    └────────────▲────────────┘
                                 │
                 6. LPOP every 5s via /api/poll
                    (x-router-secret authenticated)
                                 │
     ┌───────────────────────────┴───────────────────────────┐
     │                                                       │
     ▼                                                       ▼
┌─────────────────────────┐             ┌─────────────────────────┐
│   OpenWrt Router Script │             │   ArcherGuard Mobile    │
│      router/sync.sh     │             │   Flutter App (LAN/VPN) │
└────────────┬────────────┘             └────────────┬────────────┘
             │ 7. Executes:                          │ Direct CGI REST API:
             │    - ndsctl auth <MAC> <MINUTES>      │ - Hardware vitals & telemetry
             │    - hostapd del_client (kick)        │ - SQM & Wi-Fi radio controls
             ▼                                       │ - Device blocking & firewall
┌─────────────────────────┐                          │
│   Client Device State   │◄─────────────────────────┘
│  INTERNET ACCESS GRANTED│
└─────────────────────────┘
```

---

## 📱 ArcherGuard Mobile Dashboard

The companion mobile application (`mobile_app/`) is built using **Flutter & Dart** with an immersive dark cyberpunk aesthetic. It connects directly to the OpenWrt router over local Wi-Fi or securely over a WireGuard VPN tunnel.

| Feature | Capabilities |
| :--- | :--- |
| **System Vitals** | Real-time CPU core loads, RAM allocation, internal flash storage, and system uptime. |
| **Traffic Analytics** | Live upload/download Mbps speedometer, sparkline charts, and monthly data quota monitoring. |
| **Device Controller** | Detailed client table (hostnames, MACs, signal dBm, connected frequency) with 1-tap firewall block. |
| **Radio & Wi-Fi** | Toggle 2.4GHz / 5GHz radios, guest network isolation, TX power adjustments, 802.11r/w features. |
| **Network Acceleration**| CAKE / FQ_CoDel SQM latency tuning, MediaTek MT7621 hardware flow offloading, and DNS presets. |
| **Stealth Mode** | Instantly turn off all router hardware LEDs for bedroom or nighttime operation. |

---

## 📁 Repository Structure

```
├── api/                     # Vercel Serverless API Endpoints
│   ├── admin.js             # Web Admin Console backend (requests, manual auth, queue)
│   ├── confirm-auth.js      # Captive portal authorization verification
│   ├── deauth.js            # Direct client deauthentication endpoint
│   ├── login.js             # FAS token decoder and pending session registrar
│   ├── pending-auth.js      # Polling target for pending client MAC addresses
│   ├── poll.js              # Secret-authenticated router command queue dispatcher
│   ├── request.js           # Portal submission handler (dispatches Telegram prompt)
│   ├── status.js            # Network state & client statistics endpoint
│   ├── voucher.js           # Guest voucher passcode generator and verification
│   └── webhook.js           # Telegram bot webhook (menu commands & callback queries)
├── lib/                     # Serverless business logic & Telegram utilities
│   ├── bot-menu.js          # Telegram keyboards, cards, and formatting engine
│   ├── opennds.js           # openNDS FAS token decoding & MAC normalizers
│   └── router/safety.js     # Command whitelist validator & timing-safe security guards
├── mobile_app/              # ArcherGuard Flutter Mobile Application
│   ├── lib/core/            # Glossy theme, colors, and API HTTP client services
│   ├── lib/models/          # Immutable JSON models for router telemetry and clients
│   └── lib/presentation/    # Dashboard, Network, Devices, Firewall & Security screens
├── public/                  # Static Web Assets
│   ├── admin.html           # Standalone Web Admin Console
│   └── index.html           # High-conversion responsive captive portal landing page
├── router/                  # OpenWrt Router POSIX Shell Scripts
│   ├── archer_c6_helper.sh  # LED and hardware pin diagnostics for MediaTek MT7621
│   ├── binauth.sh           # openNDS session expiry event hook
│   ├── deploy.sh            # Automated router deployment & service installer
│   ├── opennds_sync.init    # OpenWrt procd service definition (/etc/init.d/opennds_sync)
│   ├── setup_wireguard.sh   # Automated WireGuard VPN server & client QR-code setup
│   ├── sync.conf.example    # Router configuration template (/etc/opennds/sync.conf)
│   ├── sync.sh              # Background command polling daemon with radio kick logic
│   └── lib/                 # Modular CGI-bin shell handlers (metrics, actions, analytics)
├── docs/specifications/     # Architecture designs and detailed component specifications
├── test/                    # Automated Test Suite (149+ Unit & Shell Tests)
├── .env.example             # Environment variables blueprint
└── vercel.json              # Vercel serverless routing and cache headers
```

---

## 🚀 Quick Start & Deployment Guide

### 1. Telegram Bot Setup
1. Message [@BotFather](https://t.me/BotFather) on Telegram and send `/newbot`.
2. Name your bot and copy the **HTTP API Bot Token** (`TELEGRAM_BOT_TOKEN`).
3. Get your Telegram Chat ID:
   - Message your new bot or [@userinfobot](https://t.me/userinfobot) to find your numeric ID (`TELEGRAM_CHAT_ID`).
   - For an administrative group/channel, add the bot as admin and retrieve the group ID (starts with `-100`).

### 2. Upstash Redis Setup
1. Create a free database at [Upstash Redis](https://console.upstash.com/).
2. Under **REST API**, copy:
   - `UPSTASH_REDIS_REST_URL`
   - `UPSTASH_REDIS_REST_TOKEN`

### 3. Generate Router Secret Key
Generate a cryptographically secure random token:
```bash
openssl rand -hex 24
```
Keep this string for `ROUTER_SECRET_KEY`.

### 4. Deploy Cloud Bridge to Vercel
Deploy using the Vercel CLI or connect your GitHub repository:
```bash
npm i -g vercel
vercel
```

In your Vercel Project Settings (**Settings → Environment Variables**), set:
- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_CHAT_ID`
- `UPSTASH_REDIS_REST_URL`
- `UPSTASH_REDIS_REST_TOKEN`
- `ROUTER_SECRET_KEY`
- `ADMIN_PASSWORD` *(Optional; protects `/admin` console, falls back to `ROUTER_SECRET_KEY`)*

### 5. Register the Telegram Webhook
Point Telegram to your deployed Vercel domain:
```bash
curl -X POST "https://api.telegram.org/bot<YOUR_TELEGRAM_BOT_TOKEN>/setWebhook" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://<your-vercel-domain>.vercel.app/api/webhook"}'
```

Verify status anytime:
```bash
curl "https://api.telegram.org/bot<YOUR_TELEGRAM_BOT_TOKEN>/getWebhookInfo"
```

---

## 📡 OpenWrt Router Configuration

### 1. Configure openNDS FAS
SSH into your OpenWrt router and configure `/etc/config/opennds`:
```uci
config opennds
    option enabled '1'
    option allow_preemptive_authentication '1'
    option fasremotefqdn 'your-domain.vercel.app'
    option fasport '443'
    option faspath '/'
    option fas_secure_enabled '1'
    option faskey 'none'
```

Disable IPv6 router advertisements on the captive interface to prevent loopbacks:
```sh
uci set dhcp.lan.ra='disabled'
uci set dhcp.lan.dhcpv6='disabled'
uci commit dhcp
/etc/init.d/odhcpd restart
/etc/init.d/opennds restart
```

### 2. Install Sync Polling Daemon
Install dependencies on OpenWrt:
```sh
opkg update
opkg install curl
```

Deploy the sync daemon:
1. Copy `router/sync.sh` to `/usr/bin/opennds_sync.sh` on the router:
   ```sh
   chmod +x /usr/bin/opennds_sync.sh
   ```
2. Create `/etc/opennds/sync.conf`:
   ```sh
   mkdir -p /etc/opennds
   cat << 'EOF' > /etc/opennds/sync.conf
   API_URL="https://your-domain.vercel.app/api/poll"
   ROUTER_SECRET_KEY="your_shared_secret_key_matching_vercel"
   POLL_INTERVAL=5
   LOG_TAG="opennds-sync"
   EOF
   ```
3. Install and start the background `procd` service:
   ```sh
   cp router/opennds_sync.init /etc/init.d/opennds_sync
   chmod +x /etc/init.d/opennds_sync
   /etc/init.d/opennds_sync enable
   /etc/init.d/opennds_sync start
   ```

Check router logs:
```sh
logread -e opennds-sync
```

### 3. Automated WireGuard Remote Setup
To securely connect the **ArcherGuard Mobile App** to your router from anywhere without opening public ports:
```sh
chmod +x router/setup_wireguard.sh
/bin/sh router/setup_wireguard.sh
```
The script automatically configures interface `wg0`, configures firewall forwarding, and displays a terminal QR code to import directly into your mobile device.

---

## 🔒 Security Hardening

- **Anti-Brick Command Filter:** `router/sync.sh` strictly enforces an allowlist (`ndsctl auth <MAC> <MINUTES>` and `ndsctl deauth <MAC>`). Arbitrary commands or shell injection characters (`;`, `&&`, `|`, `` ` ``, `$`) are actively blocked and logged.
- **Timing-Safe Crypto:** Endpoints use constant-time comparisons (`crypto.timingSafeEqual`) to eliminate side-channel timing attacks on router secrets.
- **Strict Environment Isolation:** No hardcoded secrets or backdoors are stored in the codebase; all operational tokens are injected via environment variables or `/etc/opennds/sync.conf`.
- **Layer-2 Client Deauth:** Immediate radio deauthentication via `hostapd` ubus ensures devices cannot remain in zombie connection states after session expiry.
- **No-Store Edge Cache:** All polling endpoints send `Cache-Control: no-store` headers to prevent intermediate proxies from caching sensitive command queue messages.

---

## 🧪 Testing

The repository includes a comprehensive automated test suite covering API endpoints, Telegram webhook parsing, FAS token decoding, and POSIX shell security validation:

```bash
# Run all unit tests & shell script validators
npm test
```

---

## 📜 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more details.
