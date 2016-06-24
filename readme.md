# QS Vagrant setup

The setup creates the development stack, combines the three repos, and the required dependencies.

## Steps

Export your GitHub key and just run vagrant up.

```
echo $key
[[ -z $(ssh-add -L | grep $key) ]] && ssh-add $key
ssh-add -L
git clone . . .
cd quicksearch-full-stack
vagrant up
vagrant ssh
cd search-fronend
rails s
```
