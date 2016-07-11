describe 'Item' do

  describe '#==' do

    let(:now) { Time.now }

    it 'returns true for instances with same properties' do
      i1 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      i2 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      assert i1 == i2
    end

    it 'returns false for instances with different titles' do
      i1 = Item.new(title: 'Title1',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      i2 = Item.new(title: 'Title2',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      refute i1 == i2
    end

    it 'returns false for instances with different descriptions' do
      i1 = Item.new(title: 'Title',
                    description: 'Description1',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      i2 = Item.new(title: 'Title',
                    description: 'Description2',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      refute i1 == i2
    end

    it 'returns false for instances with different links' do
      i1 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com1',
                    pub_date: now)
      i2 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com2',
                    pub_date: now)
      refute i1 == i2
    end

    it 'returns false for instances with different dates' do
      i1 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: nil)
      i2 = Item.new(title: 'Title',
                    description: 'Description',
                    link: 'http://ruslanledesma.com',
                    pub_date: now)
      refute i1 == i2
    end

  end

end
