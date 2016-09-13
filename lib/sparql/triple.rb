# module Sparql
#   class Triple
#     attr_reader :subject, :predicate, :object
#     def initialize(s, p, o, type)
#       @subject = s
#       @predicate = p
#       @object = o
#       @object_type = type
#     end
#
#     def IsLiteral?
#       @object_type == "literal"
#     end
#
#     def IsUri?
#       @object_type == "uri"
#     end
#
#   end
# end
