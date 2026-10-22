# airgeddon-plugins

Community plugins for [airgeddon](https://github.com/v1s1t0r1sh3r3/airgeddon),
maintained independently so that plugins can be fixed here and re-submitted
upstream regardless of airgeddon's release timing. Each plugin is also
submitted upstream to airgeddon's own `plugins/` directory via pull request;
this repository is the canonical home where development happens first.

---

## EvilQR

**A WiFi join QR code generator for airgeddon's Evil Twin attacks.**

### What the plugin does

airgeddon's Evil Twin attacks traditionally rely on deauthentication to herd
victims onto the rogue access point: kick the client off the real network
and hope it (or its user) wanders onto your twin. EvilQR adds a second,
**silent association vector** — the moment airgeddon launches the fake access
point, the plugin renders a scannable QR code (directly in the terminal,
plus a PNG file) containing the standard `WIFI:` network-configuration
payload that the built-in cameras of Android and iOS understand:

```
WIFI:S:<evil twin ESSID>;T:nopass;;
```

A victim who scans the code with a stock phone camera joins the Evil Twin
**immediately and with zero interaction** — no password prompt (airgeddon's
evil twin is an open AP), no network list, no deauth required. Print the QR
on a sticker, display it on a screen, embed it in a page: any context where
a human might point a phone at a square code becomes an association
opportunity.

Technical details worth knowing:

- **The zero-width space is preserved.** airgeddon distinguishes the twin
  from the original network by appending an invisible zero-width space
  (U+200B) to the target ESSID (`generate_fake_essid`). EvilQR carries the
  ESSID verbatim — invisible character included — so a scanning phone joins
  the **Evil Twin**, not the legitimate access point. Strip that character
  and the phone would silently join the real network instead.
- **Special characters are escaped.** The `WIFI:` payload format reserves
  `\ ; , : "` — all are backslash-escaped, so twin ESSIDs cloned from
  real-world SSIDs decode correctly.
- **PNG output.** The QR is also saved as `evilqr_<essid>.png` in the
  directory airgeddon was launched from (next to airgeddon's other attack
  outputs), for use outside the terminal.
- **WPA-Enterprise awareness.** airgeddon's enterprise (hostapd-wpe) evil
  twin mode doesn't fit the `WIFI:` join format, so the plugin detects it
  and skips generation with a notice instead of producing a broken code.
- **Multilingual.** Strings ship in English and Spanish through airgeddon's
  plugin language hook; more languages can be added with one line each
  (see [Development](#development) below).

### How to use it

1. **Install the plugin** (see the distro table below).
2. **Install `qrencode`** — the only dependency. If it's missing, the
   plugin prints a warning and the attack proceeds normally without the QR.
3. Run `sudo airgeddon` and walk your normal Evil Twin flow, for example:
   - select your attack interface
   - menu `7` → *Evil Twin attacks menu*
   - `4` → *Explore for targets* → select the target network to clone
   - back at the Evil Twin menu → `5` → *Evil Twin attack only AP*
     (or any other Evil Twin mode)
   - pick a deauth attack as prompted (airgeddon requires this choice in
     its flow — note there is no "skip" option; the QR association works
     with or without the deauth running alongside)
   - select the internet-sharing interface when asked
4. When the attack windows launch, you'll see the **EvilQR banner**, the
   QR code rendered in ANSI in your terminal, and a notice naming the PNG
   file that was saved.
5. Have the target scan it — point a phone camera at your terminal or the
   PNG. The phone joins the twin instantly.

**What success looks like on the wire:** the hostapd window shows the
phone's MAC in `AP-STA-CONNECTED` / association lines, and airgeddon's
Evil Twin control window lists it as a connected client.

**Expected behavior notes:**

- The phone will show the network name as the cloned SSID (the invisible
  trailing character is invisible by design).
- Internet connectivity for the victim depends on the attack mode you
  chose (an only-AP attack with an internet interface shares routing;
  captive-portal modes intercept instead).
- Test against networks you own or are authorized to test. EvilQR makes
  association *easier*, which makes authorization *more* important.

### Requirements per distro

The plugin needs exactly one external tool: `qrencode`. Package names and
airgeddon's plugin location vary:

| Distro | Install qrencode | Plugin directory |
|---|---|---|
| **Gentoo / Pentoo** | `emerge media-gfx/qrencode` | `/usr/share/airgeddon/plugins/` |
| **Kali** | `apt install qrencode` | `/usr/share/airgeddon/plugins/` (packaged airgeddon) or `<clone>/plugins/` |
| **Parrot** | `apt install qrencode` | `/usr/share/airgeddon/plugins/` or `<clone>/plugins/` |
| **Debian / Ubuntu** | `apt install qrencode` | `<airgeddon-clone>/plugins/` |
| **Arch / BlackArch** | `pacman -S qrencode` | `<airgeddon-clone>/plugins/` |

Installation is copying one file:

```bash
cp plugins/evilqr.sh /usr/share/airgeddon/plugins/   # or your clone's plugins/ dir
```

There is nothing to enable — airgeddon discovers and loads the plugin on
its next start (`plugin_enabled=1` is already set). Remove the file to
disable it.

### Phone compatibility

| Platform | Native camera joins `WIFI:` QRs |
|---|---|
| Android 9+ (stock camera / Google Lens) | yes — older versions and some OEM camera apps vary; any ZXing-based scanner app works |
| iOS 11+ | yes — Camera app recognizes and joins |

Because airgeddon's Evil Twin is an open network (`T:nopass`), joining
requires no further interaction on any platform.

### Verified

- airgeddon **12.02** on Gentoo/Pentoo (kernel 7.2.7, bash 5.x)
- QR payload verified byte-exact with `zbarimg`, including the zero-width
  space and escaped special characters
- **Live end-to-end test:** a phone scanned the plugin-generated QR during a
  real airgeddon Evil Twin attack and associated with the fake access point

### Development

- The plugin hooks airgeddon's `launch_fake_ap` via the posthook mechanism
  (`evilqr_posthook_launch_fake_ap`), so it fires in every Evil Twin mode
  at the exact moment the AP goes live.
- User-visible strings are registered through the `hookable_for_languages`
  prehook (`evilqr_prehook_hookable_for_languages`). To add a language,
  add one `arr["<LANGUAGE>","evilqr_N"]` line per string — the pattern
  follows airgeddon's own `missing_dependencies` plugin.
- Patches and fixes land here first; upstream airgeddon PRs are cut from
  this repository.

### License

GPL-3.0, matching airgeddon.
