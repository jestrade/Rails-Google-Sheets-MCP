require "faraday"
require "json"

class GeminiService
  def initialize(api_key: ENV["GEMINI_API_KEY"], model: ENV["GEMINI_MODEL"])
    @api_key = api_key
    @model = model
  end

  def generate_content(prompt)
    conn = Faraday.new(
      url: "https://generativelanguage.googleapis.com",
      params: { key: @api_key },
      headers: { "Content-Type" => "application/json" }
    )

    body = {
      contents: [
        {
          role: "user",
          parts: [ { text: prompt } ]
        }
      ]
    }

    response = conn.post("/v1beta/models/#{@model}:generateContent", body.to_json)

    if response.success?
      data = JSON.parse(response.body)
      data.dig("candidates", 0, "content", "parts", 0, "text") || "No response from Gemini."
    else
      Bugsnag.notify("Gemini API error: #{response.status} #{response.body}")
      "No response from Gemini."
    end
  rescue => e
    Bugsnag.notify(e)
    "No response from Gemini."
  end

  def generate_product_confirmation(product)
    prompt = <<~PROMPT
      A new product is being added to a Google Sheet.
      Product details: SKU is "#{product["sku"]}", Name is "#{product["name"]}", and Price is #{product["price"]}.
      Generate a short, friendly confirmation message for the user, confirming the product has been added.
    PROMPT

    generate_content(prompt)
  end
end
