# ActiveRecord::Futures

[![Code Climate](https://codeclimate.com/github/leoasis/activerecord-futures.png)](https://codeclimate.com/github/leoasis/activerecord-futures)

Define future queries in ActiveRecord that will get executed in a single round trip to the database.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-futures'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-futures

## Usage

Currently, the only database supported is MySQL, and with a special adapter, provided by the gem.

Set your config/database.yml file to use the given adapter:

```yml
development: &development
  adapter: future_enabled_mysql2 # set this adapter for futures to work!
  username: your_username
  password: your_password
  database: your_database
  host: your_host
```

Now let's see what this does, consider a model `User`, with a `:name` attribute:

```ruby
# Build the queries and mark them as futures
users = User.where("name like 'John%'").future # becomes a future relation, does not execute the query.
count = User.where("name like 'John%'").future_count # becomes a future calculation, does not execute the query.

# Execute any of the futures
count = count.value # trigger the future execution, both queries will get executed in one round trip!
#=> User Load (fetching Futures) (0.6ms)  SELECT `users`.* FROM `users` WHERE (name like 'John%');SELECT COUNT(*) FROM `users` WHERE (name like 'John%')

# Access the other results
users = users.to_a # does not execute the query, results from previous query get loaded
```

Any amount of futures can be prepared, and the will get executed as soon as one of them needs to be evaluated.

### Methods

ActiveRecord::Relation instances get a `future` method for all queries where multiple results are returned. The future gets
executed whenever `#to_a` gets executed. Note that, as ActiveRecord does, enumerable methods get delegated to `#to_a` also,
so things like `#each`, `#map`, `#collect` all trigger the future.

Also, ActiveRecord::Relation instances get all the calculation methods provided by the ActiveRecord::Calculations module
"futurized", that means, for `#count` you get `#future_count`, for `#sum` you get `#future_sum` and so on. These future
calculations are triggered by executing the `#value` method, which also return the actual result of the calculation.

## Database support

### SQlite

SQlite doesn't support multiple statement queries. Currently this gem doesn't fall back to the normal behavior if the
adapter does not support futures, but this is in the road map :)

### MySQL

Multi statement queries are supported by the mysql2 gem since version 0.3.12b1, so you'll need to use that one or a newer
one.
Currently the adapter provided is the same as the built-in in Rails, but it also sets the MULTI_STATEMENTS flag to allow
multiple queries in a single command. It also has a special way to
execute the queries in order to fetch the results correctly. You
can check the code if you're curious!

### Postgres

Coming soon!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Roadmap

1. Support for postgres
2. Fallback to normal queries when adapter does not support futures
3. Think of a way to use the normal adapters
