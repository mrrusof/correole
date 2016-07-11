class Item < ActiveRecord::Base
  validates :title, presence: true
  validates :description, presence: true
  validates :link, presence: true, format: /http.+/

  def ==(o)
    return o.class == self.class &&
      o.title == self.title &&
      o.description == self.description &&
      o.link == self.link &&
      o.pub_date == self.pub_date &&
      o.id == self.id &&
      o.created_at == self.created_at &&
      o.updated_at == self.updated_at
  end

end
