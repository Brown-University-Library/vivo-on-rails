class SearchHit
  attr_accessor :field, :value
  def initialize(field, value)
    @field = field
    @value = value
    #
    # TODO: handle the case where there are more <strong> than </strong>
    # tags in the value. This could happen because we allow the user
    # to enter HTML in the field and therefore there is no guarantee that
    # the Solr snippet will include an exact number of open and close tags.
    #
    # As an example see the record for https://vivo.brown.edu/display/ceickhof
    #
    # A possible workaround is to use a non-HTML tag as the hl.pre nd hl.post
    # parameters when querying Solr and add the <strong></strong> tags at the
    # very end after we have sanitied the value/snippet. The current issue is
    # compounded because we want to sanitize the HTML except the <strong>
    # </strong> tags.
  end
end
