# A basic pi-hole setup for osx over docker


## Install
follow https://docs.docker.com/docker-for-mac/install/ for Docker install over mac

## Reference
https://github.com/pi-hole/docker-pi-hole

## Setup

`git clone https://github.com/bipulkkuri/pihole.git`

Run the following
Edit the line https://github.com/bipulkkuri/pihole/blob/master/docker-compose.yml#L19 or `WEBPASSWORD: "piholepass"` for your password or comment for random password
```
cd pihole
./dockeredPihole.sh setup
```
Here is the output

```
$ ./dockeredPihole.sh setup
Processing setup
pihole scan
If this is first time running this script.
and if you see ports already used, either change ports in docker-compose.yml file
or close other apps using same ports
Mac OS X
port scanned
Pi-hole docker config location /Users/bkuri000/pihole/src/pihole
Mac OS X
host ip to be used 11.1.1.1 for setting up pihole docker container
pihole shutdown
Removing network pihole_default
WARNING: Network pihole_default not found.
pihole cleaning
No stopped containers
Error: No such image: pihole/pihole
Using default tag: latest
latest: Pulling from pihole/pihole
f17d81b4b692: Already exists 
2f887aeb5ecf: Already exists 
11a931b774ae: Already exists 
ee11abf8c9a0: Already exists 
d044d32f5a48: Already exists 
787094bfb12c: Already exists 
06bb4102c359: Already exists 
a4176b9267d2: Already exists 
d4c2b6a5be10: Already exists 
69b1ce33ff52: Already exists 
Digest: sha256:3c165a8656d22b75ad237d86ba3bdf0d121088c144c0b2d34a0775a9db2048d7
Status: Downloaded newer image for pihole/pihole:latest
pihole start in detach mode
Creating network "pihole_default" with the default driver
Creating pihole_pihole_1 ... done
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS                                     PORTS                                                                                                  NAMES
4218bba8d495        pihole/pihole:latest   "/s6-init"          1 second ago        Up Less than a second (health: starting)   0.0.0.0:53->53/udp, 0.0.0.0:53->53/tcp, 0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:67->67/udp   pihole_pihole_1
Docker daemon running
Container name detected pihole_pihole_1
pihole version
  Pi-hole version is v4.1 (Latest: v4.1.1)
  AdminLTE version is v4.1 (Latest: v4.1.1)
  FTL version is v4.1 (Latest: v4.1.2)
Waiting for http://11.1.1.1/admin/
...Got 200! Pihole is up!
Your password for http://11.1.1.1/admin/ is Setting password: piholepass

    ___  _    _  _ ____ _    ____    ____ _  _ ____ _ _    ____ ___  _    ____
    |__] | __ |__| |  | |    |___    |__| |  | |__| | |    |__| |__] |    |___
    |    |    |  | |__| |___ |___    |  |  \/  |  | | |___ |  | |__] |___ |___


```
Try blocking custom lists

add this to your lists
https://raw.githubusercontent.com/bipulkkuri/pihole/master/hosts

