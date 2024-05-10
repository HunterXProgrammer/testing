#!/usr/bin/sh

set -e

if ! { command -v patch &>/dev/null && command -v git &>/dev/null; }; then
  if [ -n "$TERMUX_VERSION" ]; then
    apt update && pkg install -y git patch
  else
    echo "Command \"git\" and \"patch\" required, install it"
    exit 1
  fi
fi

CURRENT_DIR="$(pwd)"
TMP_DIR="$(mktemp -d)"

interrupt(){
  exit_code=$?
  echo
  echo "Build has been cancelled"
  return $exit_code
} 
trap interrupt INT

cleanup(){
  exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo
    echo "Error occured, exiting..."
    echo
  fi
  rm -rf "$TMP_DIR"
  return $exit_code
} 
trap cleanup EXIT

cd "$TMP_DIR"

cp -r "$CURRENT_DIR/src" .

git clone --depth 1 https://github.com/tulir/whatsmeow whatsmeow

rm -rf whatsmeow/.git*

for i in $(find src/patches -maxdepth 1 -type f -name "*\.patch"); do
  patch -p0 -i "$i" --no-backup-if-mismatch -r "$(mktemp -up .)"
done

rm -rf "$CURRENT_DIR/whatsmeow"

mv "$TMP_DIR/whatsmeow" "$CURRENT_DIR"

echo "Update complete"
