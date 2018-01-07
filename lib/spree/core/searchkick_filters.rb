module Spree
  module Core
    module SearchkickFilters
      def self.applicable_filters(aggregations)
        es_filters = []
        Spree::Taxonomy.filterable.each do |taxonomy|
          es_filters << self.process_filter(taxonomy.filter_name, :taxon, aggregations[taxonomy.filter_name])
        end
        if aggregations.has_key? 'price'
          es_filters << self.process_filter('price', :price, aggregations['price'])
        end
        if aggregations.has_key? 'price_month'
          es_filters << self.process_filter('price_month', :price, aggregations['price_month'])
        end
        if aggregations.has_key? 'price_points'
          es_filters << self.process_filter('price_points', :points, aggregations['price_points'])

        end

        Spree::OptionType.filterable.each do |optiontype|
          es_filters << self.process_filter(optiontype.filter_name, :optiontype, aggregations[optiontype.name])
        end

        Spree::Property.filterable.each do |property|
          es_filters << self.process_filter(property.filter_name, :property, aggregations[property.filter_name])
        end

        es_filters.uniq
      end

      def self.process_filter(name, type, filter)
        options = []
        case type
          when :price
            filter["buckets"].each do |bucket|
              label = "#{bucket['to'].to_i}"
              options << { label: label, value: bucket["key"], count: bucket['doc_count']}
            end
          when :points
            filter["buckets"].each do |bucket|
              label = "#{bucket['to'].to_i}p"
              options << { label: label, value: bucket["key"], count: bucket['doc_count']}
            end

          when :taxon
            ids = filter["buckets"].map{|h| h["key"]}
            id_counts = Hash[filter["buckets"].map { |h| [h["key"], h["doc_count"]] }]
            taxons = Spree::Taxon.where(id: ids).order(name: :asc)
            taxons.each { |t|
              options << {label: t.name, value: t.id, count: id_counts[t.id] }}

          when :optiontype
            ids = filter["buckets"].map{|h| h["key"]}
            optionsvalues = Spree::OptionValue.where(id: ids).order(name: :asc)
            optionsvalues.each {|t| options << {label: t.presentation, value: t.id }}

        when :property
          values = filter["buckets"].map{|h| h["key"]}
          values.sort!
          values.each {|t| options << {label: t, value: t }}


        end

        {
          name: name,
          type: type,
          options: options
        }

      end

      def self.aggregation_term(aggregation)
        aggregation["buckets"].sort_by { |hsh| hsh["key"] }
      end

# # -------------------------------------------------------------------------------------
# # PRICE SLIDER FILTER
# # option scope
# # -------------------------------------------------------------------------------------
#
#
#       def self.price_rental_filter
#         conds = [
#             ["< 10€" ,  { range: { price_rental: { lt: 10 } } }],
#             ["10€ - 20€",       { range: { price_rental: { from: 10, to: 20 } } }],
#             ["20€ - 30€",       { range: { price_rental: { from: 20, to: 30 } } }],
#             ["30€ - 40€",       { range: { price_rental: { from: 30, to: 40 } } }],
#             ["40€ - 50€",       { range: { price_rental: { from: 40, to: 50 } } }],
#             ["50€ - 60€",       { range: { price_rental: { from: 50, to: 60 } } }],
#             ["60€ - 70€",       { range: { price_rental: { from: 60, to: 70 } } }],
#             ["70€ - 80€",       { range: { price_rental: { from: 70, to: 80 } } }],
#             ["80€ - 90€",       { range: { price_rental: { from: 80, to: 90 } } }],
#             ["90€ - 100€",       { range: { price_rental: { from: 90, to: 100 } } }],
#             ["> 100€",  { range: { price_rental: { gt: 100 } } }],
#         ]
#         {
#             name:   'precio mes',
#             scope:  :price_rental,
#             conds:  Hash[*conds.flatten],
#             labels: conds.map { |k, _v| [k, k] }
#         }
#       end

      def self.format_price(amount)
        Spree::Money.new(amount)
      end

    end
  end
end