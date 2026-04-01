#!/bin/bash
# 小红书 MCP 一键安装脚本
# 使用方法: bash install-xiaohongshu-mcp.sh

set -e

echo "=== 小红书 MCP 安装脚本 ==="

# 检测系统
OS=$(uname -s)
ARCH=$(uname -m)

if [ "$OS" = "Darwin" ]; then
    if [ "$ARCH" = "arm64" ]; then
        PLATFORM="darwin-arm64"
    else
        PLATFORM="darwin-amd64"
    fi
elif [ "$OS" = "Linux" ]; then
    if [ "$ARCH" = "aarch64" ]; then
        PLATFORM="linux-arm64"
    else
        PLATFORM="linux-amd64"
    fi
else
    echo "不支持的系统: $OS"
    exit 1
fi

VERSION="v2026.03.09.0605-0e16f4b"
FILENAME="xiaohongshu-mcp-${PLATFORM}.tar.gz"
URL="https://github.com/xpzouying/xiaohongshu-mcp/releases/download/${VERSION}/${FILENAME}"
INSTALL_DIR="$HOME/xiaohongshu-mcp"

echo "系统: $OS $ARCH"
echo "下载: $FILENAME"

# 创建安装目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 下载二进制文件
echo "正在下载..."
curl -L -o "$FILENAME" "$URL"
tar xzf "$FILENAME"
rm "$FILENAME"

# 找到解压出来的二进制文件并重命名
BIN_FILE=$(find . -maxdepth 1 -name "xiaohongshu-mcp*" -type f -perm +111 2>/dev/null || find . -maxdepth 1 -name "xiaohongshu-mcp*" -type f -executable 2>/dev/null)
if [ -n "$BIN_FILE" ] && [ "$BIN_FILE" != "./xiaohongshu-mcp" ]; then
    mv "$BIN_FILE" ./xiaohongshu-mcp
fi
chmod +x ./xiaohongshu-mcp

echo "已安装到: $INSTALL_DIR/xiaohongshu-mcp"

# 注册到 Claude Code
echo ""
echo "正在注册到 Claude Code..."
if command -v claude &> /dev/null; then
    claude mcp add --transport http xiaohongshu-mcp http://localhost:18060/mcp
    echo "已注册到 Claude Code MCP 配置"
else
    echo "未检测到 claude 命令，请手动注册："
    echo "  claude mcp add --transport http xiaohongshu-mcp http://localhost:18060/mcp"
fi

# 启动服务
echo ""
echo "=== 安装完成 ==="
echo ""
echo "使用方法:"
echo "  1. 启动 MCP 服务:  $INSTALL_DIR/xiaohongshu-mcp -headless=true"
echo "  2. 首次使用需扫码登录小红书"
echo "  3. 重启 Claude Code 即可使用小红书工具"
echo ""
echo "是否现在启动? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo "启动中..."
    ./xiaohongshu-mcp -headless=true
fi
