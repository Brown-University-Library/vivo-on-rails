# module Sparql
#   class Row
#     def initialize(row)
#       @row = row
#     end
#
#     def is_column_literal?(col_name)
#       data = @row[col_name]
#       return data && data["type"] == "literal"
#     end
#
#     def is_column_uri?(col_name)
#       data = @row[col_name]
#       return data && data["type"] == "uri"
#     end
#
#     def column(token, defaultValue = "")
#       data = @row[col_name]
#       if data
#         value = data["value"]
#       else
#         value = defaultValue
#       end
#       return value
#     end
#   end
# end
