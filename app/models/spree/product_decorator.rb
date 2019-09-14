Spree::Product.class_eval do
  searchkick word_start: [:name], settings: {number_of_replicas: 0} unless respond_to?(:searchkick_index)

  def search_data
    json = {
      id: id,
      name: name,
      description: description,
      active: available?,
      created_at: created_at,
      updated_at: updated_at,
      price: price,
      currency: currency,
      conversions: orders.complete.count,
      taxon_ids: taxon_and_ancestors.map(&:id),
      taxon_names: taxon_and_ancestors.map(&:name)
    }

    Spree::Property.all.each do |prop|
      json.merge!(Hash[prop.name.downcase, property(prop.name)])
    end

    Spree::Taxonomy.all.each do |taxonomy|
      json.merge!(Hash["category", taxon_by_taxonomy(taxonomy.id).map(&:id)])
    end

    json
  end

  def taxon_by_taxonomy(taxonomy_id)
    taxons.joins(:taxonomy).where(spree_taxonomies: { id: taxonomy_id })
  end

  def self.autocomplete(keywords)
    if keywords
      Spree::Product.search(
        keywords,
        fields: [:name],
        match: :word_start,
        limit: 10,
        load: false,
        misspellings: {below: 3},
        where: search_where
      ).map(&:name).map(&:strip).uniq
    else
      Spree::Product.search(
        '*',
        fields: [:name],
        load: false,
        misspellings: {below: 3},
        where: search_where
      ).map(&:name).map(&:strip)
    end
  end

  def self.search_where
    {
      active: true,
      price: { not: nil }
    }
  end
end
