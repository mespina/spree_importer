class NotificationMailer < ActionMailer::Base
  default from: Spree::Config[:importer_from]

  def error filename, failed_rows
    @filename    = filename
    @failed_rows = failed_rows

    mail to: Spree::Config[:importer_to], subject: I18n.t(:error, scope: [:spree, :spree_importer, :messages, :notification], filename: filename)
  end

  def successfully filename
    @filename  = filename

    mail to: Spree::Config[:importer_to], subject: I18n.t(:success, scope: [:spree, :spree_importer, :messages, :notification], filename: filename)
  end
end
