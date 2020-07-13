# Validators.app Client Scripts
This folder contains client scripts that are used to collect network and system
data from nodes in the cluster and then send the data to our collector API
endpoint.

On the Solana testnet, we are asking validators to contribute ping times from their node to the other nodes in the cluster. The ping data can be used to build a network graph of cluster nodes with edges showing the minimum, average, & maximum ping times between the node pair. The ping times might also help us see correlations between network and validator performance. As a validator, this data can also help you trouble-shoot performance problems if they arise.

The scripts below are written in the Ruby scripting language. Simply download the client script to your home folder and follow the instructions inside the file. No compilation required! The scripts will work with any recent version of Ruby, and `sudo apt install ruby` should do it.

The scripts are written to run in a single thread to minimize system load -- I do not want to disturb your running validator with bursts of traffic!

### Script Listing
- collect_ping_times.rb will ping each of the other nodes in the cluster and
  upload the results through our API.  `curl https://raw.githubusercontent.com/brianlong/www.validators.app/master/client_scripts/collect_ping_times.rb > collect_ping_times.rb`

### Miscellaneous
Each of the scripts will contain instructions inside the file. All supporting
modules are contained within one file for the simplest possible installation.

Before you can upload data, you will need to create an account on
(www.validators.app)[https://www.validators.app/] and grab your API token. The
account and token are required to keep the API endpoint secure.

I will be happy to review pull requests if you would like to create compatible scripts in your favorite scripting language.

Questions? Please contact me on Discord. Issues? Please create a new Issue on
this GitHub repo.

Thanks!

-- Brian Long
