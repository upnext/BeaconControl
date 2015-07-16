###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(q = {})
      order_clause =
        if q[:sort] && self::SORTABLE_COLUMNS.include?(q[:sort])
          direction = q[:direction] == "asc" ? "asc" : "desc"
          "#{q[:sort]} #{direction}"
        else
          "name"
        end

      where(q.blank? || q[:name].blank? ? nil : "#{self.table_name}.name LIKE ?", "%#{q[:name]}%")
        .order(order_clause)
    end
  end
end
