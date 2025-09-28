echo "=== Optimizing macOS client for 65k QUIC connections ==="

# File descriptors (most important for macOS)
echo "Setting file limits..."
ulimit -n 200000
sudo launchctl limit maxfiles 200000 unlimited

# UDP buffers - critical for QUIC
echo "Optimizing UDP..."
sudo sysctl -w net.inet.udp.recvspace=4194304  # 4MB
sudo sysctl -w net.inet.udp.maxdgram=65535
sudo sysctl -w kern.ipc.maxsockbuf=8388608     # 8MB

# System limits
sudo sysctl -w kern.maxfiles=300000
sudo sysctl -w kern.maxfilesperproc=200000

# Ephemeral port range (important for client)
sudo sysctl -w net.inet.ip.portrange.first=10000
sudo sysctl -w net.inet.ip.portrange.last=65000

echo "macOS client ready for high connection count!"
ulimit -n
