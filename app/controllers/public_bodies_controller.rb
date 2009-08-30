# app/controllers/body_controller.rb:
# Show information about a public body.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: public_body_controller.rb,v 1.4 2009-07-14 23:30:37 francis Exp $

class PublicBodiesController < ApplicationController

  def index
    @public_bodies = PublicBody.find(:all)
  end

  def show
    @public_body = PublicBody.find_by_url_name(params[:id])
    @track_thing = TrackThing.create_track_for_public_body(@public_body)
  end
end

