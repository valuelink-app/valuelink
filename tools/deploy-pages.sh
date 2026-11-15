#!/bin/zsh
# Build web/ and publish it to the gh-pages branch (https://valuelink-app.github.io/valuelink/).
set -e
source /Volumes/Transcend/devtools/env.sh
ROOT=${0:A:h:h}
cd "$ROOT/web" && npm run build
S=$(mktemp -d)
cp -R "$ROOT/web/dist/." "$S/"
find "$S/3d/renders" -name '*.png' -delete
rm -f "$S/3d/ioniq5_black.glb"
touch "$S/.nojekyll"
# the demo film (4:50, 1080p), served from the same site so the link carries no personal account
VID=/Volumes/Transcend/공모전_현대자동차/제출/밸류링크_ValueLink_시연영상.mp4
if [ -s "$VID" ]; then
  mkdir -p "$S/video" && cp "$VID" "$S/video/valuelink_demo.mp4"
  cat > "$S/video/index.html" <<'HTML'
<!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>밸류링크 ValueLink 시연 영상</title>
<style>html,body{margin:0;background:#000;color:#ddd;font-family:-apple-system,BlinkMacSystemFont,"Apple SD Gothic Neo","Pretendard",sans-serif}
main{max-width:1280px;margin:0 auto;padding:24px 16px}h1{font-size:20px;font-weight:600;margin:0 0 14px}
video{width:100%;aspect-ratio:16/9;background:#000;border-radius:8px}p{font-size:14px;color:#999}a{color:#E6D2A8}</style></head>
<body><main><h1>밸류링크 ValueLink 시연 영상 (4분 50초)</h1>
<video src="valuelink_demo.mp4" controls playsinline preload="metadata"></video>
<p>재생이 안 되면 <a href="valuelink_demo.mp4" download>영상 파일 받기 (MP4, 1920×1080)</a> · <a href="../">웹 라이브 데모</a> · <a href="https://github.com/valuelink-app/valuelink">GitHub 저장소</a></p>
</main></body></html>
HTML
fi
cd "$S" && git init -q -b gh-pages && git add -A && git commit -qm "Deploy $(git -C "$ROOT" rev-parse --short HEAD)"
git -c credential.helper= -c credential.helper='!gh auth git-credential' push -f https://github.com/valuelink-app/valuelink.git gh-pages
rm -rf "$S"
