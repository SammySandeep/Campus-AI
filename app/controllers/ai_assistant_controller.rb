class AiAssistantController < ApplicationController
  def show
    @history = assistant_history
    @suggestions = suggestions_for(current_user)
  end

  def create
    question = params[:question].to_s.strip.first(240)
    if question.blank?
      redirect_to assistant_path, alert: "Please enter a question."
      return
    end

    answer = Ai::AssistantService.new(user: current_user).ask(question)
    history = assistant_history
    history << { "role" => "user", "content" => question }
    history << { "role" => "assistant", "content" => answer.to_s.first(700) }
    session[:assistant_history] = history.last(8)
    redirect_to assistant_path(anchor: "latest")
  end

  def destroy
    session.delete(:assistant_history)
    redirect_to assistant_path, notice: "Conversation cleared."
  end

  private

  def assistant_history
    Array(session[:assistant_history]).filter_map do |message|
      next unless message.is_a?(Hash) && message["role"].in?(%w[user assistant])
      { role: message["role"], content: message["content"].to_s }
    end
  end

  def suggestions_for(user)
    common = [
      "What classes do I have today?",
      "What assignments are due this week?",
      "Show upcoming campus events",
      "What can you help me with?"
    ]

    role_prompts = if user.student?
      [
        "Show my attendance and warn me if it is low",
        "What placement drives am I eligible for?",
        "Explain my placement eligibility",
        "Show my active projects and milestones",
        "What complaints are still open?",
        "How many unread notifications do I have?",
        "Give me my academic overview",
        "What should I focus on today?"
      ]
    elsif user.faculty?
      [
        "Which assignments are awaiting grading?",
        "Show my recent student submissions",
        "Which projects are awaiting review?",
        "Summarize attendance for my courses",
        "Show my teaching overview",
        "What should I focus on today?"
      ]
    else
      [
        "How many open complaints exist?",
        "Show the complaint status summary",
        "Which department has the lowest average attendance?",
        "Which students are at attendance risk?",
        "Show active placement drives",
        "Give me a campus operations overview",
        "What should I focus on today?"
      ]
    end

    (role_prompts + common).uniq
  end
end
