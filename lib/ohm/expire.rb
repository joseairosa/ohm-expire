module Ohm
    # Main expire module
    # ==== Examples
    #
    #   Model < Ohm::Model
    #       include Ohm::Expire
    #   end
    module Expire

        # Extend this module with Ohm
        def self.included(base)
            base.send(:extend, ClassMethods)
        end

        # Extends Ohm::Model with new class methods
        module ClassMethods

            # Set expire for this model
            #
            # ==== Attributes
            #
            # * +ttl <i>Fixnum</i>+ - The expire amount in seconds
            #
            # ==== Returns
            #
            # * nil
            #
            # ==== Examples
            #
            #   Model < Ohm::Model
            #       include Ohm::Expire
            #
            #       attribute :hash
            #       index :hash
            #
            #       expire 30
            #   end
            def expire(ttl)
                @expire = ttl.to_i
            end

            # Callback that is called everytime a new Model is created. This will initialize the export parameters.
            #
            # ==== Attributes
            #
            # * +args <i>Array</i>+ - The arguments supplied on the create method
            #
            # ==== Returns
            #
            # * self
            def create(*args)
                args.first.merge!(:_default_expire => @expire)
                object = super(*args)
                if !object.new? && @expire
                    Ohm.redis.expire(object.key, @expire)
                    Ohm.redis.expire("#{object.key}:_indices", @expire)
                end
                object
            end
        end
    end
end

module Ohm
    # Extends Ohm::Model with new methods
    class Model

        attribute :_default_expire

        # Update the ttl of a given Model
        #
        # ==== Attributes
        #
        # * +model <i>Ohm::Model</i>+ - A Ohm model that will be used to update its ttl. If nil, value will fallback
        #                               to default expire
        # * +new_ttl <i>Fixnum</i>+ - The new expire amount
        #
        # ==== Returns
        #
        # * nil
        #
        # ==== Examples
        #
        #   d = Model.create(:hash => "123")
        #   Model.update_ttl(d, 30)
        def self.update_ttl(model, new_ttl=nil)
            unless model.respond_to? :update_ttl
                model.update_ttl new_ttl
            end
        end

        # Update the ttl
        #
        # ==== Attributes
        #
        # * +new_ttl <i>Fixnum</i>+ - The new expire amount. If nil, value will fallback to default expire
        #
        # ==== Returns
        #
        # * nil
        #
        # ==== Examples
        #
        #   d = Model.create(:hash => "123")
        #   d.update_ttl(30)
        def update_ttl new_ttl=nil
            # Load default if no new ttl is specified
            new_ttl = self._default_expire if new_ttl.nil?
            # Make sure we have a valid value
            new_ttl = -1 if !new_ttl.to_i.is_a?(Fixnum) || new_ttl.to_i < 0
            # Update indices
            Ohm.redis.expire(self.key, new_ttl)
            Ohm.redis.expire("#{self.key}:_indices", new_ttl)
        end

        # Get ttl for a given Model
        #
        # ==== Attributes
        #
        # * +model <i>Ohm::Model</i>+ - A Ohm model that will be used to retrieve its ttl
        #
        # ==== Returns
        #
        # * nil
        #
        # ==== Examples
        #
        #   d = Model.create(:hash => "123")
        #   Model.get_ttl(d)
        def self.get_ttl model
            unless model.respond_to? :get_ttl
                model.get_ttl
            end
        end

        # Get ttl for a given Model
        #
        # ==== Returns
        #
        # * nil
        #
        # ==== Examples
        #
        #   d = Model.create(:hash => "123")
        #   d.get_ttl
        def get_ttl
            Ohm.redis.ttl(self.key)
        end

    end
end