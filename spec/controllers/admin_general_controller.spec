require File.dirname(__FILE__) + '/../spec_helper'

describe AdminGeneralController, "when viewing front page of admin interface" do
    integrate_views
  
    it "should render the front page" do
        get :index
        response.should render_template('index')
    end

end
