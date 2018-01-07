Spree::ProductsController.class_eval do
  before_action :load_taxon, only: [:best_selling]


  # Sort by conversions desc
  def best_selling
    params.merge(taxon: @taxon.id) if @taxon
    @searcher = build_searcher(params.merge(conversions: true))
    @products = @searcher.retrieve_products
    render action: :index
  end

  def autocomplete
    keywords = params[:keywords] ||= nil

    json = autocomplete_taxons(keywords)
    json += Spree::Product.autocomplete(keywords)

    render json: json
  end

  private

  def autocomplete_taxons(keywords)
    taxons = Spree::Taxonomy.first.taxons.where("name ilike ?", "%#{keywords}%")
    taxons.take(3).map do |t|
      {
          id: t.id,
          type: 'taxon',
          value: t.name
      }
    end
  end

  def autocomplete_brands(keywords)
    brands = Brand.where("name ilike ?", "%#{keywords}%")
    brands.take(3).map do |b|
      {
          id: b.id,
          type: 'brand',
          value: b.name
      }
    end
  end

  def load_taxon
    @taxon = Spree::Taxon.friendly.find(params[:id]) if params[:id]
  end
end
