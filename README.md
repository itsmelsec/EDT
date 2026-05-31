# EDT — Embedded Device Toolkit

## One-liner

```sh
wget https://raw.githubusercontent.com/itsmelsec/EDT/main/edt.sh && sh edt.sh
```

```sh
wget http://cdn.jsdelivr.net/gh/itsmelsec/EDT@main/edt.sh && sh edt.sh
```

## Non-interactive

```sh
sh edt.sh install tor
sh edt.sh install busybox tor zerotier
sh edt.sh install all
EDT_ARCH=armv7l sh edt.sh install all
sh edt.sh list
sh edt.sh help
```

## Credits

- [busybox](https://busybox.net) — GPL-2.0-only
- [tor](https://gitlab.torproject.org/tpo/core/tor) — BSD-3-Clause
- [tailscale](https://github.com/tailscale/tailscale) — BSD-3-Clause
- [zerotier](https://github.com/zerotier/ZeroTierOne) — MPL-2.0
- [nmap](https://nmap.org) — Nmap Public Source License (NPSL)
- [copyfail](https://github.com/badsectorlabs/copyfail-go) — MIT
- [linpeas](https://github.com/peass-ng/PEASS-ng) — GPL-2.0-or-later

`edt.sh` is GPL-3.0. See [`NOTICE.md`](NOTICE.md) for full attribution.
