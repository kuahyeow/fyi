# lib/activesupport_cache_extensions.rb:
# Extensions / fixes to ActiveSupport::Cache
#
# Copyright (c) 2009 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: activesupport_cache_extensions.rb,v 1.1 2009-07-01 11:07:32 francis Exp $

# Monkeypatch!

module ActiveSupport
    module Cache
        class FileStore < Store
            # We don't add the ".cache" file extension, as we want things like
            # .jpg files made by pdf2html to be picked up and rendered if
            # present.
            def real_file_path(name)
                '%s/%s' % [@cache_path, name.gsub('?', '.').gsub(':', '.')]
            end
        end
    end
end

