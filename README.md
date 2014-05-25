# nenv-binstubs: A binstubs Plugin for nenv

This plugin makes [nenv](http://nenv.org/) transparently
aware of project-specific binaries created by [npm](http://npmjs.org/).

This means that binaries in your node_modules/.bin directories are automatically added to your shims.

This plugin is based on rbenv-binstubs by ianheggie.

## Installation

To install nenv-binstubs, clone this repository into your ~/.nenv/plugins directory. (You'll need a recent version of nenv that supports plugin bundles.)

    $ mkdir -p ~/.nenv/plugins
    $ cd ~/.nenv/plugins
    $ git clone https://github.com/madumlao/nenv-binstubs.git 

Then for each application directory run the following just once:

    $ npm install
    $ nenv rehash

## Usage

Simply type the name of the command you want to run! Thats all folks! Eg:

   $ express --version

This plugin searches from the current directory up towards root for a directory containing a package.json.
If such a directory is found, then the plugin checks for the desired command under the node_modules/.bin subdirectory.

To confirm that the local binary is being used, run the command:

    $ nenv which COMMAND

To show which package npm will use, run the command:

    $ npm ls PACKAGE

You can disable the searching for package binaries by setting the environment variable DISABLE\_BINSTUBS to a non empty string:

    $ DISABLE_BINSTUBS=1 nenv which command

You can list the bundles (project directories) and their associated binstub directories that have been registered since the plugin was installed using the command:
    
    $ nenv bundles

This will add a comment if the directory is missing, or if a package.json no longer exists. If the package.json for a bundle is removed, then that bundle will be dropped from the list of bundles to check when `nenv rehash` is next run.

## License

Copyright (c) 2014 Mark Dumlao - Released under the same terms as [rbenv's MIT-License](https://github.com/sstephenson/nenv#license)

## Links

* [Issues on GitHub](https://github.com/madumlao/nenv-binstubs/issues) for Known Issues
* [Wiki](https://github.com/madumlao/nenv-binstubs/wiki) for further information
* [nenv](https://github.com/madumlao/nenv) for nenv itself (see thanks note below)

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit
* Send me a pull request. Bonus points for topic branches.

## Contributors

Thanks go to:

* [ianheggie](https://github.com/ianheggie) - nenv-binstubs was forked from his rbenv-binstubs plugin for rbenv!
* [ryuone](https://github.com/ryuone) - for nenv. Note: as of this commit, ryuone's nenv hasn't yet been updated to handle plugins, so this plugin only works with the madumlao nenv fork for now.
* [sstephenson](https://github.com/sstephenson) - for rbenv

