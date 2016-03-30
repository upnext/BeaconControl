###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Account < ActiveRecord::Base
  has_many :admins

  has_many :account_extensions

  has_many :zones
  has_many :beacons

  has_many :applications
  has_many :application_extensions, through: :applications
  has_many :triggers,     through: :applications
  has_many :activities,   through: :triggers

  belongs_to :brand

  validates :name,
    presence: true

  def active_extensions
    ExtensionsRegistry.active_extensions_for(account_extensions)
  end

  def inactive_extensions
    ExtensionsRegistry.inactive_extensions_for(account_extensions)
  end

  def activate_extension(extension)
    account_extensions.where(extension_name: extension.to_s).first_or_create
  end

  def deactivate_extension(extension)
    account_extensions.where(extension_name: extension.to_s).destroy_all

    application_extensions.where(
      extension_name: extension.to_s
    ).delete_all
  end

  #
  # Creates list of Beacon / Zone for application. Returns collection of BeaconOrZone objects.
  #
  # ==== Parameters
  #
  # * +app_id+ - Integer, ID of application to check active flag for
  # * +q+ - Hash (+ActionController::Parameters+), parameters for query, valid keys:
  #   * +:name+      - filters list to match given +:name+
  #   * +:sort+      - sort list by +:name+ attribute, only range,name,active supported
  #   * +:direction+ - sorting direction (asc/desc)
  #
  def beacons_and_zones(app_id, q = {})
    query_params = []
    search_query, order_clause = ""
    if q[:name]
      search_query = " and name LIKE ? "
      query_params << "%#{q[:name]}%" << "%#{q[:name]}%"
    end

    if q[:sort] && BeaconOrZone::SORTABLE_COLUMNS.include?(q[:sort])
      direction = q[:direction] == "asc" ? "asc" : "desc"
      order_clause = " order by `#{q[:sort]}` #{direction} "
    end

    sql =  <<-SQL
      (
        select z.id, name, 'Zone' AS "range", az.application_id = #{app_id} AS "active" from zones z
        left join applications_zones az on (z.id = az.zone_id and az.application_id = #{app_id})
        where z.account_id = #{id}
        #{search_query}
      )
        union
      (
        select b.id, name, 'Beacon' AS "range", ab.application_id = #{app_id} AS "active" from beacons b
        left join applications_beacons ab on (b.id = ab.beacon_id and ab.application_id = #{app_id})
        where b.account_id = #{id}
        #{search_query}
      )
        #{order_clause}
      SQL

      result = Account.sanitized_select_all([sql] + query_params)

      result.map { |i| BeaconOrZone.new(i) }
  end

  # @return [Application|NilClass]
  def test_application
    applications.where(test: true).first
  end

  def self.sanitized_select_all(sql, binds = [])
    connection.select_all(sanitize_sql(sql), "#{name} Load", binds)
  end
end
