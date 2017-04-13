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

    attr_accessor :name, :title, :values
    def initialize(name, display_value)
      @name = name # field name in Solr
      @title = display_value
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

    def set_remove_url_for(value, url)
      @values.each do |v|
        if v.text == value
          v.remove_url = url
        end
      end
    end
  end
end
