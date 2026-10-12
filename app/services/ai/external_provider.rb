module Ai
  class ExternalProvider
    def ask(user:, question:)
      return DemoProvider.new.ask(user: user, question: question) if ENV["OPENAI_API_KEY"].blank?
      "External AI is configured as an extension point. Add an approved HTTP client integration here; no student data is sent by this demo."
    end
  end
end
