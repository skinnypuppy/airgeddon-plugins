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
and hope it (or its user) wanders onto your twin. EvilQR adds an additional
way to associate by scanning a QR code. After airgeddon launches the fake access
point, the plugin renders a scannable QR code (directly in the terminal,
plus a PNG file) containing the standard `WIFI:` network-configuration
payload that the built-in cameras of Android and iOS understand:

```
WIFI:S:<evil twin ESSID>;T:nopass;;
```

A victim can scan the code with a compatible phone camera to join the Evil
Twin without entering a password, because the fake access point is open.
The phone may ask for confirmation before joining. The plugin does not
disable or replace airgeddon's existing deauthentication flow; QR scanning
provides an additional way to associate. The PNG can be printed or displayed
on another screen for scanning.

Technical details worth knowing:

- **The fake access point's ESSID is preserved.** EvilQR uses `et_essid`
  directly, including the invisible zero-width space (U+200B) added by
  airgeddon's `generate_fake_essid` when ESSID stripping is enabled. On
  versions with `AIRGEDDON_EVIL_TWIN_ESSID_STRIPPING`, disabling that option
  also leaves the character out of the QR payload. The plugin does not
  append another character or change the ESSID selected by airgeddon.
- **Special characters are escaped.** The `WIFI:` payload format reserves
  `\ ; , : "` — all are backslash-escaped, so twin ESSIDs cloned from
  real-world SSIDs decode correctly.
- **PNG output.** The QR is also saved as `evilqr_<filtered_essid>.png` in
  airgeddon's current working directory. The filename retains only
  alphanumeric characters, underscores and hyphens from the ESSID. The
  success message displays the absolute path. With tmux startup, the
  working directory can be airgeddon's script directory rather than the
  original launch directory. Existing files with the same name are overwritten.
- **WPA-Enterprise awareness.** airgeddon's enterprise (hostapd-wpe) evil
  twin mode doesn't fit the `WIFI:` join format, so the plugin detects it
  and skips generation with a notice instead of producing a broken code.
- **Multilingual.** Strings are provided through airgeddon's plugin language
  hook in all 13 supported languages: English, Spanish, French, Catalan,
  Portuguese, Russian, Greek, Italian, Polish, German, Turkish, Arabic and
  Chinese. Translations other than English and Spanish retain the
  `pending_of_translation` marker for review.

### How to use it

1. **Install the plugin** (see the distro table below). It is enabled by
   default; ensure airgeddon's `AIRGEDDON_PLUGINS_ENABLED` setting is `true`.
2. **Install `qrencode`** — the only dependency. If it's missing, the
   plugin prints a warning and the attack proceeds normally without the QR.
3. Run `sudo airgeddon` and walk your normal Evil Twin flow, for example:
   - select your attack interface
   - menu `7` → *Evil Twin attacks menu*
   - `4` → *Explore for targets* → select the target network to clone
   - back at the Evil Twin menu → `5` → *Evil Twin attack only AP*
     (or another non-Enterprise Evil Twin mode)
   - pick a deauth attack as prompted (airgeddon requires this choice in
     its flow; the plugin leaves that flow unchanged)
   - select the internet-sharing interface when asked
4. When the attack windows launch, you'll see the **EvilQR banner**, the
   QR code rendered in ANSI in airgeddon's main terminal, and a notice
   showing the absolute path of the PNG file after successful generation.
   The plugin does not open a separate QR window or add the QR to the captive
   portal page.
5. Have the target scan it — point a phone camera at your terminal or the
   PNG, then confirm the connection if prompted by the phone.

**What success looks like on the wire:** the hostapd window shows the
phone's MAC in `AP-STA-CONNECTED` / association lines, and airgeddon's
Evil Twin control window lists it as a connected client.

**Expected behavior notes:**

- The phone will show the network name as the cloned SSID (the invisible
  trailing character is invisible by design).
- Internet connectivity for the victim depends on the attack mode you
  chose (an only-AP attack with an internet interface shares routing;
  captive-portal modes intercept instead).
- If terminal QR rendering fails, PNG generation is not attempted. If
  rendering or PNG generation fails, the plugin does not display the PNG
  success message, and airgeddon's normal flow continues. Enterprise mode
  is skipped with a notice and does not produce a PNG success message.
- Test against networks you own or are authorized to test. EvilQR makes
  association *easier*, which makes authorization *more* important.

### Requirements per distro

The plugin requires **airgeddon 11.51 or later**. Its language hook was
introduced in 11.41, and the `et_essid` variable it uses was introduced in 11.51.

It adds one dependency to airgeddon's existing requirements: `qrencode`.
Package names and airgeddon's plugin location vary:

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

The plugin **ships enabled** (`plugin_enabled=1`). Start or restart airgeddon
after copying the file so its hooks are loaded. To disable it, set
`plugin_enabled=0` in the plugin file and restart airgeddon. Remove the file
to uninstall.

### Phone compatibility

| Platform | Native camera joins `WIFI:` QRs |
|---|---|
| Android 9+ (stock camera / Google Lens) | yes — older versions and some OEM camera apps vary; any ZXing-based scanner app works |
| iOS 11+ | yes — Camera app recognizes and joins |

The QR describes an open network (`T:nopass`), so no password is required.
Recognition and connection prompts depend on the phone and scanner app;
scanning does not guarantee an automatic connection without confirmation.

### Verified

- airgeddon **12.02** on Gentoo/Pentoo (kernel 7.2.7, bash 5.x)
- QR payload verified byte-exact with `zbarimg`, including the zero-width
  space and escaped special characters
- **Live end-to-end test:** a phone scanned the plugin-generated QR during a
  real airgeddon Evil Twin attack and associated with the fake access point

### Development

- The plugin hooks airgeddon's `launch_fake_ap` via the posthook mechanism
  (`evilqr_posthook_launch_fake_ap`). It runs after that function returns
  and skips QR generation when Enterprise mode is active.
- User-visible strings are registered through the `hookable_for_languages`
  prehook (`evilqr_prehook_hookable_for_languages`). To add a language,
  add one `arr["<LANGUAGE>","evilqr_N"]` line per string — the pattern
  follows airgeddon's own `missing_dependencies` plugin.
- Keep runtime variables such as `\${et_essid}` and `\${qr_file}` escaped
  in language assignments so airgeddon expands them when displaying the
  message rather than when registering the strings.
- Patches and fixes land here first; upstream airgeddon PRs are cut from
  this repository.

### License

GPL-3.0, matching airgeddon.
