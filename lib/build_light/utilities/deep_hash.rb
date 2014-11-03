# http://stackoverflow.com/a/6225321

module Sawyer

  class Resource
    def get_deep(*fields)
      fields.inject(self) {|acc,e| acc[e] if ( acc.is_a?(Sawyer::Resource) )}
    end
  end

end

class Hash
  def get_deep(*fields)
    fields.inject(self) {|acc,e| acc[e] if ( acc.is_a?(Hash) )}
  end
end

