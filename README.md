# XmlmcRb

This gem provides a wrapper for the Xmlmc API provided by Hornbill. Currently A direct interface exists where all services and operations are supported.
Helper methods exist for the `session` and `data` services.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xmlmc-rb', '2.0.3'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xmlmc-rb-2.0.3.gem

## Usage

###  Api

  The API helpers are divided into classes of the services available in the API. Currently the following classes exist: `Session`, `Data`, `Helpdesk`, `Knowledgebase`, and `Mail`. Before you can use any other
  method, a login method must be executed. After that the session state is maintained automatically through consecutive calls. To end your session a logoff method must
  be executed.

  The session class is the only class in the api that takes a parameter during instantiation, it requires the endpoint address for your supportworks server, and an optional
  port number to use. By default the port is 5015 which should not be changed. If a different port is required, the helper methods handle the switching on your behalf.
  The methods all return hashes of the values returned from the api. In the case of query methods, the data is returned under the `:data` key and is an array of hashes
  where each index in the array represents a row, and each key is column. Keys in the return hashes have been parameterized according to the rails standard, that is,
  lower snake-case.

###  Standard Example

```ruby
require 'xmlmc-rb'

session = Xmlmc::Api::Session.new '10.1.10.31'

#begin a session
session.analyst_logon 'admin', 'password'

data = Xmlmc::Api::Data.new

#query a table
opencall = data.sql_query 'select * from opencall'

#get the callref from the first row
puts opencall[:data][0][:callref]

#logoff
session.analyst_logoff
```

###  Making calls across multiple endpoints

The Mail services API resides on port 5014 and the Session services reside on port 5015. In this case the
ruby helper methods handle switching automatically.

```ruby
require "xmlmc-rb"



##
# Change these details to match your environment!! The first option needs to be the hostname or ip address
# of your server. The second option 'analyst_logon' needs to be set to the username and password of an administrator
# Failure to adjust these settings correctly could prevent the script from working or worse, make unwanted changes to
# your production environment
##

endpoint = '192.168.1.32'
username = 'admin'
password = ''

##################################################
# List all the mailboxes in your system
##################################################

# Authenticate the user

session = Xmlmc::Api::Session.new endpoint #defaults to port 5015
session.analyst_logon username, password

mail = Xmlmc::Api::Mail.new #Automatically switch the port to port 5014
puts mail.get_mailbox_list :shared

#switch back to port 5015
session.analyst_logoff
```

###  Interface

  The interface class allows you to directly interface with the API as though you were sending xml straight to the endpoint using a library like cURL.
  When you create the interface class you will have the option of providing an endpoint address and port just as in the API class. If you do not define one
  the endpoint defaults to `localhost:5015`

  The method through which most of the work will be done is the invoke method takes two required parameters and a third optional parameter. The first two are strings
  and proivde the service and method to be used, the last is an optional parameters hash that should contain the key value pairs of the parameters to be sent in the correct
  casing and order they are to be sent. If no parameters are required this defaults to an empty hash. Hash keys can either be symbols or strings.
  Since the helper methods call the invoke method of the interface class, the return values are the same in either case. Here is the same example as above using the interface class.

###  Example

```ruby
require 'xmlmc-rb'

xmlmc = Xmlmc::Interface.new '10.1.10.31'

xmlmc.invoke 'session', 'analystLogon', {:userId => 'admin', :password => ''}

query = xmlmc.invoke 'data', 'sqlQuery', {:database => 'swdata', :query => 'Select * from opencall'}

puts query[:data][0][:callref]

xmlmc.invoke 'session', 'analystLogoff'

if xmlmc.last_error
  puts xmlmc.last_error
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on BitBucket at https://bitbucket.org/richbai90/xmlmc-rb.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

