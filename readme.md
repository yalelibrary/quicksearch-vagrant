#Steps

Export your GitHub key and just run vagrant up.

```
echo $key_file
[[ -z $(ssh-add -L | grep $key_file) ]] && ssh-add $key_file
ssh-add -L
mkdir quicksearch
cd quicksearch
vagrant up
```
