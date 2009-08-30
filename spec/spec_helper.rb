# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end

# XXX No idea what namespace/class/module to put this in 
def receive_incoming_mail(email_name, email_to, email_from = 'geraldinequango@localhost')
    email_name = File.join(Spec::Runner.configuration.fixture_path, email_name)
    content = File.read(email_name)
    content.gsub!('EMAIL_TO', email_to)
    content.gsub!('EMAIL_FROM', email_from)
    RequestMailer.receive(content)
end

def load_image_fixture(image_name)
    image_name = File.join(Spec::Runner.configuration.fixture_path, image_name)
    content = File.read(image_name)
    return content
end

def rebuild_xapian_index
    rebuild_name = File.dirname(__FILE__) + '/../script/rebuild-xapian-index'
    Kernel.system(rebuild_name) or raise "failed to launch rebuild-xapian-index"
end

# Validate an entire HTML page
def validate_html(html)
    $tempfilecount = $tempfilecount + 1
    tempfilename = File.join(Dir::tmpdir, "railshtmlvalidate."+$$.to_s+"."+$tempfilecount.to_s+".html")
    File.open(tempfilename, "w+") do |f|
        f.puts html
    end
    if not system($html_validation_script, tempfilename)
        raise "HTML validation error in " + tempfilename + " HTTP status: " + @response.response_code.to_s
    end
    File.unlink(tempfilename)
    return true
end

# Validate HTML fragment by wrapping it as the <body> of a page
def validate_as_body(html)
    validate_html('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">' +
        "<html><head><title>Test</title></head><body>#{html}</body></html>")
end

# Monkeypatch! Validate HTML in tests.
$html_validation_script = "/usr/bin/validate" # from Debian package wdg-html-validator
if $tempfilecount.nil?
    $tempfilecount = 0
    if File.exist?($html_validation_script)
        module ActionController
            module TestProcess
                # Hook into the process function, so can automatically get HTML after each request
                alias :original_process :process

                def process(action, parameters = nil, session = nil, flash = nil)
                    # Call original process function
                    self.original_process(action, parameters, session, flash)

                    # XXX Is there a better way to check this than calling a private method?
                    return unless @response.template.controller.instance_eval { integrate_views? }

                    # And then if HTML, not a redirect (302), and not a partial template (something/_something, such as in AJAX partial results)
                    if @response.content_type == "text/html" and @response.response_code != 302 and not @response.rendered_file.include?("/_")
                        validate_html(@response.body)
                    end
                end
            end
        end
    else
        puts "WARNING: HTML validation script " + $html_validation_script + " not found"
    end
end

