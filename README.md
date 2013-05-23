# ActiveRecord::Futures

[![Gem Version](https://badge.fury.io/rb/activerecord-futures.png)](http://badge.fury.io/rb/activerecord-futures)
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

If you're using postgresql or mysql2 currently, you have nothing more to do. The gem will automatically use the future enabled adapter and just work. If you are using a custom adapter, specify it in the config/database.yml file as you're used to.

Check the database support (below) section for more info.

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

#### Rails

No configuration to do, things will Just Work.

#### Rack based apps (not Rails)

You will need to manually add the `ActiveRecord::Futures::Middleware` somewhere in the middleware stack:

```ruby
use ActiveRecord::Futures::Middleware
```

This is to clear the futures that were defined and not triggered between requests.

### Methods

#### #future method
ActiveRecord::Relation instances get a `future` method  that futurizes a normal
relation. The future gets executed whenever `#to_a` gets executed. Note that, as ActiveRecord does, enumerable methods get delegated to `#to_a` also,
so things like `#each`, `#map`, `#collect` all trigger the future.

#### Calculation methods
You also get all the calculation methods provided by the ActiveRecord::Calculations module
"futurized". More specifically you get:
* future_count
* future_average
* future_minimum
* future_maximum
* future_sum
* future_calculate
* future_pluck

All future
calculations are triggered with the `#value` method, except for the `#future_pluck` method, that returns an array, and is
triggered with a `#to_a` method (or any other method that delegates to it).

#### Finder methods

Lastly, you also get finder methods futurized, which are:

* future_find
* future_first
* future_last
* future_exists?
* future_all

As with the other future methods, those which return an array get triggered with
the `#to_a` method, or the delegated ones, and those that return a value or a hash
are triggered with the `#value` method. Note that the `#find` method returns an
array or a value depending on the parameters provided, and so will the futurized
version of the method.

## Database support

### SQlite

SQlite doesn't support multiple statement queries. ActiveRecord::Futures will fall back to normal query execution, that is,
it will execute the future's query whenever the future is triggered, but it will not execute the other futures' queries.

### MySQL

Multi statement queries are supported by the mysql2 gem since version 0.3.12b1, so you'll need to use that one or a newer
one.
Currently the adapter provided inherits the built-in one in Rails, and it also sets the MULTI_STATEMENTS flag to allow
multiple queries in a single command.
If you have an older version of the gem, ActiveRecord::Futures will fall back to normal query execution.

### Postgres

The pg gem supports multiple statement queries by using the `#send_query` method
and retrieving the results via `#get_result`.

### Other databases

In general, ActiveRecord::Futures will look for a method `#supports_futures?` in the adapter. So any adapter that returns
false when calling the method, or does not respond to it, will fall back to normal query execution.
If you want to have support for ActiveRecord::Futures with your database, feel free to create a pull request with it, or
create your own gem, or just create an issue.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
