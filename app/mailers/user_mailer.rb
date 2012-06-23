class UserMailer < ActionMailer::Base
  default from: "notifier@kloudcatch.com"

  def reset_password_email(user)
    @user = user
    @url = CustomHelper.app_url + "/password_resets/#{user.reset_password_token}/edit" 
    mail(to: user.email, :subject => I18n.t(:subject, :scope => [:user_mailer, :reset_password_email]))
  end

  def inactive_dropbox_email(user)
    @user = user
    @url = CustomHelper.app_url + "/account"
    mail(to: user.email, :subject => I18n.t(:subject, :scope => [:user_mailer, :inactive_dropbox_email]))
    user.inactive_dropbox_email_sent_at = DateTime.now
    user.save
  end

  def dropbox_quota_warning(user)
    @user = user
    mail(to: user.email, :subject => I18n.t(:subject, :scope => [:user_mailer, :dropbox_quota_warning]))
    user.save
  end

  def signup_confirmation(user)
    @user = user
    mail(to: user.email, :subject => I18n.t(:subject, :scope => [:user_mailer, :signup_confirmation]))
  end
end
