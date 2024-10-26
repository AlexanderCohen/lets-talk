# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    # Base configuration
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self, :https, "'unsafe-inline'", "'unsafe-eval'"
    policy.style_src   :self, :https, "'unsafe-inline'"

    # Development-specific sources
    if Rails.env.development?
      dev_sources = [
        "http://lvh.me:3000",
        "ws://lvh.me:3000",
        "http://localhost:3000",
        "ws://localhost:3000",
        "http://localhost:3100",  # Added for Vite
        "ws://localhost:3100"     # Added for Vite HMR
      ]
    end

    # Production-specific sources
    prod_sources = if Rails.env.production?
      [
        "https://lets-talk-together.com",
        "wss://lets-talk-together.com",
        "https://lets-talk-prod.s3.ap-southeast-2.amazonaws.com"
      ]
    else
      []
    end

    # Combine sources for connect-src
    policy.connect_src(
      :self,
      :https,
      *(dev_sources || []),
      *prod_sources
    )

    # Allow blob: URLs for media playback
    policy.media_src(
      :self,
      :https,
      'blob:',
      *(dev_sources || []),
      *prod_sources
    )
  end

  # Report CSP violations in development, enforce in production
  config.content_security_policy_report_only = Rails.env.development?

  # Remove nonce generation as we're using unsafe-inline
  config.content_security_policy_nonce_generator = nil
  config.content_security_policy_nonce_directives = []
end
