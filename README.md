# scoop-proxy

[Scoop](https://scoop.sh) bucket for proxy tools.

Currently included:

| App | Version | Description |
|---|---|---|
| [bowel](https://github.com/21stware/bowel) | 0.4.3 | a [mihomo](https://github.com/MetaCubeX/mihomo) client for macOS, Windows, Linux and Android |
| [mihomo](https://github.com/MetaCubeX/mihomo) | 1.19.34 | the mihomo (Clash Meta) core |
| [sing-box](https://github.com/SagerNet/sing-box) | 1.14.4 | the sing-box core |
| [xray](https://github.com/XTLS/Xray-core) | 26.11.9 | the Xray core |
| [v2rayN](https://github.com/2dust/v2rayN) | 7.25.6 | GUI client for Xray / sing-box / mihomo cores |
| [FlClash](https://github.com/chen08209/FlClash) | 0.9.3 | multi-platform mihomo GUI built with Flutter |
| [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) | 2.5.10 | Clash Meta GUI based on Tauri |
| [Clash Party](https://clashparty.org/) | 2.0.4 | another Mihomo GUI |
| [Sparkle](https://github.com/xishang0128/sparkle) | 1.26.10 | Mihomo Party fork |
| [Clash Nyanpasu](https://github.com/libnyanpasu/clash-nyanpasu) | 2.0.1 | Clash GUI based on Tauri |
| [Karing](https://github.com/KaringX/karing) | 1.2.26.2931 | cross-platform client compatible with Clash / Singbox / Shadowrocket subscriptions |
| [GUI.for.Clash](https://github.com/GUI-for-Cores/GUI.for.Clash) | 1.29.0 | lightweight Lua-based mihomo GUI |
| [GUI.for.SingBox](https://github.com/GUI-for-Cores/GUI.for.SingBox) | 1.29.0 | lightweight Lua-based sing-box GUI |
| [Throne](https://github.com/throneproj/Throne) | 1.4.1 | cross-platform GUI proxy utility powered by sing-box (Nekoray successor) |
| [Husi](https://github.com/xchacha20-poly1305/husi) | 2.3.4 | sing-box GUI client with bundled JBR runtime (64bit) |
| [SFW](https://sing-box.sagernet.org/clients/desktop/) | 1.14.4 | official Windows GUI client for sing-box |
| [v2ray](https://github.com/v2fly/v2ray-core) | 5.53.0 | the Project V v2ray core |
| [Clash.Mini](https://github.com/MetaCubeX/Clash.Mini) | 0.2.2 | a simple mihomo GUI |
| [Pandora-Box](https://github.com/snakem982/Pandora-Box) | 1.0.26 | a simple mihomo desktop client |
| [ClashMi](https://github.com/KaringX/clashmi) | 1.0.32.1803 | Clash Mihomo for iOS/MacOS/Android/Windows/Linux (64bit) |
| [clashtui](https://github.com/JohanChane/clashtui) | 0.3.1 | mihomo / sing-box TUI client |
| [Tailscale](https://tailscale.com) | 1.104.7 | WireGuard-based mesh VPN (requires admin) |

## Usage

```powershell
scoop bucket add proxy https://github.com/gandli/scoop-proxy
scoop install proxy/bowel proxy/mihomo proxy/v2rayn
```

Manifests support 64bit and arm64 Windows (where available) and auto-update from GitHub releases.
