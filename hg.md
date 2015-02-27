Rebase variants
---
```
a)
hg pull --rebase

b)
hg up $revisionToAppendRebasedChangesetsTo
hg rebase -r changesetToRebase
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
