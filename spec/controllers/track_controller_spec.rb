require File.dirname(__FILE__) + '/../spec_helper'

describe TrackController, "when making a new track on a request" do
    before do
        @ir = mock_model(InfoRequest, :url_title => 'myrequest', :title => 'My request')
        InfoRequest.stub!(:find_by_url_title).and_return(@ir)

        @user = mock_model(User)
        User.stub!(:find).and_return(@user)
    end

    it "should require login when making new track" do
        get :track_request, :url_title => @ir.url_title, :feed => 'track'
        post_redirect = PostRedirect.get_last_post_redirect
        response.should redirect_to(:controller => 'user', :action => 'signin', :token => post_redirect.token)
    end

    it "should make track and redirect if you are logged in " do
        old_count = TrackThing.count
        session[:user_id] = @user.id
        get :track_request, :url_title => @ir.url_title, :feed => 'track'
        TrackThing.count.should == old_count + 1
        response.should redirect_to(:controller => 'request', :action => 'show', :url_title => @ir.url_title)
    end

end 

