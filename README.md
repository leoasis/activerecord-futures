# ActiveRecord::Futures

[![Build Status](https://travis-ci.org/leoasis/activerecord-futures.png)](https://travis-ci.org/leoasis/activerecord-futures)
[![Code Climate](https://codeclimate.com/github/leoasis/activerecord-futures.png)](https://codeclimate.com/github/leoasis/activerecord-futures)
[![Coverage Status](https://coveralls.io/repos/leoasis/activerecord-futures/badge.png?branch=master)](https://coveralls.io/r/leoasis/activerecord-futures)


Define future queries in ActiveRecord that will get executed in a single round trip to the database.

This gem allows to easily optimize an application using activerecord. All
independent queries can be marked as futures, so that when you execute any of
them at a later time, all the other ones will be executed as well, but the query
of all of them will be executed in a single round trip to the database. That way,
when you access the other results, they'll already be there, not needing to go
to the database again.

The idea is heavily inspired from [NHibernate's future queries](http://ayende.com/blog/3979/nhibernate-futures)

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-futures'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-futures

## Usage

Once the gem is installed, set your config/database.yml file to use a future enabled adapter:

```yml
development: &development
  adapter: future_enabled_mysql2 # or "future_enabled_postgresql"
  username: your_username
  password: your_password
  database: your_database
  host: your_host
```

Now let's see what this does, consider a model `User`, with a `:name` attribute:

```ruby

# Build the queries and mark them as futures
users = User.where("name like 'John%'")
user_list = users.future # becomes a future relation, does not execute the query.
count = users.future_count # becomes a future calculation, does not execute the query.

# Execute any of the futures
count = count.value # trigger the future execution, both queries will get executed in one round trip!
#=> User Load (fetching Futures) (0.6ms)  SELECT `users`.* FROM `users` WHERE (name like 'John%');SELECT COUNT(*) FROM `users` WHERE (name like 'John%')

# Access the other results
user_list.to_a # does not execute the query, results from previous query get loaded
```

Any amount of futures can be prepared, and they will get executed as soon as one of them needs to be evaluated.

This makes this especially useful for pagination queries, since you can execute
both count and page queries at once.

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
Currently the adapter provided inherits the built-in one in Rails, and it also sets the MULTI_STATEMENTS flag to allow multiple queries in a single command.

### Postgres

The pg gem supports multiple statement queries by using the `send_query` method
and retrieving the results via `get_result`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
