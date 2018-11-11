module Servable
  extend ActiveSupport::Concern

  def server_id
    return self.id.to_s
  end
end