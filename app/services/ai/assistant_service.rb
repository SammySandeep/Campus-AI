module Ai
  class AssistantService
    def initialize(user:, provider: nil)
      provider_name = provider || ENV.fetch("AI_PROVIDER", "demo")
      @provider = provider_name == "external" ? ExternalProvider.new : DemoProvider.new
      @user = user
    end

    def ask(question)
      @provider.ask(user: @user, question: question.to_s)
    end
  end
end
