module API
  module V1
    module CustomTypes

      class Tempfile
        def self.coerce(input)
          input
        end

        def self.coerced?(value)
          value.is_a?(::Tempfile)
        end

        def self.parse(value)
          value
        end
      end

    end
  end
end
