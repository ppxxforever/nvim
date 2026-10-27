#!/usr/bin/env bash
# ============================================================================
# 用户目录自举：Java / .NET 运行时（不需要 sudo）
#
# 装到哪里：
#   ~/.local/share/jdk-25   Temurin JDK 25（mason 的 jdtls 要求 JavaSE 25，低于 25 会启动失败）
#   ~/.dotnet               .NET SDK 10（LTS）+ 8 / 9 的运行时（nuget 工具按各自 TFM 挑运行时）
#
# Neovim 侧由 lua/config/env.lua 把这两个目录塞进 PATH，不需要改你的 shell 配置。
# 重复执行是安全的：已经装好的会跳过。
# ============================================================================
set -euo pipefail

JDK_DIR="${JDK_DIR:-$HOME/.local/share/jdk-25}"
DOTNET_DIR="${DOTNET_DIR:-$HOME/.dotnet}"

info() { printf '\033[36m==>\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. JDK 25（Adoptium 官方 binary API，直出 tar.gz）
# ---------------------------------------------------------------------------
install_jdk() {
  if [ -x "$JDK_DIR/bin/java" ]; then
    info "JDK 已存在，跳过：$JDK_DIR"
    return
  fi

  info "下载 Temurin JDK 25 …"
  local tmp
  tmp="$(mktemp -d)"
  curl -fL --retry 3 --retry-delay 2 \
    -o "$tmp/jdk.tar.gz" \
    "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse"

  info "解压到 $JDK_DIR …"
  mkdir -p "$JDK_DIR"
  tar -xzf "$tmp/jdk.tar.gz" -C "$tmp"
  local extracted
  extracted="$(find "$tmp" -maxdepth 1 -mindepth 1 -type d | head -1)"
  cp -a "$extracted"/. "$JDK_DIR"/
  rm -rf "$tmp"

  "$JDK_DIR/bin/java" -version
}

# ---------------------------------------------------------------------------
# 2. .NET SDK + 额外运行时
# ---------------------------------------------------------------------------
install_dotnet() {
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL --retry 3 -o "$tmp/dotnet-install.sh" https://dot.net/v1/dotnet-install.sh

  if [ -x "$DOTNET_DIR/dotnet" ] && "$DOTNET_DIR/dotnet" --list-sdks 2>/dev/null | grep -q '^10\.'; then
    info ".NET SDK 10 已存在，跳过"
  else
    info "安装 .NET SDK 10.0 …"
    bash "$tmp/dotnet-install.sh" --channel 10.0 --install-dir "$DOTNET_DIR"
  fi

  # nuget 上的工具大多还是 net8 / net9 目标，光有 SDK 10 跑不起来
  for ch in 8.0 9.0; do
    if "$DOTNET_DIR/dotnet" --list-runtimes 2>/dev/null | grep -q "Microsoft.NETCore.App $ch\."; then
      info ".NET $ch 运行时已存在，跳过"
    else
      info "安装 .NET $ch 运行时 …"
      bash "$tmp/dotnet-install.sh" --channel "$ch" --runtime dotnet --install-dir "$DOTNET_DIR"
    fi
  done

  rm -rf "$tmp"
  "$DOTNET_DIR/dotnet" --list-sdks
  "$DOTNET_DIR/dotnet" --list-runtimes | grep 'Microsoft.NETCore.App '
}

install_jdk
install_dotnet

info "完成。剩下的 LSP / 格式化 / 调试器由 mason 在 Neovim 启动时自动装（见 lua/plugins/mason.lua）"
