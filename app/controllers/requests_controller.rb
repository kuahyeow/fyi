# app/controllers/request_controller.rb:
# Show information about one particular request.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: request_controller.rb,v 1.170 2009-08-20 11:05:24 francis Exp $

class RequestsController < ApplicationController
  def new
    @public_body = PublicBody.find_by_url_name(params[:public_body_id])
    @request = InfoRequest.new(:public_body => @public_body)
  end

  def index
    @requests = InfoRequest.paginate(:all, :per_page => 25, :page => params[:page] || 1)
  end

  def create
    @request = PublicBody.create(params[:info_request])
    if @request.save
      
    end
  end
end

