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
            'newest' => { sort: { created_at: :desc }, label: 'Newest' }
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
            'featured'
          end
        else
          'relevance'
        end
      end
    end
  end
end