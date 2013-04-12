require_relative "helper"
require "ohm/expire"

class Model < Ohm::Model

    include Ohm::Expire

    TTL = 5

    attribute :hash
    attribute :required_attr
    index :hash

    expire TTL

    attribute :data

    def validate
        assert_present :required_attr
    end
end

test do
    Ohm.flush

    m = Model.create(:hash => "123", :required_attr => "1")
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

    # invalid model should not raise undefined method for nil:NilClass
    invalid_model = Model.create(:hash => "123")
    assert invalid_model.nil?

    # invalid model should not raise undefined method for nil:NilClass
    empty_model = Model.create
    assert invalid_model.nil?
end
