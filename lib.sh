#!/usr/bin/env bash
# Helpers de 'descargar': instalación de dependencias, yt-dlp y utilidades.
# Se cargan con: source lib.sh  (la descarga 'descargar' automáticamente si
# no está presente junto a él).
#
# CRÉDITOS: las descargas las realiza yt-dlp (github.com/yt-dlp/yt-dlp, licencia
# Unlicense). Este wrapper solo invoca el binario OFICIAL de yt-dlp y no contiene
# ni modifica su código.

YTDLP="${YTDLP:-$HOME/.local/bin/yt-dlp}"

die() { echo "❌ $*" >&2; exit 1; }

# Consulta rápida: confirma que la URL responde y devuelve metadatos
quick_query() {
  timeout 20 "$YTDLP" --no-update "${JS_ARGS[@]+"${JS_ARGS[@]}"}" \
    "${COOKIE_ARGS[@]+"${COOKIE_ARGS[@]}"}" \
    --simulate --flat-playlist "$@" "$URL" 2>/dev/null | head -1 || true
}

detect_pkgmgr() {
  command -v apt-get >/dev/null 2>&1 && { echo apt; return; }
  command -v dnf     >/dev/null 2>&1 && { echo dnf; return; }
  command -v yum     >/dev/null 2>&1 && { echo yum; return; }
  command -v pacman  >/dev/null 2>&1 && { echo pacman; return; }
  command -v zypper  >/dev/null 2>&1 && { echo zypper; return; }
  command -v apk     >/dev/null 2>&1 && { echo apk; return; }
  command -v pkg     >/dev/null 2>&1 && command -v termux-info >/dev/null 2>&1 && { echo pkg; return; }
  command -v brew    >/dev/null 2>&1 && { echo brew; return; }
}

run_root() {
  if [[ $EUID -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "❌ Sin acceso root ni sudo para instalar paquetes." >&2
    return 1
  fi
}

install_pkgs() {
  local pm="$1"
  shift
  case "$pm" in
    apt)    run_root apt-get update && run_root apt-get install -y "$@" ;;
    dnf)    run_root dnf install -y "$@" ;;
    yum)    run_root yum install -y "$@" ;;
    pacman) run_root pacman -S --noconfirm "$@" ;;
    zypper) run_root zypper --non-interactive install "$@" ;;
    apk)    run_root apk add "$@" ;;
    pkg)    run_root pkg install -y "$@" ;;
    brew)   brew install "$@" ;;
    *)
      echo "❌ Gestor de paquetes no soportado. Instala manualmente." >&2
      return 1
      ;;
  esac
}

ensure_cmd() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $cmd detectado"
    return 0
  fi
  echo "⚠ $cmd no está instalado → instalando..."
  if [[ -z "$PKGMGR" ]] || ! install_pkgs "$PKGMGR" "$@"; then
    echo "   Instálalo manualmente o revisa la conexión." >&2
    MISSING_DEPS+=" $cmd"
  elif command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $cmd instalado"
  else
    echo "   Instálalo manualmente." >&2
    MISSING_DEPS+=" $cmd"
  fi
}

ensure_deps() {
  PKGMGR="$(detect_pkgmgr)"
  MISSING_DEPS=""
  echo "── Verificando dependencias ──"
  ensure_cmd python3 python3
  ensure_cmd curl curl
  ensure_cmd ffmpeg ffmpeg
  if command -v node >/dev/null 2>&1; then
    echo "✅ node detectado (runtime JS)"
  elif command -v deno >/dev/null 2>&1; then
    echo "✅ deno detectado (runtime JS)"
  elif command -v bun >/dev/null 2>&1; then
    echo "✅ bun detectado (runtime JS)"
  elif [[ -n "$PKGMGR" ]]; then
    echo "⚠ Sin runtime JS → instalando nodejs..."
    install_pkgs "$PKGMGR" nodejs >/dev/null 2>&1 || MISSING_DEPS+=" nodejs"
  else
    MISSING_DEPS+=" nodejs"
  fi
  [[ -z "$MISSING_DEPS" ]] || die "Faltan dependencias que no pude instalar:$MISSING_DEPS"
}

ensure_ytdlp() {
  if [[ ! -x "$YTDLP" ]] || ! "$YTDLP" --version >/dev/null 2>&1; then
    echo "▶ Instalando yt-dlp (última versión) en ~/.local/bin ..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL --retry 3 -o "$YTDLP" \
      https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      || die "No se pudo descargar yt-dlp. Revisa la conexión a internet."
    chmod +x "$YTDLP"
    "$YTDLP" --version >/dev/null 2>&1 \
      || die "yt-dlp quedó corrupto. Borra ~/.local/bin/yt-dlp y vuelve a ejecutar."
  fi
}