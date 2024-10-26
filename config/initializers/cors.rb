Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Define allowed origins based on environment
    origins_list = if Rails.env.development?
      ['localhost:3000', 'lvh.me:3000']
    else
      ['https://lets-talk-together.com']
    end

    origins *origins_list

    # Allow Active Storage endpoints
    resource '/rails/active_storage/*',
      headers: :any,
      methods: [:get, :head, :options],
      credentials: true,
      expose: ['Content-Disposition']
  end
end
