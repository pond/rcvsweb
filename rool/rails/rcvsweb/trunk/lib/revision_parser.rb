require 'strscan'
require 'uri'
require 'net/https'
require 'rss'

class RevisionDetails
  attr_accessor(:title,
                :revision,
                :category,
                :description,
                :author,
                :date,
                :path,
                :folder,
                :link,
                :log)

  def initialize(title,
                 revision,
                 category,
                 description,
                 author,
                 date,
                 path,
                 folder,
                 link,
                 log)

    self.title       = title
    self.revision    = revision
    self.category    = category
    self.description = description
    self.author      = author
    self.date        = date
    self.folder      = folder
    self.path        = path
    self.link        = link
    self.log         = log
  end
end

class RevisionParser

  # Initialize the object - pass a CVSHistory RSS feed URL.
  #
  def initialize(feed)
    @feed = feed
  end

  # Fetch and parse the CVSHistory feed, returning a hash keyed
  # by revision number (as a string). Each revision entry contains
  # an array of hashes of revision data. The optional parameter is
  # set to 'true' to try and fetch and parse log data using 'cvs
  # rlog'. Obviously, this slows down operation though it makes the
  # returned data more comprehensive. By default the parameter is
  # set to 'false' so logs are not retrieved. Note that logs in
  # RevisionDetails objects will never be an empty string - they
  # will either be a message saying log data couldn't be retrieved
  # or contain some parsed log data.
  #
  # The keys for the hash are revision numbers as strings, but in
  # CVS revisions apply to directories - revision "1.2" does not
  # uniquely identify a single group of files. The path to which
  # the revision applies is thus used as a prefix for the revision
  # number to form the key string, with a ": " separator - e.g.
  # "/CVSROOT: 1.2".
  #
  def fetch_and_parse(extract_logs = false)

    # Site-specific issue: At ROOL, the SSL certificate issuer uses
    # a certificate chain which isn't known about by Ruby initially.
    # This causes SLL failures if we were to just try and get the
    # RSS parser to fetch & parse the data by passing it "@feed" in
    # "RSS::Parser.parse()". Instead we have to manually do the SSL
    # foot work and pass the parser the fetched data.

    uri                = URI.parse( @feed )
    https              = Net::HTTP.new( uri.host, uri.port )
    https.use_ssl      = true
    https.verify_mode  = OpenSSL::SSL::VERIFY_PEER
    https.ca_file      = SSL_CERT_CHAIN unless ( SSL_CERT_CHAIN.nil? || SSL_CERT_CHAIN.empty? )

    feed_data = https.start do | http |
      request  = Net::HTTP::Get.new( uri.request_uri )
      response = https.request( request )

      raise "#{ response.code }: #{ response.messages }" unless ( response.code.to_i >= 200 && response.code.to_i <= 299 )

      response.body
    end

    revisions = {}
    rss       = RSS::Parser.parse( feed_data )

    rss.items.each do |item|
      # Description format:
      #   "authorname: Category X.Y (path/of/file/from/cvs/root)"

      description = item.description
      category    = item.category.content

      if (category and category != '' and description and description != '')
        # Match so that [1] = author, [2] = revision, [3] = (ignore), [4] = path.

        parsed = description.match("^(.*?): #{category} (([0-9]+\.?)+) \\((.*)\\)$")

        unless(parsed.nil?      or
               parsed.size < 5  or
               parsed[1].empty? or
               parsed[2].empty? or
               parsed[4].empty?)

          # We only use the item.author field if the parser couldn't find much of
          # any use; CVSHistory tries to generate e-mail addresses for the author
          # but they don't really make much sense.

          author   = parsed[1] || item.author
          revision = parsed[2]

          # Now we can construct revision key for the hash.

          revision_key = "/#{parsed[4]}: #{revision}"

          # The path is just a path to the changed file - add on the leafname.
          # This could be extracted from the 'guid' field in the RSS data but
          # that's sufficiently opaque to have no confidence in its format for
          # a variety of CVS operations. Instead, use the CVSweb link and take
          # the leafname (or leaf directory) from that.

          folder = parsed[4] + '/'
          path   = folder
          link   = item.link
          index  = (link[-1] == '/') ? link.rindex('/', -2) : link.rindex('/')
          path  += index.nil?        ? link                 : link[(index + 1)..-1]

          # Should we try to use the link to fetch log data?

          log_cache  = {}
          cache_size = 0
          log        = nil

          if (extract_logs)
            # Construct the CVS command to retrieve log information.

            error   = nil
            command = "cvs rlog -lS -r#{revision} #{path} 2> /dev/null"

            # Store log data in a temporary internal cache to avoid fetching
            # logs on a particular file over and over again. Very crude cache
            # size management - just ditch the cache if it gets too big!

            if (cache_size > 1048576) # 1 MiB
              log_cache  = {}
              cache_size = 0
            end

            if (log_cache[command].nil?)
              begin
                log_cache[command] = `#{command}`
                cache_size += log_cache[command].length
              rescue
                error              = $!
                log_cache[command] = ''
              end
            end

            # Synthesise log entries if log data retrieval failed, else look
            # for the log's descriptive text.

            if (error.nil?)
              sscan = StringScanner.new(log_cache[command])
              found = sscan.scan_until(/^revision #{revision}\n/)
              found = sscan.scan(/^date:.*?\n/) if (found)
              found = sscan.scan_until(/^=============================================================================$/) if (found)
              log   = found[0..-(sscan.matched_size + 2)] if (found)

              # Trim white space and chop off '\n' at the start or end of the
              # log text. Reset the log to 'nil' if the string ends up empty.

              if (log)
                log.strip!
                log.chomp!
                log = log[1..-1] while log[0..0] == "\n"
                log = nil if (log.empty?)
              end
            else
              log = "Log data could not be retrieved: '#{error.to_s}'"
            end
          end # From 'if (extract_logs)'

          # Push the entry onto an array in the revisions hash, creating an
          # empty array beforehand for the first entry under the current key.

          revisions[revision_key] = [] if  revisions[revision_key].nil?
          revisions[revision_key].push( { :title       => item.title,
                                          :revision    => revision,
                                          :category    => category,
                                          :description => description,
                                          :author      => author,
                                          :date        => item.pubDate,
                                          :path        => path,
                                          :folder      => folder,
                                          :link        => link,
                                          :log         => log.nil? ? 'Log data not available.' : log
                                        } )
        end
      end
    end # For 'each' iterator

    return revisions

  end # For function defininition
end # For class defintion
