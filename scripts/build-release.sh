#!/usr/bin/env bash
# 构建 macOS 应用并导出为可分发的 .app（不依赖 clone 后本地运行）
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEME="priority_list"
ARCHIVE_NAME="priority_list.xcarchive"
EXPORT_DIR="$PROJECT_DIR/build/Release"
ZIP_NAME="Do-it-Release.zip"

cd "$PROJECT_DIR"

echo "→ 清理并构建 Archive..."
xcodebuild -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$PROJECT_DIR/build/$ARCHIVE_NAME" \
  clean archive

echo "→ 导出 .app..."
rm -rf "$EXPORT_DIR"
xcodebuild -exportArchive \
  -archivePath "$PROJECT_DIR/build/$ARCHIVE_NAME" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$SCRIPT_DIR/ExportOptions.plist"

APP_PATH="$EXPORT_DIR/priority_list.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "错误：未找到 $APP_PATH"
  exit 1
fi

echo "→ 打包为 $ZIP_NAME ..."
cd "$EXPORT_DIR"
zip -r -y "$PROJECT_DIR/$ZIP_NAME" "priority_list.app"
cd "$PROJECT_DIR"

echo ""
echo "完成。用户可直接使用："
echo "  1. 解压 $ZIP_NAME"
echo "  2. 将 priority_list.app 拖到「应用程序」"
echo "  3. 从菜单栏或启动台打开 Do it!"
echo ""
echo "输出文件: $PROJECT_DIR/$ZIP_NAME"
