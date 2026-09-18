# 🎬 descargar — YouTube Downloader (yt-dlp) autoconfigurable

Script de bash para descargar videos de YouTube con **yt-dlp** en la mejor calidad disponible, que se configura solo.

## ✨ Características

- **Se auto-instala las dependencias**: verifica si faltan `python3`, `curl`, `ffmpeg` y un runtime JS (`node`/`deno`/`bun`), y las instala con el gestor de paquetes de tu sistema (`apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`, `pkg`/Termux, `brew`/macOS).
- **yt-dlp siempre actualizado**: si no lo encuentra, descarga la última versión oficial en `~/.local/bin`.
- **Evita el error HTTP 403 de YouTube**: usa un runtime JS para resolver los retos de YouTube (PO tokens / nsig).
- **Interfaz mínima**: solo te pide la **URL** y la **resolución**. Nada más.
- **Reintentos automáticos** (5) ante cortes de red.
- **Funciona en**: Linux, macOS, WSL, Termux (Android).

## 🚀 Instalación

```bash
# Opción A — clonar este repo
git clone https://github.com/pedromcd999/yt-descargar.git
cd yt-descargar
chmod +x descargar
./descargar

# Opción B — solo el script (el script se autoconfigura)
curl -fsSL -o descargar https://raw.githubusercontent.com/pedromcd999/yt-descargar/main/descargar
chmod +x descargar
./descargar
```

Para usarlo desde cualquier carpeta:

```bash
mkdir -p ~/.local/bin
mv descargar ~/.local/bin/
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
descargar
```

## 🎯 Uso

Ejecuta `descargar` y responde las dos preguntas:

```
🔗 URL del video: https://youtu.be/7iobxzd_2wY

Resoluciones disponibles:
  max            → máxima calidad disponible (por defecto)
  2160/1440/1080/720/480/360 → limitar a esa resolución
  audio          → solo audio en mp3
🎚 Resolución [max]: 1080
```

El video se guarda **en la carpeta desde donde ejecutes el script**.

| Resolución | Ejemplo | Nota |
|---|---|---|
| `max` | `max` | Máxima calidad que YouTube ofrece para ese video (puede ser enorme) |
| `1080` | `1080` | Full HD (recomendado para cursos) |
| `720` / `480` / `360` | `720` | Ahorra tamaño y tiempo de descarga |
| `audio` | `audio` | Solo audio, convertido a **mp3** |

> 💡 **Tip**: si la descarga se interrumpe, vuelve a ejecutar el script con la misma URL y resolución: **continúa desde donde quedó**.

## 🧰 Dependencias

| Dependencia | Tipo | Para qué |
|---|---|---|
| `python3` | Obligatoria | Ejecuta yt-dlp |
| `curl` | Obligatoria | Descarga yt-dlp automáticamente |
| `ffmpeg` | Obligatoria | Une video + audio y convierte a mp3 |
| `node` / `deno` / `bun` | Recomendada | Resuelve los retos JS de YouTube (evita HTTP 403) |

El script las instala automáticamente si faltan (pide contraseña de `sudo` solo cuando es necesario). Si no detecta ningún gestor de paquetes compatible, te indica qué instalar manualmente.

## 🐛 Solución de problemas

| Error | Causa | Solución |
|---|---|---|
| `HTTP Error 403: Forbidden` | yt-dlp desactualizado o sin runtime JS | Ejecuta el script (instala todo solo) o actualiza yt-dlp |
| `ERROR: ffmpeg not found` | Falta ffmpeg | El script lo instala automáticamente |
| Descarga se corta | Red inestable | Reintenta con la misma URL — se reanuda |

## 💳 Créditos

Este proyecto **no contiene código de yt-dlp** y **no se atribuye su autoría**.

- **yt-dlp** es un proyecto de la comunidad ([yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)), publicado bajo licencia **Unlicense** (dominio público).
- Este script es un **wrapper** de ~60 líneas: al ejecutarlo descarga el **binario oficial** de yt-dlp desde el repo de sus releases (`https://github.com/yt-dlp/yt-dlp/releases`) y lo invoca. Todo el mérito de la descarga es de su proyecto.
- Si este script te es útil, apoya el proyecto original: ⭐ [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)

## 📄 Licencia

- **Este script (wrapper)**: MIT — úsalo, modifícalo y compártelo libremente.
- **yt-dlp** (binario que se descarga en tiempo de ejecución): [Unlicense](https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE) — sus autores son el equipo de yt-dlp.