Spree::TaxonsController.class_eval do
  before_action :load_taxon, only: [:best_selling]

  def show
    @taxon = Spree::Taxon.find_by!(permalink: params[:id])
    return unless @taxon

    @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end
  # Sort by conversions desc
  def best_selling
    params.merge(taxon: @taxon.id) if @taxon
    @searcher = build_searcher(params.merge(conversions: true))
    @products = @searcher.retrieve_products
    render action: :index
  end

  def autocomplete
    keywords = params[:keywords] ||= nil
    json = Spree::Product.autocomplete(keywords)
    render json: json
  end

  private

  def load_taxon
    @taxon = Spree::Taxon.friendly.find(params[:id]) if params[:id]
  end
end
