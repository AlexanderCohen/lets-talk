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

    # Build connect sources based on environment
    connect_sources = [:self, :https]
    if Rails.env.development?
      connect_sources.push(
        "http://lvh.me:3000",
        "ws://lvh.me:3000",
        "http://localhost:3000",
        "ws://localhost:3000"
      )
    end

    if Rails.env.production?
      connect_sources.push(
        "https://lets-talk-together.com",
        "wss://lets-talk-together.com",
        "https://lets-talk-prod.s3.ap-southeast-2.amazonaws.com"
      )
    end

    policy.connect_src(*connect_sources)

    # Media sources
    media_sources = [:self, :https]
    if Rails.env.development?
      media_sources.push("http://lvh.me:3000", "http://localhost:3000")
    else
      media_sources.push("https://lets-talk-together.com")
    end
    media_sources.push("https://lets-talk-prod.s3.ap-southeast-2.amazonaws.com")
    
    policy.media_src(*media_sources)
  end

  # Remove nonce generation as we're using unsafe-inline
  config.content_security_policy_nonce_generator = nil
  config.content_security_policy_nonce_directives = []

  # Report CSP violations in production
  config.content_security_policy_report_only = Rails.env.development?
end
