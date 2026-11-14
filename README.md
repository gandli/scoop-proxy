# scoop-proxy

[Scoop](https://scoop.sh) bucket for proxy tools.

Currently included:

| App | Description |
|---|---|
| [bowel](https://github.com/21stware/bowel) | a [mihomo](https://github.com/MetaCubeX/mihomo) client for macOS, Windows, Linux and Android |
| [mihomo](https://github.com/MetaCubeX/mihomo) | the mihomo (Clash Meta) core |
| [sing-box](https://github.com/SagerNet/sing-box) | the sing-box core |
| [xray](https://github.com/XTLS/Xray-core) | the Xray core |
| [v2rayN](https://github.com/2dust/v2rayN) | GUI client for Xray / sing-box / mihomo cores |
| [FlClash](https://github.com/chen08209/FlClash) | multi-platform mihomo GUI built with Flutter |
| [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev) | Clash Meta GUI based on Tauri |
| [Clash Party](https://clashparty.org/) | another Mihomo GUI |
| [Sparkle](https://github.com/xishang0128/sparkle) | Mihomo Party fork |
| [Clash Nyanpasu](https://github.com/libnyanpasu/clash-nyanpasu) | Clash GUI based on Tauri |
| [Karing](https://github.com/KaringX/karing) | cross-platform client compatible with Clash / Singbox / Shadowrocket subscriptions |
| [GUI.for.Clash](https://github.com/GUI-for-Cores/GUI.for.Clash) | lightweight Lua-based mihomo GUI |
| [GUI.for.SingBox](https://github.com/GUI-for-Cores/GUI.for.SingBox) | lightweight Lua-based sing-box GUI |
| [Throne](https://github.com/throneproj/Throne) | cross-platform GUI proxy utility powered by sing-box (Nekoray successor) |
| [Husi](https://github.com/xchacha20-poly1305/husi) | sing-box GUI client with bundled JBR runtime (64bit) |
| [SFW](https://sing-box.sagernet.org/clients/desktop/) | official Windows GUI client for sing-box |
| [v2ray](https://github.com/v2fly/v2ray-core) | the Project V v2ray core |
| [Clash.Mini](https://github.com/MetaCubeX/Clash.Mini) | a simple mihomo GUI |
| [Pandora-Box](https://github.com/snakem982/Pandora-Box) | a simple mihomo desktop client |
| [ClashMi](https://github.com/KaringX/clashmi) | Clash Mihomo for iOS/MacOS/Android/Windows/Linux (64bit) |
| [clashtui](https://github.com/JohanChane/clashtui) | mihomo / sing-box TUI client |
| [Tailscale](https://tailscale.com) | WireGuard-based mesh VPN (requires admin) |
| [NetBird](https://netbird.io/) | WireGuard-based overlay network with SSO/MFA |
| [UU Remote 网易UU远程](https://uuyc.163.com/) | NetEase remote desktop access and control tool (requires admin) |

Versions are kept current by the daily auto-update workflow; check exact versions with `scoop search` or `scoop status`.

## Usage

```powershell
scoop bucket add proxy https://github.com/gandli/scoop-proxy
scoop install proxy/bowel proxy/mihomo proxy/v2rayn
```

Manifests support 64bit and arm64 Windows (where available) and auto-update from GitHub releases.
