FROM ubuntu:18.04 
RUN apt-get update; apt-get install wget -y
RUN  wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb 
RUN  apt-get install ./cloudflared-stable-linux-amd64.deb
RUN  useradd -s /usr/sbin/nologin -r -M cloudflared;rm -rf cloudflared-stable-linux-amd64.deb
CMD ["/bin/sh", "-c", "/usr/local/bin/cloudflared proxy-dns --address 0.0.0.0 --port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query"]
