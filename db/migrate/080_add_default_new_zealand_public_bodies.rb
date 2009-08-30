class AddDefaultNewZealandPublicBodies < ActiveRecord::Migration
  def self.up
    pb = PublicBody.create(
      :name => "Test Body",
      :short_name => "TB",
      :request_email => "whut@example.com",
      :version => 1,
      :last_edit_editor => "automated",
      :last_edit_comment => "automated",
      :url_name => "Test Body Home Page",
      :home_page => "http://example.com/",
      :notes => "",
      :first_letter => "T"
    )
    pb.public_body_tags.create(:name => "executive_agency")
  end

  def self.down
    PublicBody.find(:all).each(&:destroy)
  end
end
