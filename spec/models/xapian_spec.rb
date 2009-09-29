require File.dirname(__FILE__) + '/../spec_helper'

describe User, " when indexing users with Xapian" do
    fixtures :users

    before(:all) do
        rebuild_xapian_index
    end

    it "should search by name" do
          # def InfoRequest.full_search(models, query, order, ascending, collapse, per_page, page)
        xapian_object = InfoRequest.full_search([User], "Silly", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        xapian_object.results[0][:model].should == users(:silly_name_user)
    end

end

describe PublicBody, " when indexing public bodies with Xapian" do
    fixtures :public_bodies

    before(:all) do
        rebuild_xapian_index
    end

    it "should search index the main name field" do
        xapian_object = InfoRequest.full_search([PublicBody], "humpadinking", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        xapian_object.results[0][:model].should == public_bodies(:humpadink_public_body)
    end

    it "should search index the notes field" do
        xapian_object = InfoRequest.full_search([PublicBody], "albatross", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        xapian_object.results[0][:model].should == public_bodies(:humpadink_public_body)
    end

end

describe PublicBody, " when indexing requests by body they are to" do
    fixtures :public_bodies, :info_request_events, :info_requests

    it "should find requests to the body" do
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_from:tgq", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
    end

    it "should update index correctly when URL name of body changes" do
        verbose = false

        # initial search
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_from:tgq", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
        models_found_before = xapian_object.results.map { |x| x[:model] }

        # change the URL name of the body
        body = public_bodies(:geraldine_public_body)
        body.short_name = 'GQ'
        body.save!
        body.url_name.should == 'gq'
        ActsAsXapian.update_index(true, verbose) # true = flush to disk

        # check we get results expected
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_from:tgq", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 0
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_from:gq", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
        models_found_after = xapian_object.results.map { |x| x[:model] }

        models_found_before.should == models_found_after
    end
end

describe User, " when indexing requests by user they are from" do
    fixtures :users, :info_request_events, :info_requests

    it "should find requests from the user" do
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_by:bob_smith", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
    end

    it "should update index correctly when URL name of user changes" do
        verbose = false

        # initial search
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_by:bob_smith", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
        models_found_before = xapian_object.results.map { |x| x[:model] }

        # change the URL name of the body
        u= users(:bob_smith_user)
        u.name = 'Robert Smith'
        u.save!
        u.url_name.should == 'robert_smith'
        ActsAsXapian.update_index(flush_to_disk=true, verbose) 

        # check we get results expected
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_by:bob_smith", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 0
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "requested_by:robert_smith", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 4
        models_found_after = xapian_object.results.map { |x| x[:model] }

        models_found_before.should == models_found_after
    end
end

describe User, " when indexing comments by user they are by" do
    fixtures :users, :info_request_events, :info_requests, :comments

    it "should find requests from the user" do
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "commented_by:silly_emnameem", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
    end

    it "should update index correctly when URL name of user changes" do
        verbose = false

        # initial search
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "commented_by:silly_emnameem", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        models_found_before = xapian_object.results.map { |x| x[:model] }

        # change the URL name of the body
        u = users(:silly_name_user)
        u.name = 'Silly Name'
        u.save!
        u.url_name.should == 'silly_name'
        ActsAsXapian.update_index(true, verbose) # true = flush to disk

        # check we get results expected
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "commented_by:silly_emnameem", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 0
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "commented_by:silly_name", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        models_found_after = xapian_object.results.map { |x| x[:model] }

        models_found_before.should == models_found_after
    end
end

describe InfoRequest, " when indexing requests by their title" do
    fixtures :info_request_events, :info_requests

    it "should find events for the request" do
        rebuild_xapian_index
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "request:how_much_public_money_is_wasted_o", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        xapian_object.results[0][:model] == info_request_events(:silly_outgoing_message_event)
    end

    it "should update index correctly when URL title of request changes" do
        verbose = false

        # change the URL name of the body
        rebuild_xapian_index
        ir = info_requests(:naughty_chicken_request)
        ir.title = 'Really naughty'
        ir.save!
        ir.url_title.should == 'really_naughty'
        ActsAsXapian.update_index(true, verbose) # true = flush to disk

        # check we get results expected
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "request:how_much_public_money_is_wasted_o", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 0
        xapian_object = InfoRequest.full_search([InfoRequestEvent], "request:really_naughty", 'created_at', true, nil, 100, 1)
        xapian_object.results.size.should == 1
        xapian_object.results[0][:model] == info_request_events(:silly_outgoing_message_event)
    end
end










