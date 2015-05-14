http://www.aloop.org/2010/11/27/from-mercurial-to-git-commands-mapping/

$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com

```
# add to .gitconfig for git lg / git lg2 (thg-like branch display)
[alias]
lg1 = log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
lg2 = log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
lg = !"git lg1"
```

Github workflow:

git branch is more like hg bookmark than hg branch. Create a git branch for
each feature or bugfix on github:
```
git checkout master
git branch <feature xyz>
git checkout <feature xyz>
# or simpler: git checkout -b <feature xyz> -t origin/master
vim ...
git status
git diff
git add -u # or -A for new files
git commit -m 'msg'
git amend -a # stages all changed & removed files, then amends
git reflog # shows old amend steps you can git reset --hard to
git show
git log
git lg
git lg2
```

commit msgs: format for http_parser & nodejs is here: 
https://github.com/iojs/io.js/blob/master/CONTRIBUTING.md#step-3-commit

to push to github (and create pull req for new branch):
```
git push # shows longer cmd line when necessary, e.g.
   # git push --set-upstream origin <local branch>
```

After getting code review feedback keep appending changesets to this
branch & push, github auto-updates the pull request and auto-squashes 
commits on demand.

Combining multiple features (each in its own branch):
```
# http://stackoverflow.com/questions/5308816/how-to-use-git-merge-squash
git checkout <target branch>
git merge --squash <feature or bugfix branch>
git status
git diff --cached
git commit
```

Pulling changes into your repo clone from upstream after you pull requests got 
accepted:
```
git remote add upstream https://github.com/joyent/http-parser
git fetch upstream
git checkout master
git merge upstream/master # should print 'fast forward'
# optional git log to verify changeset hashes
```

Other somewhat frequent cmds:
```
git branch # ls
git branch -r # ls remote
git branch -a # ls all

# for checking out remote branches with tracking: 
git checkout --track origin/some_branch

git diff master # to diff what the squashed changeset will be
```
