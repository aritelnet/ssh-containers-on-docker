#!/bin/bash
set -e

IMAGE=py-ssh-key
NUM=10
PORT_START=2200
DOCKERFILE_DIR="$(dirname "$0")"   # スクリプトと同じ場所に Dockerfile がある想定

declare -A PIDS

# --- 1. イメージをビルド ---
echo "[INFO] Building image $IMAGE ..."
docker build -t $IMAGE "$DOCKERFILE_DIR"

# --- 2. コンテナ起動関数 ---
start_container() {
    local idx=$1
    local port=$((PORT_START + idx))
    echo "[INFO] Starting container $idx on port $port"
    CID=$(docker run -d -p $port:22 $IMAGE)
    PIDS[$idx]=$CID
}

# --- 3. コンテナ再作成関数 ---
cleanup_container() {
    local idx=$1
    CID=${PIDS[$idx]}
    echo "[INFO] Container $idx ($CID) stopped, removing..."
    docker rm -f "$CID" >/dev/null 2>&1 || true
    start_container $idx
}

# --- 4. 初回起動 ---
for i in $(seq 0 $((NUM-1))); do
    start_container $i
done

# --- 5. 常駐ループ ---
while true; do
    for i in "${!PIDS[@]}"; do
        CID=${PIDS[$i]}
        if ! docker ps -q --no-trunc | grep -q "$CID"; then
            cleanup_container $i
        fi
    done
    sleep 5
done
