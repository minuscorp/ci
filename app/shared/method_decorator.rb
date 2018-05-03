module FastlaneCI
  ##
  # This module provides a class-level `decorate` method.
  # It can be used to wrap the given method name with a block (make sure to call `super`)
  # or you can return an unbound method that will be used to as the decorator
  module MethodDecorator
    def self.extended(mod)
      decorator_module = Module.new
      mod.prepend(decorator_module)
      mod.instance_variable_set(:@decorator_module, decorator_module)
    end

    def decorate(method_name, with: nil, &block)
      if with.nil?
        # here we are expecting that the block provides an unbound method
        # we then give the unbound method a single parameter, the call to `super`
        # with the binding of the original caller.
        @decorator_module.module_eval do
          define_method(method_name) do |*args|
            method = instance_eval(&block)
            implied_block = proc { super(*args) }
            method.call(&implied_block)
          end
        end

      else
        @decorator_module.module_eval do
          define_method(method_name, &with)
        end
      end
    end
  end
end
