require "rails_helper"

RSpec.describe ReturnRequestProcessorJob, type: :job do
  it "processes the return request through the service" do
    request = create(:return_request)

    expect(Services::ReturnRequestProcessor).to receive(:process).with(request)

    described_class.perform_now(request.id)
  end

  it "returns quietly if record is missing" do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end

