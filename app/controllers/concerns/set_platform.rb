module SetPlatform
  extend ActiveSupport::Concern

  included do
    helper_method :platform
  end

  private
    def platform
      @platform ||= ApplicationPlatform.new(request.user_agent)
    end

    def mobile?
      @platform.mobile?
    end

    def desktop?
      @platform.desktop?
    end
end