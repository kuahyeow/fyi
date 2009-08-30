# app/controllers/comment_controller.rb:
# Show annotations upon a request or other object.
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: comment_controller.rb,v 1.9 2009-03-09 01:17:04 francis Exp $

class CommentController < ApplicationController
    
    def new
        if params[:type] == 'request'
            @info_request = InfoRequest.find_by_url_title(params[:url_title])
            @track_thing = TrackThing.create_track_for_request(@info_request)
            if params[:comment]
                @comment = Comment.new(params[:comment].merge({
                    :comment_type => 'request', 
                    :user => @user
                }))
            end
        else
            raise "Unknown type " + params[:type]
        end

        # Banned from adding comments?
        if !authenticated_user.nil? && !authenticated_user.can_make_comments?
            @details = authenticated_user.can_fail_html
            render :template => 'user/banned'
            return
        end

        if params[:comment]
            # XXX this check should theoretically be a validation rule in the model
            @existing_comment = Comment.find_by_existing_comment(@info_request.id, params[:comment][:body])
        else
            # Default to subscribing to request when first viewing form
            params[:subscribe_to_request] = true
        end
        
        # See if values were valid or not
        if !params[:comment] || !@existing_comment.nil? || !@comment.valid? || params[:reedit]
            render :action => 'new'
            return
        end

        # Show preview page, if it is a preview
        if params[:preview].to_i == 1
            render :action => 'preview'
            return
        end

        if authenticated?(
                :web => "To post your annotation",
                :email => "Then your annotation to " + @info_request.title + " will be posted.",
                :email_subject => "Confirm your annotation to " + @info_request.title
            )

            # Also subscribe to track for this request, so they get updates
            # (do this first, so definitely don't send alert)
            flash[:notice] = "Thank you for making an annotation!"
            if params[:subscribe_to_request]
                @track_thing = TrackThing.create_track_for_request(@info_request)
                @existing_track = TrackThing.find_by_existing_track(@user, @track_thing)
                if @user && @info_request.user == @user
                    # don't subscribe to own request!
                elsif !@existing_track
                    @track_thing.track_medium = 'email_daily'
                    @track_thing.tracking_user_id = @user.id
                    @track_thing.save!
                    flash[:notice] += " You will also be emailed updates about the request."
                else
                    flash[:notice] += " You are already being emailed updates about the request."
                end
            end

            # This automatically saves dependent objects in the same transaction
            @comment = @info_request.add_comment(params[:comment][:body], authenticated_user)
            @info_request.save!

            # we don't use comment_url here, as then you don't see the flash at top of page
            redirect_to request_url(@info_request)
        else
            # do nothing - as "authenticated?" has done the redirect to signin page for us
        end
    end

end

