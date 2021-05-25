module Spree
  module Core
    module SearchkickSorts
      def self.applicable_sorts
        {
            'featured' => { sort: { list_position: :asc }, label: 'Featured' },
            'relevance' => { sort: { _score: :desc }, label: 'Relevance' },
            'popularity' => { sort: { conversions: :desc }, label: 'Popularity' },
            'price_asc' => { sort: { price: :asc }, label: 'Price Low to High' },
            'price_desc' => { sort: { price: :desc }, label: 'Price High to Low' },
            'price_month_asc' => { sort: { price_month: :asc }, label: 'Price Month Low to High' },
            'price_month_desc' => { sort: { price_month: :desc }, label: 'Price Month High to Low' },
            'price_week_asc' => { sort: { price_week: :asc }, label: 'Price week Low to High' },
            'price_week_desc' => { sort: { price_week: :desc }, label: 'Price week High to Low' },
            'price_master_asc' => { sort: { price_master: :asc }, label: 'Price master Low to High' },
            'price_master_desc' => { sort: { price_master: :desc }, label: 'Price master High to Low' },
            'newest' => { sort: { available_on: :desc }, label: 'Newest' },
            'brand' => { sort: { brand: :asc }, label: 'Brand' }
        }
      end

      def self.current_sort(params, taxon = nil)
        sort = active_sort(params, taxon)
        sort[:label]
      end

      def self.process_sorts(params, taxon = nil)
        sort = active_sort(params, taxon)
        sort[:sort]
      end

      def self.active_sort(params, taxon = nil)
        found_sort = applicable_sorts[params[:sort]] if params[:sort]
        found_sort || applicable_sorts[default_sort_key(params, taxon)]
      end

      def self.default_sort_key(params, taxon = nil)
        if params[:keywords].blank?
          if taxon && taxon.respond_to?(:default_sort)
            taxon.default_sort
          else
            'brand'
          end
        else
          'relevance'
        end
      end
    end
  end
end