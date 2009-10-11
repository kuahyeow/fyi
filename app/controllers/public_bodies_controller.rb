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

  def by_category
    @public_bodies = PublicBody.tagged_with(params[:category])
    render :template => "index"
  end

  def view_email
    @public_body = PublicBody.find_by_url_name(params[:id])

    if params[:submitted_view_email]
      if verify_recaptcha
        flash.discard(:error)
        render :template => "public_bodies/view_email"
        return
      end
      flash.now[:error] = "There was an error with the words you entered, please try again."
    end
    render :template => "public_bodies/view_email_captcha"
  end

end

