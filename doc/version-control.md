## Configuration Management

It is crucial to save your configurations for deploying and staging in later
phases.

The \*.rsp files are standard Oracle response files, used typically in server
installations. Whatever you configure you should keep your configuration and
add it to your configuration management. With Git you would now branch the
project and add those files (beside the shipped example files that you've used
as templates), eg. with:

    $ git checkout -b mydevboxbranch
    $ git add .
    $ git commit -m "initial version of mydevbox config"

You can add your own git server with

    $ git remote add mygit ssh://git@git.srv.priv/myrepo.git
    $ git push mygit mydevboxbranch


