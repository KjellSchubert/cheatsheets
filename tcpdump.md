On Windows choco install wireshark, on Ubuntu use tcpdump. Tutorial at
https://danielmiessler.com/study/tcpdump/

```
# show all traffic
sudo tcpdump -i any

# show interfaces
ls /sys/class/net/
ip a
ip addr

# show traffic only for one single host
sudo tcpdump -i eth0 host slave007.interactivesys.com

# save traffic to file, reload
sudo tcpdump -i eth0 host slave007.interactivesys.com -w capturefile
sudo tcpdump -r capturefile
sudo tcpdump -r capturefile

# show very verbose content of capture file (e.g. shows full HTTP content)
sudo tcpdump -r capturefile -nnvvXSs 1514

# show output that's formatted for ease of viewing HTTP traffic
sudo tcpdump -r capturefile -s 0 -A
# the same but filtering out some of the packets
# (add 'tcp port 80 and' to condition if needed)
sudo tcpdump -r capturefile -s 0 -A '(((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
```

# loopback http traffic:
sudo tcpdump -i lo port 8080 -A -s 0 # prints ugly tcp headers though
sudo tcpdump -i lo port 8080 -nnvvXSs 0 # hexdump of full packets (incl ip hdr)
sudo tshark -i lo 'tcp port 8080' # lacks http headers & body
sudo tshark -i lo -R 'tcp.port==8080' -T pdml # ultra-verbose parsed http
sudo tshark -i lo port 8080  -V -R "http.request || http.response" # neat output
