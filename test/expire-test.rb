require_relative "helper"
require "ohm/expire"

class Model < Ohm::Model

    include Ohm::Expire

    TTL = 5

    attribute :hash
    index :hash

    expire TTL

    attribute :data
end

test do
    Ohm.flush

    m = Model.create(:hash => "123")
    assert_equal Model::TTL, m.get_ttl

    m.update_ttl 3
    assert_equal 3, m.get_ttl

    sleep 1

    m = Model.find(:hash => "123").first
    assert !m.hash.nil?

    # Update with default expire
    m.update_ttl
    assert_equal Model::TTL, m.get_ttl

    sleep 6

    m = Model.find(:hash => "123").first
    assert m.hash.nil?
end
