module BuildLight

  module Settings

    # blatantly "borrowed" from http://goo.gl/e4hZl
    class << self

      @_settings = {}
      attr_reader :_settings

      def load!(config_file, options = {})
        newsets = YAML::load_file( File.open("./config/#{config_file}.yml") ).deep_symbolize
        newsets = newsets[options[:env].to_sym] if options[:env] && newsets[options[:env].to_sym]
        deep_merge!(@_settings, newsets)
      end

      def deep_merge!(target, data)
        merger = proc{|key, v1, v2|
          Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        target.merge! data, &merger
      end

      def method_missing(name, *args, &block)
        @_settings[name.to_sym] ||
        fail(NoMethodError, "unknown configuration root #{name}", caller)
      end

    end

  end

end