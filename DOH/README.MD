
# How to enable DNS over HTTP via Pihole on docker which cane be run in Docker supported platforms.(MAC/WINDOWS/CENTOS/RASPBERRY/...)

## Reference
https://docs.pi-hole.net/guides/dns-over-https/

### First clean up existing docker images / free space
```bash
docker system prune -a
docker rmi $(docker images -a -q)
```

#### Start the pihole container in Detached  mode
```bash
docker-compose up -d
```

#### Check the newly formed containers
```bash
 docker container ls -a
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS                    PORTS                                                                         NAMES
59a9181bb6c0        pihole/pihole:latest   "/s6-init"               13 minutes ago      Up 13 minutes (healthy)   0.0.0.0:53->53/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:53->53/udp, 67/udp, 443/tcp   pihole_pihole_1
1ca3ad741a31        pihole_cloudflared     "/s6-init /bin/sh -c…"   13 minutes ago      Up 13 minutes (healthy)   53/udp, 53/tcp, 80/tcp, 443/tcp, 67/udp                                       cloudflared
```

#### Take TCPdump to see traffic on pihole docker
```bash
docker exec -it pihole_pihole_1 /bin/bash
sudo apt-get update
sudo apt-get install tcpdump -y
tcpdump -i eth0 udp port 53
```

#### Take TCPdump to see traffic on cloudflared docker
```bash 
docker exec -it cloudflared /bin/bash
apt-get update
apt-get install tcpdump -y 
tcpdump -i eth0 udp port 5053
```

#### From LAPTOP do a DNS hit
```bash 
dig @127.0.0.1  google.com
```

#### TEAR DOWN
```bash
docker-compose down
```


#### SAMPLE OUTPUT
```bash


ON LAPTOP WHEN PIHOLE CLOUDFLARED IS ON 
$ sudo tcpdump -i en0 udp port 53
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on en0, link-type EN10MB (Ethernet), capture size 262144 bytes
21:07:27.311009 IP6 2601:45:4000:6c90:bdc6:2c80:b552:f57b.19611 > cdns01.comcast.net.domain: 44937+ A? clients4.google.com. (37)
21:07:27.311282 IP6 2601:45:4000:6c90:bdc6:2c80:b552:f57b.4380 > cdns01.comcast.net.domain: 30783+ AAAA? clients4.google.com. (37)
21:07:27.357098 IP6 cdns01.comcast.net.domain > 2601:45:4000:6c90:bdc6:2c80:b552:f57b.19611: 44937 2/0/0 CNAME clients.l.google.com., A 172.217.10.14 (77)
21:07:27.357106 IP6 cdns01.comcast.net.domain > 2601:45:4000:6c90:bdc6:2c80:b552:f57b.4380: 30783 2/0/0 CNAME clients.l.google.com., AAAA 2607:f8b0:4006:802::200e (89)




WHEN PIHOLE AND CLOUDFLARED IS ON LAPTOP and DNS Setting is 127.0.0.1 Network>Advanced?
ON PIHOLE docker container note containerID's
# tcpdump -i eth0 udp port 53
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
01:23:45.130831 IP 10.0.0.1.57724 > 59a9181bb6c0.53: 51055+ [1au] A? google.com. (39)
01:23:45.131169 IP 59a9181bb6c0.53 > 10.0.0.1.57724: 51055 1/0/1 A 172.217.10.14 (55)
01:23:45.133659 IP 59a9181bb6c0.51285 > one.one.one.one.53: 58618+ PTR? 1.0.0.10.in-addr.arpa. (39)
01:23:45.136051 IP 10.0.0.1.32825 > 59a9181bb6c0.53: 23213+ PTR? 214.0.0.10.in-addr.arpa. (41)
01:23:45.150938 IP one.one.one.one.53 > 59a9181bb6c0.51285: 58618 NXDomain* 0/1/1 (262)
01:23:45.157039 IP 59a9181bb6c0.53 > 10.0.0.1.32825: 23213 NXDomain* 0/1/2 (421)
01:23:45.160069 IP 10.0.0.1.60545 > 59a9181bb6c0.53: 36899+ PTR? 1.1.1.1.in-addr.arpa. (38)
01:23:45.160638 IP 59a9181bb6c0.53 > 10.0.0.1.60545: 36899 1/0/0 PTR one.one.one.one. (67)

ON CLOUDFLARED docker container note containerID's
# tcpdump -i eth0 udp port 5053
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes

01:22:19.115836 IP pihole_pihole_1.pihole_pihole_net.23313 > 1ca3ad741a31.5053: UDP, length 28
01:22:19.116304 IP pihole_pihole_1.pihole_pihole_net.24576 > 1ca3ad741a31.5053: UDP, length 28
01:22:19.117396 IP pihole_pihole_1.pihole_pihole_net.23047 > 1ca3ad741a31.5053: UDP, length 36
01:22:19.119394 IP pihole_pihole_1.pihole_pihole_net.6226 > 1ca3ad741a31.5053: UDP, length 36
01:22:19.141899 IP 1ca3ad741a31.5053 > pihole_pihole_1.pihole_pihole_net.23313: UDP, length 138
01:22:19.148090 IP 1ca3ad741a31.5053 > pihole_pihole_1.pihole_pihole_net.24576: UDP, length 266
01:22:19.170700 IP 1ca3ad741a31.5053 > pihole_pihole_1.pihole_pihole_net.6226: UDP, length 157
01:22:19.170834 IP 1ca3ad741a31.5053 > pihole_pihole_1.pihole_pihole_net.23047: UDP, length 146
01:22:56.318428 IP pihole_pihole_1.pihole_pihole_net.5540 > 1ca3ad741a31.5053: UDP, length 39
01:22:56.345488 IP 1ca3ad741a31.5053 > pihole_pihole_1.pihole_pihole_net.5540: UDP, length 138


ON LAPTOP
$sudo tcpdump -i en0 udp port 53
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on en0, link-type EN10MB (Ethernet), capture size 262144 bytes
21:23:45.121979 IP 10.0.0.214.59933 > one.one.one.one.domain: 58618+ PTR? 1.0.0.10.in-addr.arpa. (39)
21:23:45.138448 IP one.one.one.one.domain > 10.0.0.214.59933: 58618 NXDomain* 0/1/1 (262)


on LAPTOP 
$ dig @127.0.0.1  google.com

; <<>> DiG 9.10.6 <<>> @127.0.0.1 google.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51055
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		228	IN	A	172.217.10.14

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sat Oct 26 21:23:45 EDT 2019
;; MSG SIZE  rcvd: 55
```
## Contributing
Pull requests are welcome. For major changes.

## License
[MIT](https://choosealicense.com/licenses/mit/)
