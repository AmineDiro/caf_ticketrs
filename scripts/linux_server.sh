#!/bin/bash
echo "=== Optimizing Ubuntu 22.04 server ==="

# 1. File descriptor limits
echo "Setting file descriptor limits..."
ulimit -n 200000

# Make it persistent
cat >> /etc/security/limits.conf << EOF
* soft nofile 200000
* hard nofile 200000
* soft nproc 100000
* hard nproc 100000
EOF

# 2. Network optimizations for QUIC/UDP
echo "Optimizing network stack for QUIC..."

# Core network settings
sysctl -w net.core.rmem_max=134217728        # 128MB
sysctl -w net.core.wmem_max=134217728        # 128MB
sysctl -w net.core.rmem_default=25165824     # 24MB
sysctl -w net.core.wmem_default=25165824     # 24MB
sysctl -w net.core.netdev_max_backlog=50000
sysctl -w net.core.somaxconn=65535

# UDP specific (critical for QUIC)
sysctl -w net.ipv4.udp_mem="100000 200000 300000"
sysctl -w net.ipv4.udp_rmem_min=8192
sysctl -w net.ipv4.udp_wmem_min=8192

# IP settings
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.ip_forward=0

# Connection tracking (if using iptables)
sysctl -w net.netfilter.nf_conntrack_max=200000
sysctl -w net.netfilter.nf_conntrack_udp_timeout=30
sysctl -w net.netfilter.nf_conntrack_udp_timeout_stream=60

# 3. Make settings persistent
cat > /etc/sysctl.d/99-quic-optimization.conf << EOF
# QUIC/UDP optimizations for 65k connections
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.core.rmem_default=25165824
net.core.wmem_default=25165824
net.core.netdev_max_backlog=50000
net.core.somaxconn=65535
net.ipv4.udp_mem=100000 200000 300000
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.ipv4.ip_local_port_range=1024 65535
net.netfilter.nf_conntrack_max=200000
fs.file-max=2000000
fs.nr_open=200000
EOF

# 4. Apply settings
sysctl -p /etc/sysctl.d/99-quic-optimization.conf


echo "Ubuntu server optimized! Reboot recommended for full effect."
