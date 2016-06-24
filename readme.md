# QS Vagrant setup

The project creates the full development stack (CentOS 7, rvm, Ruby, MySql, PostgreSql, Oracle Instant Client), combines the three QuickSearch repos (search-frontend,
search-backend, quicksearch-morris), and any required gem dependencies.

It tries to replicate the existing stack -- therefore, there might be opportunities for improvements (e.g., removing unnecessary libraries or adding additional useful libraries). The installation script will continue evolving (to add config, comply with best practices, etc.). 

In future, this repo's setup would likely get assimilated into the individual QS projects, along the style of the rubymine-vagrant project. 


## Steps

As documented in this section, clone this repo, export your key, and run vagrant up. The first time VM will take about 15 mins. Add your YAML config files as usual.

```
git clone git@github.com:yalelibrary/quicksearch-vagrant.git
cd quicksearch-vagrant
key=~/.ssh/id_rsa
[[ -z $(ssh-add -L | grep $key) ]] && ssh-add $key
vagrant up
# observe message "==> default: Done. Happy coding!"
vagrant ssh
cd search-fronend
# add YAML config, and start rails
rails s
```
## Notes

