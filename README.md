# Validators.app
This is code repository for Validators.app.  
https://www.validators.app/

## System dependencies
  - Ruby 3 (see `.ruby-version` file)
  - Rails 6.1+
  - MySQL 8
  - Redis/Valkey 7+
  - Node 20+
  - Solana CLI (see instruction below)
  - ImageMagick
  - Object Storage

## Configuration Notes
- Download credentials (master.key, test.key and .env) from Keybase
- To edit credentials run `EDITOR=vim rails credentials:edit`.  
  To open in a different editor, e.g. in nano, use `EDITOR=nano rails credentials:edit`
- Copy `config/database.example.yml` to `config/database.yml` and edit to reflect the proper database name, user name and other settings.
- Developers using Mac OS will need to `brew install shared-mime-info` before `bundle install`

## Database 
- Make sure you have `database.yml` with correct settings.
- run `rails db:create` and `rails db:migrate` to create and migrate the database.
- run `rails db:seed` for basic data generation. 
- Then follow instructions in `database_instructions` on Keybase for more advanced data population.

### Copying data from prod to staging
To enable copying records to staging database set copy_records_to_stage in credentials file to true.

## Solana CLI
https://docs.solana.com/cli/install-solana-cli-tools  
Follow the instructions for your OS. Make sure `solana --version` returns correct CLI version.
### On production/staging servers
See keybase file for instructions.

### Check current version
`solana -V` or `solana --version`

## Attribute Encryption
Attribute encryption on models is required for any attribute that contains personal information or other sensitive 
data. The default solution is the attr_encrypted gem. Encryption key is stored in rails credentials.

## Captcha
Set up hCaptcha account at https://www.hcaptcha.com/ and get your site key and secret key. Put them in the credentials file.
For development, you will find sample keys in config/credentials.yml.enc.

## Run server
Run server by calling `./bin/dev`. It bundles assets, starts rails server at default port and runs sidekiq.

## Tests
How to run the test suite:
- To run all tests: `rails test`
- To run all tests from specific directory: `rails test test/models` 
- To run all tests from specific file: `rails test test/models/article_test.rb` 
- To run specific test and line: `rails test test/models/article_test.rb:6` 

If you see errors related to yarn while running tests locally, try `rake assets:clobber` and `yarn install`.

### Continuous Integration
We use Github Actions. See .github directory for more details.  
The test credentials are kept in config/credentials/test.yml.enc.
We have encrypted test.key to decrypt these credentials.  
To decrypt the file: `gpg --output config/credentials/test.key --decrypt config/credentials/test_key.gpg`.  
To encrypt the file: `gpg -c --output config/credentials/test_key.gpg config/credentials/test.key`.  
To decrypt and encrypt the file you need a passphrase, please ask your team leader about it.

## Deployment
Deployments are handled by Capistrano. 
Follow the instructions on Keybase in deployment_instructions.md.

## Data Centers
- See instructions on Keybase in data_center_override_instruction.md.

## Validators Stack
- ValidatorsApp https://github.com/brianlong/www.validators.app
- BlockLogic https://github.com/firstmoversadvantage/www_blocklogic_net

### Gems
- Validators ruby client https://github.com/Block-Logic/validators-app-ruby
- Solana RPC ruby gem https://github.com/Block-Logic/solana-rpc-ruby
- Solscan API ruby gem https://github.com/Block-Logic/solscan-api-ruby
- Ping Thing client https://github.com/Block-Logic/ping-thing-client
