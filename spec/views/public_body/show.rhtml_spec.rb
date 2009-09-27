require File.dirname(__FILE__) + '/../../spec_helper'

describe "when viewing a body" do

    before do
        @pb = mock_model(PublicBody, 
                         :name => 'Test Quango', 
                         :short_name => 'tq',
                         :url_name => 'testquango', 
                         :notes => '',
                         :charity_number => '',
                         :type_of_authority => 'A public body',
                         :eir_only? => nil,
                         :info_requests => [1, 2, 3, 4], # out of sync with Xapian
                         :publication_scheme => '',
                         :calculated_home_page => '')
        @pb.stub!(:is_requestable?).and_return(true)
        @pb.stub!(:has_notes?).and_return(false)
        
        assigns[:public_body] = @pb
        assigns[:track_thing] = mock_model(TrackThing, 
            :track_type => 'public_body_updates', :public_body => @pb, :params => {})
        assigns[:page] = 1
        assigns[:per_page] = 10
    end

    it "should be successful" do
        render "public_body/show"
        response.should be_success
    end

    it "should be valid HTML" do
        render "public_body/show"
        validate_as_body response.body 
    end

    it "should show the body's name" do
        render "public_body/show"
        response.should have_tag("h1", "Test Quango")
    end

    it "should tell total number of requests" do
        render "public_body/show"
        response.should have_tag("h2", "4 Freedom of Information requests made")
    end

    it "should cope with Xapian being down" do
        assigns[:xapian_requests] = nil
        render "public_body/show"
        response.should have_tag("p", /The search index is currently offline/m)
    end

    it "should link to Charity Commission site if we have a number" do
        @pb.stub!(:charity_number).and_return('98765')
        render "public_body/show"
        response.should have_tag("div#request_sidebar") do
            with_tag("a[href*=?]", /charity-commission.gov.uk.*RegisteredCharityNumber=98765$/)
        end
    end 

    it "should not link to Charity Commission site if we don't have number" do
        render "public_body/show"
        response.should have_tag("div#request_sidebar") do
            without_tag("a[href*=?]", /charity-commission.gov.uk/)
        end
    end 


end

def mock_event 
    return mock_model(InfoRequestEvent, 
        :info_request => mock_model(InfoRequest, 
            :title => 'Title', 
            :url_title => 'title',
            :display_status => 'awaiting_response',
            :calculate_status => 'awaiting_response',
            :public_body => @pb,
            :user => mock_model(User, :name => 'Test User', :url_name => 'testuser')
        ),
        :incoming_message => nil, :is_incoming_message? => false,
        :outgoing_message => nil, :is_outgoing_message? => false,
        :comment => nil,          :is_comment? => false,
        :event_type => 'sent',
        :created_at => Time.now - 4.days,
        :search_text_main => ''
    )
end

