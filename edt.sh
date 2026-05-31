#!/bin/sh

REPO="itsmelsec/EDT"
BRANCH="main"
BASES="
https://raw.githubusercontent.com/${REPO}/${BRANCH}
https://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}
http://cdn.jsdelivr.net/gh/${REPO}@${BRANCH}
"

detect_arch() {
	m="$(uname -m 2>/dev/null)"
	case "$m" in
		x86_64|amd64)        echo x86_64 ;;
		i686)                echo i686 ;;
		i586)                echo i586 ;;
		i486|i386)           echo i486 ;;
		aarch64|arm64)       echo aarch64 ;;
		armv7*)              echo armv7l ;;
		armv6*)              echo armv6l ;;
		armv5*)              echo armv5l ;;
		armv4t*)             echo armv4tl ;;
		armv4*)              echo armv4l ;;
		arm*)                echo armv5l ;;
		mips64*)             echo mips64 ;;
		mipsel|mipsle)       echo mipsel ;;
		mips)                echo mips ;;
		m68k)                echo m68k ;;
		sh4*)                echo sh4 ;;
		sparc*)              echo sparc ;;
		ppc|powerpc)         echo powerpc ;;
		*)                   echo "" ;;
	esac
}

download() {
	rel="$1"; out="$2"; tmp="$out.part"
	rm -f "$tmp"

	for base in $BASES; do
		url="$base/$rel"
		echo "  fetching: $url"
		if command -v curl >/dev/null 2>&1; then
			if curl -fSL -k -o "$tmp" "$url"; then
				mv -f "$tmp" "$out"; return 0
			fi
		elif command -v wget >/dev/null 2>&1; then
			if wget --no-check-certificate -O "$tmp" "$url" 2>/dev/null \
			   || wget -O "$tmp" "$url"; then
				if [ -s "$tmp" ]; then
					mv -f "$tmp" "$out"; return 0
				fi
			fi
		else
			echo "  !! no curl or wget on this system"
			return 1
		fi
		rm -f "$tmp"
	done

	echo "  !! all mirrors failed for $rel"
	return 1
}

TOOLS="busybox tor tailscale zerotier nmap copyfail linpeas"

install_one() {
	subdir="$1"; name="$2"; mode="${3:-755}"
	out="./$name"
	echo
	echo "Installing $subdir/$name -> $out"
	if download "$subdir/$name" "$out"; then
		chmod "$mode" "$out" 2>/dev/null || true
		echo "  done. size: $(wc -c <"$out" 2>/dev/null) bytes"
		echo "  run:  ./$name"
		return 0
	else
		echo "  download failed."
		return 1
	fi
}

install_tool() {
	case "$1" in
		busybox)   install_one busybox  "busybox-${ARCH}" ;;
		tor)       install_one tor      "tor-linux-${ARCH}" ;;
		tailscale)
			install_one tailscale "tailscaled-linux-${ARCH}" || return 1
			if [ -f "./tailscaled-linux-${ARCH}" ]; then
				ln -sf "tailscaled-linux-${ARCH}" "./tailscale" 2>/dev/null \
					|| cp -f "tailscaled-linux-${ARCH}" "./tailscale"
				chmod 755 "./tailscale" 2>/dev/null || true
				echo "  also: ./tailscale -> tailscaled-linux-${ARCH}"
			fi ;;
		zerotier)  install_one zerotier "zerotier-one-linux-${ARCH}" ;;
		nmap)      install_one nmap     "nmap-linux-${ARCH}" ;;
		copyfail)  install_one copyfail "copyfail-linux-${ARCH}" ;;
		linpeas)   install_one linpeas  "linpeas.sh" ;;
		*) echo "  unknown tool: $1 (valid: $TOOLS)"; return 2 ;;
	esac
}

ARCH="$(detect_arch)"

show_menu() {
	echo
	echo "============================================================"
	echo "  EDT - Embedded Device Toolkit"
	echo "============================================================"
	echo "  Detected arch: ${ARCH:-UNKNOWN ('$(uname -m 2>/dev/null)')}"
	echo "  Repo:          https://github.com/${REPO}"
	echo
	echo "  1) busybox"
	echo "  2) tor"
	echo "  3) tailscale"
	echo "  4) zerotier-one"
	echo "  5) nmap"
	echo "  6) copyfail"
	echo "  7) linpeas"
	echo
	echo "  a) change arch (override auto-detect: $ARCH)"
	echo "  h) help"
	echo "  q) quit"
	echo
	printf "  Choice: "
}

prompt_arch() {
	echo
	echo "  Common labels: x86_64 aarch64 armv7l armv6l armv5l armv4l"
	echo "                 i686 i586 i486 mips mipsel mips64 m68k sh4"
	echo "                 powerpc powerpc-440fp sparc"
	printf "  New arch [%s]: " "$ARCH"
	read new
	if [ -n "$new" ]; then ARCH="$new"; fi
}

usage() {
	cat <<EOF
EDT - Embedded Device Toolkit

Usage:
  sh edt.sh                              interactive menu
  sh edt.sh install <tool> [tool...]     install one or more tools
  sh edt.sh install all                  install every tool for this arch
  sh edt.sh list                         list available tools
  sh edt.sh help                         this message

Tools: $TOOLS

Arch override:
  EDT_ARCH=armv7l sh edt.sh install busybox tor
  EDT_ARCH=mips   sh edt.sh install all

Detected on this box:  ${ARCH:-UNKNOWN ($(uname -m 2>/dev/null))}
EOF
}

run_cli() {
	cmd="$1"; shift 2>/dev/null || true
	case "$cmd" in
		help|-h|--help) usage; return 0 ;;
		list)
			echo "Available tools:"
			for t in $TOOLS; do echo "  $t"; done
			return 0 ;;
		install)
			if [ $# -eq 0 ]; then
				echo "install: missing tool name. Try: sh edt.sh list" >&2
				return 2
			fi
			tools=""
			for t in "$@"; do
				if [ "$t" = "all" ]; then tools="$tools $TOOLS"
				else tools="$tools $t"; fi
			done
			rc=0
			for t in $tools; do
				install_tool "$t" || rc=$?
			done
			return $rc ;;
		*)
			echo "edt.sh: unknown command '$cmd'" >&2
			echo "Try: sh edt.sh help" >&2
			return 2 ;;
	esac
}

run_menu() {
	while :; do
		show_menu
		read choice
		case "$choice" in
			1) install_tool busybox ;;
			2) install_tool tor ;;
			3) install_tool tailscale ;;
			4) install_tool zerotier ;;
			5) install_tool nmap ;;
			6) install_tool copyfail ;;
			7) install_tool linpeas ;;
			a|A) prompt_arch ;;
			h|H|help|\?) echo; usage ;;
			q|Q|"") echo; echo "  bye."; exit 0 ;;
			*) echo "  unknown choice: $choice" ;;
		esac
	done
}

main() {
	if [ -n "${EDT_ARCH:-}" ]; then ARCH="$EDT_ARCH"; fi

	if [ $# -gt 0 ]; then
		run_cli "$@"
		exit $?
	fi
	run_menu
}

main "$@"
