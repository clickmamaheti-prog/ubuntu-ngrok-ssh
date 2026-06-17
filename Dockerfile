FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    BORE_SERVER=bore.pub \
    SSH_PORT=22 \
    KEEP_ALIVE_PORT=8080

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        curl \
        ca-certificates \
        python3 \
        sudo \
        net-tools \
        iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN mkdir -p /var/run/sshd /var/log/bore

# User ubuntu dengan sudo tanpa password
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Bore v0.5.0 (stable)
RUN curl -sSL https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz \
    -o /tmp/bore.tar.gz && \
    tar -xzf /tmp/bore.tar.gz -C /usr/local/bin bore && \
    rm /tmp/bore.tar.gz && \
    chmod +x /usr/local/bin/bore && \
    bore --version

# SSH hardening + password auth
RUN sed -i \
        -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' \
        -e 's/PasswordAuthentication no/PasswordAuthentication yes/' \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#MaxAuthTries.*/MaxAuthTries 6/' \
        -e 's/#ClientAliveInterval.*/ClientAliveInterval 60/' \
        -e 's/#ClientAliveCountMax.*/ClientAliveCountMax 3/' \
        /etc/ssh/sshd_config && \
    echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD pgrep -x sshd > /dev/null && pgrep -x bore > /dev/null || exit 1

CMD ["/entrypoint.sh"]
