module RDF::RDFObjects
  module AssertionSet
    attr_reader :vocabulary, :subject
    def vocabulary=(v)
      @vocabulary = v
    end
    def subject=(s)
      @subject=s
    end
    
    def method_missing(meth, *args)
      if meth.to_s =~ /\=$/
        send(:set_property, @vocabulary.send(meth.to_s.sub(/\=$/,'').to_sym), args)
      elsif prop = @vocabulary.send(meth)
        send(:"[]", prop)       
      end
    end    
    
    def [](key)
     if self.keys.index(key.to_s)
       @subject[key]
     else
       send(:set_property, key, nil)
     end
    end
    def set_property(p, args)
      @subject[p] = args
      @subject[p]
    end
  end
end