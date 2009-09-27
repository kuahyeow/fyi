require File.dirname(__FILE__) + '/../spec_helper'

describe GeneralController, "when searching" do
    integrate_views
    fixtures :info_requests, :info_request_events, :public_bodies, :users

    it "should render the front page successfully" do
        get :index
        response.should be_success
    end

    it "should redirect from search query URL to pretty URL" do
        post :search_redirect, :query => "mouse" # query hidden in POST parameters
        response.should redirect_to(:action => 'search', :combined => "mouse") # URL /search/:query
    end
  
    it "should show help when searching for nothing" do
        get :search_redirect, :query => nil
        response.should render_template('search')
        assigns[:total_hits].should be_nil
        assigns[:query].should be_nil
    end
end

