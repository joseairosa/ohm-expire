ohm-expire
==========

Ohm plugin that exposes ttl control over modules

Getting started
---------------

Install gem by running:

    $ [sudo] gem install ohm-expire

On your source code add:

    require "ohm/expire"

After this you need to tell your Ohm Model that it needs to use this extension. Here is an example of a module:

    class Model < Ohm::Model

        include Ohm::Expire

        TTL = 5

        attribute :hash
        index :hash

        expire Model::TTL

        attribute :data
    end

This will create this Ohm Model class with an expire of 5 seconds

Updating TTL
------------

It's easy to update the TTL after creating a Model.
There is also the possibility to simple update the ttl with the default value (the one that was defined on the Model)

Taking the example above:

    m = Model.create(:hash => "123")
    m.update_ttl 30 # Updated to 30 seconds
    m.update_ttl # Updated to 5 seconds (Model::TTL)

Getting TTL
-----------

To get the TTL of a given model:

    m = Model.create(:hash => "123")
    m.get_ttl
