# Quicksearch Vagrant Setup

The project creates the full development stack (CentOS 7, rvm, Ruby, MySql, PostgreSql, Oracle Instant Client, Solr), combines the three Quicksearch repos (search-frontend,
search-backend, quicksearch-morris), and tries to install any required gem dependencies.

It tries to replicate the existing stack (for the most part). There might be opportunities for improvements (e.g., removing unnecessary libraries or adding additional useful libraries). The installation script will continue evolving (to add config, comply with best practices, etc.). 

This setup would likely split up into individual QS projects in the near future, along the style of the rubymine-vagrant project. 

## Steps

As documented in this section, clone this repo, export your key, and run vagrant up. The first time VM will take about 10-15 minutes. The setup picks up ominauth.yml from your computer, but add other YAML config files if necessary.

First, set up your key in GitHub [1], if you haven't already.

```
ssh-keygen -t rsa -b 4096 -C you@email.com
# press enter to save key to your home folder
eval "$(ssh-agent -s)"
# it should print "Agent pid . . ."
ssh-add ~/.ssh/id_rsa
# it should print "Identity added . . ."
pbcopy < ~/.ssh/id_rsa.pub
# now paste this key into your GitHub SSH Settings page
ssh -T git@github.com
# enter "yes" to recognize host
```

Finally, clone the repo and start vagrant:

```
git clone git@github.com:yalelibrary/quicksearch-vagrant.git
cd quicksearch-vagrant
key=~/.ssh/id_rsa
[[ -z $(ssh-add -L | grep $key) ]] && ssh-add $key
vagrant up
# observe message "==> default: Done. Happy coding!"
vagrant ssh

# start any repo that frontend relies on, if necessary
cd /home/vagrant/search-backend
rails s -p8080 &
cd /home/vagrant/search-frontend
# start rails
rails s -b 0.0.0.0

```
Please note: In the event you get a 'access denied (public key)', re-run lines 34 and 35 on your computer

Quicksearch should be visible now at: localhost:3000 or  http://127.0.0.1:3000

![qs](quicksearch.png)

## Notes

Edit your repo's gemfile in case you see gem dependency errors in your system (e.g., add the line 'gem json' in Gemfile if "voayager-api" gem fails for search-backend). Do a "vagrant reload --provision" to verify after editing Gemfile.
(There might be better ways also.)

Note that these gem errors are not due to Vagrant. 

## References

[1] https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

