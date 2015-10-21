module Mailchimp
  module Mixin
    extend ::ActiveSupport::Concern

    included do
      def update
        client = self.class.client = build_request(self.class.resource_path, id)
        client.update(body: dump_attributes)
      end

      def dump_attributes(attrs=attributes)
        hash = {}
        attrs.each_pair do |key, value|
          hash[key] = value.is_a?(Mixin) ?
              dump_attributes(value.attributes) :
              value
        end
        hash
      end
    end

    module ClassMethods
      def all(*ids)
        fetch_data(load_data(resources_path, ids.clone), ids.clone)
      end

      def find(*ids)
        fetch_data(load_data(resource_path, ids.clone), ids.clone)
      end

      def create(params={}, ids=[])
        client = build_request(resources_path, ids.clone)
        client.create(body: params)
      end

      def upsert(params={}, ids=[])
        client = build_request(resource_path, ids.clone)
        client.create(params)
      end

      def has_many(entries)
        define_method(entries) do
          "::Mailchimp::#{entries.to_s.singularize.camelize}".constantize.all(id)
        end
      end

      # @param [String] path
      # @param [Array<Fixnum>] ids
      def load_data(path, ids=[])
        client = build_request(path, ids)
        client.retrieve
      end

      def build_request(path, ids=[])
        client = Mailchimp.client
        ids = ids.clone
        path.gsub(/\/:/, '|:').split(/\//).select(&:present?).each do |p|
          a = p.split('|').map do |s|
            if s.include?(':')
              ids.size > 0 ? ids.shift : nil
            else
              s
            end
          end.compact
          client.send(*a)
        end
        client
      end

      def resources_path(path=nil)
        @resources_path = path if path
        @resources_path ||= "#{resources_name}"
      end

      def resource_path(path=nil)
        @resource_path = path if path
        @resource_path ||= "#{resources_name}/:id"
      end

      # @return [String]
      def resources_name(name=nil)
        @resources_name = name if name
        @resources_name ||= resource_name.pluralize
      end

      # @return [String]
      def resource_name(name=nil)
        @resource_name = name if name
        @resource_name ||= self.name[/\w+$/].underscore
      end

      # @return [String]
      def fetch_instance_name(name=nil)
        @fetch_instance_name = name if name
        @fetch_instance_name ||= resource_name
      end

      # @return [String]
      def fetch_collection_name(name=nil)
        @fetch_collection_name = name if name
        @fetch_collection_name ||= resources_name
      end

      protected

      def fetch_data(hash, ids=[])
        if hash.key? fetch_collection_name
          coll = Collection.new(self)
          hash[fetch_collection_name].each { |h| coll.push new h }
          coll.parent_ids = ids
          coll
        elsif hash.key? fetch_instance_name
          new hash
        else
          new hash
        end
      end
    end
  end
end