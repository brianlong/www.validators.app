https://stackoverflow.com/questions/68903165/rvm-install-2-6-7-always-failed-on-apple-m1-mac

There is a known issue upstream: https://bugs.ruby-lang.org/issues/17777 ruby-build is also tracking this issue: https://github.com/rbenv/ruby-build/issues/1489

The work around is to run the following code, and install ruby 2.6.7 again:

$ export warnflags=-Wno-error=implicit-function-declaration
$ rbenv install 2.6.7
-or-

$ CFLAGS="-Wno-error=implicit-function-declaration" rbenv install 2.6.7
Looks like this can also impact gem installation with native extensions (mysql2 is one of those):

gem install <GEMNAME> -- --with-cflags="-Wno-error=implicit-function-declaration"

Referenced: https://stackoverflow.com/questions/67023479/error-installing-ruby-2-6-7-on-mac-os-how-to-resolve

================================================================================

https://stackoverflow.com/questions/67631572/rails-mysql-on-apple-silicon

rbenv exec gem install mysql2 -- \
--with-mysql-lib=/opt/homebrew/opt/mysql@8.4/lib \
--with-mysql-dir=/opt/homebrew/opt/mysql@8.4/ \
--with-mysql-config=/opt/homebrew/opt/mysql@8.4/bin/mysql_config \
--with-mysql-include=/opt/homebrew/opt/mysql@8.4/include
(Note that you may need to change the version number in those paths)

Notably, this worked with the most recent version of mysql and does not require any Intel versions or using an emulated version of HomeBrew (e.g. ibrew).

Configure Bundler to use this build configuration automatically:

You may also want to set this configuration as your default for mysql2. This way anytime bundler has to re-install mysql2 (on this project or any other project on the same computer), it will automatically use this configuration. You can do that with the following:

bundle config set --global build.mysql2 \
--with-mysql-lib=/opt/homebrew/opt/mysql@8.4/lib \
--with-mysql-dir=/opt/homebrew/opt/mysql@8.4/ \
--with-mysql-config=/opt/homebrew/opt/mysql@8.4/bin/mysql_config \
--with-mysql-include=/opt/homebrew/opt/mysql@8.4/include
