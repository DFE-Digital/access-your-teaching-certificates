require_relative "fake_qualifications_data"

class FakeQualificationsApi < Sinatra::Base
  include FakeQualificationsData

  get "/v3/teacher" do
    content_type :json

    case bearer_token
    when "token"
      quals_data.to_json
    when "no-itt-token"
      quals_data(trn: "1234567", itt: false).to_json
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/teachers" do
    content_type :json

    case bearer_token
    when "token"
      return { total: 0, results: [] }.to_json if params["lastName"] == "No match"

      {
        total: 1,
        results: [teacher_data(sanctions: params["lastName"] == "Restricted")]
      }.to_json
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/teachers/:trn" do
    content_type :json

    trn = params[:trn]
    case bearer_token
    when "token"
      if trn == "1234567"
        quals_data(trn: "1234567").to_json
      elsif trn == "987654321"
        quals_data(trn:).to_json
      else
        halt 404
      end
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/npq/:id" do
    content_type "application/pdf"
    attachment "npq_certificate.pdf"

    case bearer_token
    when "token"
      if params[:id] == "missing"
        halt 404
      else
        "pdf data"
      end
    when "invalid-token"
      halt 401
    end
  end

  get "/v3/certificates/:id" do
    content_type "application/pdf"
    attachment "#{params[:id]}_certificate.pdf"

    case bearer_token
    when "token"
      "pdf data"
    when "invalid-token"
      halt 401
    end
  end

  private

  def teacher_data(sanctions: false, trn: "1234567")
    sanctions ? sanctions_data : no_sanctions_data(trn:)
  end

  def no_sanctions_data(trn:)
    {
      dateOfBirth: "2000-01-01",
      firstName: "Terry",
      lastName: "Walsh",
      middleName: "John",
      sanctions: [],
      trn:
    }
  end

  def sanctions_data
    {
      dateOfBirth: "2000-01-01",
      firstName: "Teacher",
      lastName: "Restricted",
      middleName: "",
      sanctions: [
        {
          code: "C2",
          startDate: "2019-10-25"
        }
      ],
      trn: "987654321"
    }
  end

  def bearer_token
    auth_header = request.env.fetch("HTTP_AUTHORIZATION")
    auth_header.delete_prefix("Bearer ")
  end
end
