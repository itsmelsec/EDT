# Credits and third-party licenses

`edt.sh` and the repository structure are licensed under GPL-3.0 (see `LICENSE`).
The bundled binaries are unmodified builds of third-party projects and retain
their own upstream licenses:

| Tool       | License                                           | Upstream |
|------------|---------------------------------------------------|----------|
| busybox    | GPL-2.0-only                                      | https://busybox.net |
| tor        | BSD-3-Clause                                      | https://gitlab.torproject.org/tpo/core/tor |
| tailscale  | BSD-3-Clause                                      | https://github.com/tailscale/tailscale |
| zerotier   | MPL-2.0 (client / daemon code only)               | https://github.com/zerotier/ZeroTierOne |
| nmap       | Nmap Public Source License (NPSL, GPL-2 derived)  | https://nmap.org |
| copyfail   | MIT                                               | https://github.com/badsectorlabs/copyfail-go |
| linpeas    | GPL-2.0-or-later (with author's clarifications)   | https://github.com/peass-ng/PEASS-ng |

Source for any GPL / MPL binary in this repository is available from the
upstream project linked above. Each binary corresponds to an unmodified build
of upstream source at the version reported by `<tool> --version`.
