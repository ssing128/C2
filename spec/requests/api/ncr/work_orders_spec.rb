describe 'NCR Work Orders API' do
  def get_json(url)
    get(url)
    JSON.parse(response.body)
  end

  def time_to_s(time)
    time.iso8601(3)
  end

  describe 'GET /api/v1/ncr/work_orders.json' do
    it "responds with the list of work orders" do
      proposal = FactoryGirl.create(:proposal)
      work_order = FactoryGirl.create(:ncr_work_order, proposal: proposal)

      json = get_json('/api/v1/ncr/work_orders.json')

      expect(json).to eq([
        {
          'amount' => work_order.amount.to_s, # TODO should not be a string
          'building_number' => work_order.building_number,
          'code' => work_order.code,
          'emergency' => work_order.emergency,
          'expense_type' => work_order.expense_type,
          'id' => work_order.id,
          'not_to_exceed' => work_order.not_to_exceed,
          'office' => work_order.office,
          'proposal' => {
            'created_at' => time_to_s(proposal.created_at),
            'flow' => proposal.flow,
            'id' => proposal.id,
            'requester' => nil,
            'status' => 'pending',
            'updated_at' => time_to_s(proposal.updated_at)
          },
          'rwa_number' => work_order.rwa_number,
          'vendor' => work_order.vendor
        }
      ])
    end

    it "includes the requester" do
      proposal = FactoryGirl.create(:proposal, :with_requester)
      requester = proposal.requester
      work_order = FactoryGirl.create(:ncr_work_order, proposal: proposal)

      json = get_json('/api/v1/ncr/work_orders.json')

      expect(json[0]['proposal']['requester']).to eq({
        'created_at' => time_to_s(requester.created_at),
        'id' => requester.id,
        'updated_at' => time_to_s(requester.updated_at)
      })
    end

    it "includes approvers"

    it "includes observers"

    it "responds with an empty list for no work orders" do
      json = get_json('/api/v1/ncr/work_orders.json')
      expect(json).to eq([])
    end

    describe "CORS" do
      let(:origin) { 'http://corsexample.com/' }
      let(:headers) {
        {
          'HTTP_ORIGIN' => origin,
          'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'GET'
        }
      }

      it "sets the Access-Control-Allow-Origin header to allow requests from anywhere" do
        get '/api/v1/ncr/work_orders.json', {}, headers
        expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
      end

      it "allows general HTTP methods (GET/POST/PUT)" do
        get '/api/v1/ncr/work_orders.json', {}, headers

        allowed_http_methods = response.header['Access-Control-Allow-Methods']
        %w{GET POST PUT}.each do |method|
          expect(allowed_http_methods).to include(method)
        end
      end

      it "supports OPTIONS requests" do
        options '/api/v1/ncr/work_orders.json', {}, headers
        expect(response.status).to eq(200)
        expect(response.body).to eq('')
      end
    end
  end
end
