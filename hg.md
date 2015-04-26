Rebase variants
---
```
a)
hg pull --rebase

b)
hg up $revisionToAppendRebasedChangesetsTo
hg rebase -r changesetToRebase  

c) squash like git rebase -i HEAD~2 (squashes last 2 commits):
hg rebase --dest tip~2 --base tip --collapse
```

.hgrc
```
[ui]
username = Kjell Schubert <foo@bar.com>
merge = kdiff3
ssh = "C:\tools\cygwin\bin\ssh"

[extensions]
# this one effects hg diff colors (http://mercurial.selenic.com/wiki/ColorExtension):
color =
# this allows hg pull --rebase and hg rebase:
rebase =
# this turns hg diff into 'hg diff | less' while maintaining colors
# see http://superuser.com/questions/124846/mercurial-colour-output-piped-to-less
pager =

[pager]
pager = LESS='FRX' less

[hostfingerprints]
scm.interactivesys.com External Link = 1c:3e:39:fd:e9:34:bb:df:db:9d:37:04:23:37:c5:f9:81:2f:76:7e
```

Use choco install tortoisehg on Windows: covenient UIs (thg log, annotate, commit).

https://github.com/etsy/Hound can index git & hg repos. Install:
```
# install Go (centos)
wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go*.tgz
vim /etc/profile # export PATH=$PATH:/usr/local/go/bin
go version
# make sure hg can hg clone without entering pwd (otherwise Hound will ask
# for pwd on cmd line)
ssh-copy-id kschubert@...com # whatever local user will be
# now follow Hound github instructions:
git clone https://github.com/etsy/Hound.git
...
make
./bin/houndd # just running on console, is only a temp test install for now
# this will first clone & index repos, which takes a few mins. During which
# nothing will be served on default port 6080:
  2015/02/27 11:37:12 Searcher started for isixcalibur
  2015/02/27 11:47:14 merge 0 files + mem
  2015/02/27 11:47:15 68601501 data bytes, 9785947 index bytes
  2015/02/27 11:47:15 Searcher started for AMCC # clone failed due to scm url typo
  2015/02/27 11:47:15 Some repos failed to index, see output above
  2015/02/27 11:47:15 running server at http://localhost:6080...
sudo lsof -i | grep 6080 # only works 10 mins after ./bin/houndd startup
# check firewall for 8060
sudo iptables -L
sudo iptables --line -vnL
# num 5 is REJECT line, let's accept port 6080
sudo iptables -I INPUT 5 -i eth0 -p tcp --dport 6080 -m state --state NEW,ESTABLISHED -j ACCEPT
```
