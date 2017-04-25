module SolrLite
  class FacetField

    class FacetValue
      attr_accessor :text, :count, :remove_url, :add_url
      def initialize(text = "", count = 0, remove_url = nil)
        @text = text
        @count = count
        @remove_url = remove_url
        @add_url = nil
      end
    end

    attr_accessor :name, :title, :values
    def initialize(name, display_value)
      @name = name # field name in Solr
      @title = display_value
      @values = []
    end

    def to_qs(text)
      "#{@name}|#{CGI.escape(text)}"
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

    def set_add_url_for(value, url)
      @values.each do |v|
        if v.text == value
          v.add_url = url
        end
      end
    end

    def set_urls_for(value, add_url, remove_url)
      @values.each do |v|
        if v.text == value
          v.add_url = add_url
          v.remove_url = remove_url
        end
      end
    end
  end
end
