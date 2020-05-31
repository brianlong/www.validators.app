# Validators.app Client Scripts
This folder contains client scripts that are used to collect network and system
data from nodes in the cluster and then send the data to our collector API
endpoint.

### Script Listing
- collect_ping_times.rb will ping each of the other nodes in the cluster and
  upload the results through our API. The ping data can be used to build a
  network graph of cluster nodes with edges showing the minimum, average, &
  maximum ping times between the node pair. `curl https://raw.githubusercontent.com/brianlong/www.validators.app/master/client_scripts/collect_ping_times.rb > collect_ping_times.rb`

### Miscellaneous
Each of the scripts will contain instructions inside the file. All supporting
modules are contained within one file for the simplest possible installation.
Simply download the client script to your home folder and follow the
instructions inside the file. No compilation required!

Before you can upload data, you will need to create an account on
(www.validators.app)[https://www.validators.app/] and grab your API token. The
account and token are required to keep the API endpoint secure.

The scripts above are written in Ruby. I will be happy to review pull requests
if you would like to create compatible scripts in your favorite scripting
language.

Questions? Please contact me on Discord. Issues? Please create a new Issue on
this GitHub repo.

Thanks!

-- Brian Long
