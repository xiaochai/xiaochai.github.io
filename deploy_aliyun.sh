#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_HOST="root@116.62.56.222"
REMOTE_DIR="/var/www/html/blog"
RBENV_ROOT="${RBENV_ROOT:-$HOME/.rbenv}"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=15)
RSYNC_RSH="ssh ${SSH_OPTS[*]}"

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

if [ ! -x "$RBENV_ROOT/bin/rbenv" ]; then
  echo "未找到 rbenv: $RBENV_ROOT/bin/rbenv" >&2
  exit 1
fi

export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$("$RBENV_ROOT/bin/rbenv" init - bash)"

cd "$ROOT_DIR"

echo "=== 使用 Ruby 版本 ==="
ruby -v
bundle -v

echo ""
echo "=== 检查依赖 ==="
if ! bundle check >/dev/null 2>&1; then
  bundle install
fi

echo ""
echo "=== 构建 Jekyll 站点 (baseurl=/blog) ==="
JEKYLL_ENV=production bundle exec jekyll build --baseurl /blog

echo ""
echo "=== 上传到阿里云服务器 ==="
ssh "${SSH_OPTS[@]}" "$REMOTE_HOST" "mkdir -p '$REMOTE_DIR'"
rsync \
  --archive \
  --compress \
  --delete \
  --human-readable \
  --progress \
  -e "$RSYNC_RSH" \
  "$ROOT_DIR/_site/" \
  "$REMOTE_HOST:$REMOTE_DIR/"

echo ""
echo "=== 部署完成: https://xiaochai.tech/blog/ ==="
