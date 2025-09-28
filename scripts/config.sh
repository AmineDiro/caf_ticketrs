# increase open fds
ulimit -n 2000000


# socket buffers
sysctl -w net.core.rmem_max=67108864
sysctl -w net.core.wmem_max=67108864
sysctl -w net.core.optmem_max=262144

# UDP memory settings
sysctl -w net.ipv4.udp_mem="8388608 12582912 16777216"
sysctl -w net.ipv4.udp_rmem_min=4096
sysctl -w net.ipv4.udp_wmem_min=4096

# increase overall file handle limit
sysctl -w fs.file-max=2000000
