module Spree
  module Search
    class Searchkick < Spree::Core::Search::Base
      def retrieve_products
        @products = base_elasticsearch

      end


      def base_elasticsearch
        curr_page = page || 1
        Spree::Product.search(
          keyword_query,
          where: where_query,
          aggs: aggregations,
          fields: ["name", "brand", "name_and_brand_taxons_descripction"],
          includes: search_includes,
          smart_aggs: true,
          order: sorted,
          page: curr_page,
          per_page: per_page
        )

      end

      def where_query
        where_query = {
          active: true,
          currency: current_currency,
          price: { not: nil }
        }
        where_query[:taxon_ids] = taxon.id if taxon
        add_search_filters(where_query)
      end

      def keyword_query
        (keywords.nil? || keywords.empty?) ? '*' : keywords
      end

      def sorted
        @sort
      end

      def aggregations
        fs = {}
        Spree::Taxonomy.filterable.each do |taxonomy|
          fs[taxonomy.filter_name.to_sym] = { stats: true }
        end
        Spree::Property.filterable.each do |property|
          fs[property.filter_name.to_sym] = { stats: true }
        end

        Spree::OptionType.filterable.each do |optiontype|
          fs[optiontype.filter_name.to_sym] = { stats: true }
        end
        fs[:price] = { ranges: [
            {from:5, to: 300},]
        }
        fs[:price_month] = { ranges: [
            {from:5, to: 300},]
        }
        fs[:price_week] = { ranges: [
            {from:5, to: 300},]
        }
        fs[:plan] = { stats: true }
        fs

      end

      def add_search_filters(query)
        return query unless search
        search.each do |name, scope_attribute|
          if name == 'price'
            price_filter = process_price(scope_attribute)
            query.merge!(price: price_filter)
          elsif name == 'price_month'
            price_filter = process_price(scope_attribute)
            query.merge!(price_month: price_filter)
          elsif name == 'price_week'
            price_filter = process_price(scope_attribute)
            query.merge!(price_week: price_filter)
          elsif name == 'renting'
            if scope_attribute.include?('ocassional')
              filter = {}
              filter[:gt] = '50.0'
              price_filter = filter
              query.merge!(price: price_filter)

            elsif scope_attribute.include?('buysale')
              filter = {}
              filter[:eq] = '32'
              price_filter = filter
              query.merge!(condition: price_filter)

            end

          else
            query.merge!(Hash[name, scope_attribute])
          end
        end
        query
      end
      def search_includes
        [master: [:prices, :images]]
      end
      def prepare(params)

        super
        @properties[:conversions] = params[:conversions]
        @sort = Spree::Core::SearchkickSorts.process_sorts(params, taxon)
      end

      def process_price(price_list)
        if price_list.any?
          from = nil
          to = nil
          price_list.each do |price|
            val = {}
            parts = price.split("-")
            unless parts.first == '*'
              from = [from, parts.first.to_f].compact.min
            end

            unless parts.second == '*' or parts.second == ' 300'
              to = [parts.second.to_f, to].compact.max
            end
          end
          if from || to
            filter = {}
            filter[:gte] = from if from
            filter[:lte] = to if to
            filter
          end
        end
      end

    end
  end
end
