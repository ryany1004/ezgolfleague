module CacheKeyable
  extend ActiveSupport::Concern

  def cache_key(type = nil) # NOTE: May want to retire this with Rails 6, or change the name
    key = "#{self.class.name}-#{id}-#{updated_at.to_i}"
    key = "#{key}-#{type}" if type

    key
  end

  def relation_cache_key(relation, type = nil)
    max_updated_at = relation.maximum(:updated_at).try(:utc).try(:to_s, :number)
    key = "#{self.class.name}-#{relation.first.class.name}-#{id}-#{max_updated_at}"
    key = "#{key}-#{type}" if type

    key
  end
end
