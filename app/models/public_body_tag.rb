# == Schema Information
# Schema version: 78
#
# Table name: public_body_tags
#
#  id             :integer         not null, primary key
#  public_body_id :integer         not null
#  name           :text            not null
#  created_at     :datetime        not null
#

# models/public_body_tag.rb:
# Categories for public bodies.
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: public_body_tag.rb,v 1.28 2009-06-26 14:28:38 francis Exp $

class PublicBodyTag < ActiveRecord::Base
    strip_attributes!

    validates_presence_of :public_body
    validates_presence_of :name

    belongs_to :public_body
end

