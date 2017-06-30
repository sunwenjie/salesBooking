module Concerns
  module Extract

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      cattr_accessor :search_scopes do
        []
      end

      def add_search_scope(name, &block)
        self.singleton_class.send(:define_method, name.to_sym, &block)
        search_scopes << name.to_sym
      end

      def add_simple_scopes(scopes)
        scopes.each do |name|
          parts = name.to_s.match(/(.*)_by_(.*)/)
          self.scope(name.to_s, -> { order("#{self.quoted_table_name}.#{parts[2]} #{parts[1] == 'ascend' ? "ASC" : "DESC"}") })
        end
      end

      def like_any(fields, values)
        where fields.map { |field|
                values.map { |value|
                  arel_table[field].matches("%#{value}%")
                }.inject(:or)
              }.inject(:or)
      end

      def prepare_words(words)
        return [''] if words.blank?
        a = words.split(/[,\s]/).map(&:strip)
        a.any? ? a : ['']
      end
    end
  end
end