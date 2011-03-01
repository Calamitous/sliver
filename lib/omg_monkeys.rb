class Array
  # attr_reader :htmled

  def to_html
    if first.is_a?(Array) 
      self.each do |x|
        unless x.is_a?(Array)
          raise ArgumentError.new(":#{x.to_s} is not a valid tag array.  Did you mean [:#{x.to_s}]?")
        end
      end
      map{|x| x.to_html }.join # traverse
    else
      self.to_tag #descend
    end
  end

  def to_tag
    return '' if empty?
    if self.size == 1
      return self[0].is_a?(Symbol) ? "<#{self[0].to_s} />" : self[0]
    end

    list = reject{ |x| x.is_a?(Hash) }
    head, tail = list.bite_off_head

    fore_tag = [head.to_s, properties.to_property_string].compact.reject{ |x| x.empty? }.join(' ')

    return "<#{fore_tag} />" if tail.nil? || tail.empty?
    "<#{fore_tag}>#{tail.to_html}</#{head}>"
  end

  def properties
    self.inject({}) { |acc, elem| acc.merge!(elem) if elem.is_a?(Hash); acc }
  end

  def bite_off_head
    return self[0], self[1..-1]
  end
end

class Hash
  def to_property_string
    self.map{ |k, v| "#{k.to_s}=\"#{v.to_s}\""}.join(' ')
  end
end

class String
  def to_html
    self
  end
end
