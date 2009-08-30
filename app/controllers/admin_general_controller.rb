# app/controllers/admin_controller.rb:
# Controller for main admin pages.
#
# Copyright (c) 2007 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: admin_general_controller.rb,v 1.9 2009-07-16 15:46:08 francis Exp $

class AdminGeneralController < AdminController
    def index
        # Overview counts of things
        @user_count = User.count
        @public_body_count = PublicBody.count
        @info_request_count = InfoRequest.count
        @track_thing_count = TrackThing.count
        @comment_count = Comment.count

        # Tasks to do
        @requires_admin_requests = InfoRequest.find(:all, :select => '*, ' + InfoRequest.last_event_time_clause + ' as last_event_time', :conditions => ["described_state = 'requires_admin'"], :order => "last_event_time")
        @error_message_requests = InfoRequest.find(:all, :select => '*, ' + InfoRequest.last_event_time_clause + ' as last_event_time', :conditions => ["described_state = 'error_message'"], :order => "last_event_time")
        @blank_contacts = PublicBody.find(:all, :conditions => ["request_email = ''"], :order => "updated_at")
        @old_unclassified = InfoRequest.find_old_unclassified(:limit => 50, 
                                                                       :conditions => ["prominence = 'normal'"],
                                                                       :age_in_days => 10)
        @holding_pen_messages = InfoRequest.holding_pen_request.incoming_messages
    end

    def timeline
        # Recent events
        @events_title = "Events in last two days"
        date_back_to = Time.now - 2.days
        if params[:hour]
            @events_title = "Events in last hour"
            date_back_to = Time.now - 1.hour
        end
        if params[:day]
            @events_title = "Events in last day"
            date_back_to = Time.now - 1.day
        end
        if params[:week]
            @events_title = "Events in last week"
            date_back_to = Time.now - 1.week
        end
        if params[:month]
            @events_title = "Events in last month"
            date_back_to = Time.now - 1.month
        end
        if params[:all]
            @events_title = "Events, all time"
            date_back_to = Time.now - 1000.years
        end
        @events = InfoRequestEvent.find(:all, :order => "created_at desc, id desc",
                :conditions => ["created_at > ? ", date_back_to.getutc])
        @public_body_history = PublicBody.versioned_class.find(:all, :order => "updated_at desc, id desc",
                :conditions => ["updated_at > ? ", date_back_to.getutc])
        for pbh in @public_body_history
            pbh.created_at = pbh.updated_at
        end
        @events += @public_body_history

        @events.sort! { |a,b| b.created_at <=> a.created_at }
    end

    def stats
        @request_by_state = InfoRequest.count(:group => 'described_state')
        @tracks_by_type = TrackThing.count(:group => 'track_type')
    end

    def debug
        @request_env = request.env 
    end
end

