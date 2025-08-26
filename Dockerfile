FROM python:3.13-slim-bookworm

# 必要パッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    vim \
    && rm -rf /var/lib/apt/lists/*

# sshd 用ディレクトリ
RUN mkdir /var/run/sshd

# root パスワード設定（例: root:root）
RUN echo 'root:root' | chpasswd

# パスワード認証を有効化
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ポート公開
EXPOSE 22

# sshd をフォアグラウンドで起動
CMD ["/usr/sbin/sshd", "-D"]
