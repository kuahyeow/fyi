# app/controllers/request_controller.rb:
# Show information about one particular request.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: request_controller.rb,v 1.170 2009-08-20 11:05:24 francis Exp $

class InfoRequestsController < ApplicationController
  def new
    @public_body = PublicBody.find_by_url_name(params[:public_body_id])
    @request = InfoRequest.new(:public_body => @public_body)
  end

  def index
    @status = params[:status]
    if @status == 'recent'
      @title = "Recently sent Freedom of Information requests"
      query = "variety:sent";
      sortby = "newest"
      @track_thing = TrackThing.create_track_for_all_new_requests
    elsif @status == 'successful'
      @title = "Recently successful responses"
      query = 'variety:response (status:successful OR status:partially_successful)'
      sortby = "described"
      @track_thing = TrackThing.create_track_for_all_successful_requests
    else
      raise "unknown request list view #{@status}"
    end
    @xapian_object = perform_search([InfoRequestEvent], query, sortby, 'request_collapse')
    @title = @title + " (page " + @page.to_s + ")" if (@page > 1)

    @feed_autodetect = [ { :url => do_track_url(@track_thing, 'feed'), :title => @track_thing.params[:title_in_rss] } ]

    cache_in_squid
    @requests = InfoRequest.paginate(:all, :per_page => 25, :page => params[:page] || 1)
  end

  def create
    @request = PublicBody.create(params[:info_request])
    if @request.save
      
    end
  end
end

