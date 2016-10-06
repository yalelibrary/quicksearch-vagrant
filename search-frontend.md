
This page documents the non-IDE set up.

## Steps

As documented in this section, clone search-frontend repo, export your key, and run vagrant up. The first time VM will take about 10-15 minutes. The setup picks up ominauth.yml from your computer, but add other YAML config files if necessary.

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
git clone git@github.com:yalelibrary/search-frontend.git
cd search-frontend
git fetch origin
git checkout RC9try1
key=~/.ssh/id_rsa
[[ -z $(ssh-add -L | grep $key) ]] && ssh-add $key
```

Make sure you have Vagrant version 1.8.1 or 1.8.7. Downgrade or upgrade as necessary.

```
vagrant --version
vagrant up
# observe message "==> default: Done. Happy coding!"
# if something goes wrong or if you need to pick it up again, try vagrant reload --provision
vagrant ssh
# (start any repo that search-frontend relies on, if necessary...)
```

Quicksearch should be visible now at: localhost:3000 or  http://127.0.0.1:3000

You should see the following:

[![Foo](https://raw.githubusercontent.com/yalelibrary/quicksearch-vagrant/master/quicksearch.png)](Quicksearch)


Solr should now be accessible as well (on a different port). Bring up Solr and Rails, if necessary, with:


```
vagrant ssh
cd search-frontend
rails s
cd solr
java -jar start.jar
```

You should now be able to open the current folder in your text editor. Or you can specify a different path in the file Vagrantfile with the setting config.vm.synced_folder.

## Notes

Edit your repo's gemfile in case you see gem dependency errors in your system (e.g., add the line 'gem json' in Gemfile if "voayager-api" gem fails for search-backend). Do a "vagrant reload --provision" to verify after editing Gemfile.
(There might be better ways also.)

Note that these gem errors are not due to Vagrant. 

## References

[1] https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
