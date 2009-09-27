# models/track_mailer.rb:
# Emails which go to users who are tracking things.
#
# Copyright (c) 2008 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: track_mailer.rb,v 1.21 2009-06-27 03:21:23 francis Exp $

class TrackMailer < ApplicationMailer
    def event_digest(user, email_about_things)
        post_redirect = PostRedirect.new(
            :uri => main_url(user_url(user)) + "#email_subscriptions",
            :user_id => user.id)
        post_redirect.save!
        unsubscribe_url = confirm_url(:email_token => post_redirect.email_token)

        @from = contact_from_name_and_email
        headers 'Auto-Submitted' => 'auto-generated' # http://tools.ietf.org/html/rfc3834
        # 'Return-Path' => blackhole_email, 'Reply-To' => @from # we don't care about bounces for tracks
        # (We let it return bounces for now, so we can manually kill the tracks that bounce so Yahoo
        # etc. don't decide we are spammers.)

        @recipients = user.name_and_email
        @subject = "Your WhatDoTheyKnow.com email alert"
        @body = { :user => user, :email_about_things => email_about_things, :unsubscribe_url => unsubscribe_url }
    end
end


