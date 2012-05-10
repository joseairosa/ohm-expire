require_relative "helper"
require "ohm/expire"


class Model < Ohm::Model

    include Ohm::Expire

    attribute :hash
    index :hash

    expire 5

    attribute :data
end

test do
    Ohm.flush

    m = Model.create(:hash => "123")
    assert_equal 5, m.get_ttl

    m.update_ttl 2
    assert_equal 2, m.get_ttl

    sleep 1

    m = Model.find(:hash => "123").first
    assert !m.hash.nil?

    sleep 2

    m = Model.find(:hash => "123").first
    assert m.hash.nil?
end
