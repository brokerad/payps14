class EngageNotifier < ActionMailer::Base

  default :from         => "noreply@paypersocial.com",
          :return_path   => "noreply@paypersocial.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.engage_notifier.engage_complete.subject
  #
  def engage_complete publisher
    @publisher = publisher

    # Sending email to the publisher
    mail :to => publisher.email
  end

  # This method sends email to admins eache time a new publisher ends the engagement process.
  # Email addresses are located in: config/admin_emails.txt
  def new_publisher_joined_us(publisher)
    @publisher = publisher
    addresses = Array.new

    # Collecting admin email addresses
    File.open("config/admin_emails.txt", "r").each_line do |line|
      address = line.split(/\n/)[0]
      addresses.push address unless (address.first == '#' or address.first.empty?)
    end

    # Sending email to admins
    mail :to => addresses
  end
end
