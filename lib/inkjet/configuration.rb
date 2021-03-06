module Inkjet
  class Configuration
    DEFAULT_CONFIGURATION_OPTIONS = {:tabstop => 2}

    attr_reader *DEFAULT_CONFIGURATION_OPTIONS.keys

    DEFAULT_CONFIGURATION_OPTIONS.keys.each do |key|
      define_method "#{key.to_s}=" do |val|
        @changed[key] = [send(key), val]
        instance_variable_set "@#{key.to_s}", val
      end
    end

    # Returns a hash of all the changed keys and values after being reconfigured
    def changed
      @changed = {}
      to_hash.each { |key,val| @changed[key] = [@saved_state[key], val] if @saved_state[key] != val }
      @changed
    end

    # Check whether a key was changed after being reconfigured
    def changed?(key)
      changed.has_key?(key)
    end

    # Pass arguments and/or a block to configure the available options
    def configure(args={}, &block)
      save_state
      configure_with_args args
      configure_with_block &block if block_given?
      self
    end

    # Accepts arguments which are used to configure available options
    def configure_with_args(args)
      args.select { |k,v| DEFAULT_CONFIGURATION_OPTIONS.keys.include?(k) }.each do |key,val|
        instance_variable_set "@#{key.to_s}", val
      end
    end

    # Accepts a block which is used to configure available options
    def configure_with_block(&block)
      self.instance_eval(&block) if block_given?
    end

    # Saves a copy of the current state, to be used later to determine what was changed
    def save_state
      @saved_state = clone.to_hash
      @changed = {}
    end

    def to_hash
      h = {}
      DEFAULT_CONFIGURATION_OPTIONS.keys.each do |key|
        h[key] = instance_variable_get "@#{key.to_s}"
      end
      h
    end
    alias_method :to_h, :to_hash

    protected

    def initialize
      DEFAULT_CONFIGURATION_OPTIONS.each do |key,val|
        instance_variable_set "@#{key.to_s}", val
      end
      save_state
      super
    end

  end
end
