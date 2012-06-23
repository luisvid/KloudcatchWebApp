ActionMailer::Base.smtp_settings = {
  :address => "mail.kloudcatch.com",
  :port => 587,
  :domain => "kloudcatch.com",
  :user_name => "notifier.kloudcatch",
  :password => "2102_luisvid",
  :authentication => "plain",
  :enable_starttls_auto => false
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
