# Git aliases (Oh My Zsh style)
function current_branch { git rev-parse --abbrev-ref HEAD }

Set-Alias g git

function gst { git status }
function gl { git pull }
function gup { git pull --rebase }
function gp { git push }
function gd { git diff }
function gdc { git diff --cached }
function gc { git commit -v }
function gca { git commit -v -a }
function gcmsg { git commit -m $args }
function gco { git checkout $args }
function gcm { git checkout master }
function gr { git remote }
function grv { git remote -v }
function grmv { git remote rename $args }
function grrm { git remote remove $args }
function gsetr { git remote set-url $args }
function grup { git remote update }
function grbi { git rebase -i $args }
function grbc { git rebase --continue }
function grba { git rebase --abort }
function gb { git branch }
function gba { git branch -a }
function gcount { git shortlog -sn }
function gcl { git config --list }
function gcp { git cherry-pick $args }
function glg { git log --stat --max-count=10 }
function glgg { git log --graph --max-count=10 }
function glgga { git log --graph --decorate --all }
function glo { git log --oneline --decorate --color }
function glog { git log --oneline --decorate --color --graph }
function gss { git status -s }
function ga { git add $args }
function gm { git merge $args }
function grh { git reset HEAD }
function grhh { git reset HEAD --hard }
function gclean { git reset --hard; git clean -dfx }
function gwc { git whatchanged -p --abbrev-commit --pretty=medium }
function gsts { git stash show --text }
function gsta { git stash }
function gstp { git stash pop }
function gstd { git stash drop }
function ggpull { git pull origin (current_branch) }
function ggpur { git pull --rebase origin (current_branch) }
function ggpush { git push origin (current_branch) }
function ggpnp { git pull origin (current_branch); git push origin (current_branch) }
function glp { git log --pretty=$args }
function gc! { git commit -v --amend }
function gca! { git commit -v -a --amend }