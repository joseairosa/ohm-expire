require "ohm"
require "ohm/expire"

class Model < Ohm::Model

    include Ohm::Expire

    TTL = 5

    attribute :hash
    index :hash

    expire Model::TTL

    attribute :data
end

# Our test framework
require "cutest"

# Make sure we always a clean Redis instance
preapre { Ohm.flush }

setup do
    Model.create(:hash => "123")
end

test "get_ttl after 1 second" do |model|
    sleep 1
    assert model.get_ttl > 0 && model.get_ttl <= Model::TTL
end

test "update_ttl to 10" do |model|
    model.update_ttl 10
    assert model.get_ttl == 10
end