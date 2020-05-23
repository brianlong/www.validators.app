## Template Notes
This repo is a template to be used for creating new projects. After creating your new project, you will need to touch some files to customize the new environment. Those files are:
- config/deploy/* to provide the host names for each deployment target.
- config/deploy.rb to update the project name & other deployment settings.
- Run `EDITOR=vim rails credentials:edit` to initialize the Rails encrypted
  credentials files. See config/credentials.example.yml for some of the
  environment variables that you should copy to config/credentials.yml.enc
- config/database.yml to reflect the proper database name and other settings.
  There is an example in `config/database.example.yml`
- Look at `config/initializers/site_information.rb` and make changes as needed
  to the constant values shown there.
- Perform a 'find all' to look for 'fmaprivacy' and 'fmadata'. Modify those
  values as needed.
- You will also need to go through the views to remove/change some of the
  current boiler plate. This template was originally created for FMAprivacy, so
  the privacy policies, etc. will require some changes.
- This template is configured for the free version of Sidekiq. Review the
  Gemfile and config/routes.rb files if you are using Sidekiq Pro.

NOTE: If you find other files that need to be touched after creating a new project please come back here and update the documentation!

## Ruby version
This project requires Ruby 2.7+ as denoted in the `.ruby-version` file. This project also requires Rails 6.0+. Run the `bundle` command to install Rails and all other Gem dependencies. See the Gemfile for additional notes.

## System dependencies
  - MySQL 5.7+
  - Redis
  - Yarn

## Configuration
Ask someone in charge about the development `master.key`

To open e.g. in atom, use `EDITOR="atom --wait" rails credentials:edit`

To open in vim, make sure it's up to date and use `EDITOR=vim rails credentials:edit`

Set up locking strategy during configuration (https://github.com/plataformatec/devise/wiki/How-To:-Add-:lockable-to-Users).

## Database creation

MySQL 5.7 is the recommended version to run on your machine. Once you have MySQL running, run:
  `cp config/database.example.yml config/database.yml`
and configure your config/database.yml to your machine's MySQL configuration. Minor edits should only be necessary.

## Database initialization
Run rake db:setup to create and migrate the database from schema (db/schema.rb).

## Attribute Encryption
Attribute encryption on models is required for any attribute that contains personal information or other sensitive data. The default solution is the attr_encrypted gem. A more secure alternative is Vault.

## Vault
Vault is an optional component to this project. We mostly are using its Encryption As A Service feature. This functionality is wrapped by the vault-rails gem.

Please note that we currently are using a forked version of the Gem until Rails 5.2+ is supported in the native gem. See this PR for details.

In the test and development modes you do not need an actual Vault server running. The gem will intercept and perform all encryption that would normally by done by the Vault encryption server.

To use Vault, search the project for 'vault' and read the comments.

## How to run the test suite
  `rails test` # run all tests
  `rails test test/models` # run all tests from specific directory
  `rails test test/models/article_test.rb` # run all tests from specific file
  `rails test test/models/article_test.rb:6` # run specific test and line

If you see errors related to yarn, try `yarn upgrade` and `yarn install`

## Services (job queues, cache servers, search engines, etc.)
  - Sidekiq

## Deployment instructions
Follow the instructions for Capistrano

### Testing
Please use `User` factory when you need users, more info in 'test/factories/user.rb'
