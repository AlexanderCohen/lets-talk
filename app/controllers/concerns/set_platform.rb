module SetPlatform
  extend ActiveSupport::Concern

  included do
    helper_method :platform
    before_action :set_platform
  end

  private
    def platform
      @platform
    end

    def set_platform
      @platform = ApplicationPlatform.new(request.user_agent)
    end

    def mobile?
      @platform.mobile?
    end

    def desktop?
      @platform.desktop?
    end
end