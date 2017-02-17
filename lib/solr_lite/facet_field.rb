module SolrLite
  class FacetField

    class FacetValue
      attr_accessor :text, :count, :remove_url
      def initialize(text = "", count = 0, remove_url = nil)
        @text = text
        @count = count
        @remove_url = remove_url
      end
    end

    attr_accessor :name, :values
    def initialize(name)
      @name = name
      @values = []
    end

    def to_fq(text)
      "#{@name}:\"#{text}\""
    end

    def add_value(text, count)
      @values << FacetValue.new(text, count)
    end

    def value_count(text)
      v = @values.find {|v| v.text == text}
      return 0 if v == nil
      v.count
    end
  end

end
