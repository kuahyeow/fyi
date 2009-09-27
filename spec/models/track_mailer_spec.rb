require File.dirname(__FILE__) + '/../spec_helper'

describe TrackMailer do

    describe 'delivering the email' do
        it 'should deliver one email, with right headers' do
            @user = mock_model(User, 
                    :name_and_email => TMail::Address.address_from_name_and_email('Tippy Test', 'tippy@localhost'),
                    :url_name => 'tippy_test'
            )

            TrackMailer.deliver_event_digest(@user, []) # no items in it email for minimal test
            deliveries = ActionMailer::Base.deliveries
            deliveries.size.should == 1
            mail = deliveries[0]

            mail['Auto-Submitted'].to_s.should == 'auto-generated'
        end
    end

end



