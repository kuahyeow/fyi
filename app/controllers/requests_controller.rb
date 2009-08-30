# app/controllers/request_controller.rb:
# Show information about one particular request.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: request_controller.rb,v 1.170 2009-08-20 11:05:24 francis Exp $

class RequestsController < ApplicationController


  def index
    @requests = InfoRequest.paginate(:all, :per_page => 25, :page => params[:page] || 1)
  end
end

