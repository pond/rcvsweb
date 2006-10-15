require 'revision_parser'

class RevisionsController < ApplicationController

  @@parser_url = 'http://pond.org.uk/python/cvshistory/cvshistory.cgi?revsel1=na&revsel2=na&datesel1=na&datesel2=na&selop=in&opA=on&opM=on&opR=on&opT=on&limit=1&rss=1'

  def list
    # Create a revision parser for a CVSHistory RSS feed. Get a
    # hash keyed by revision number (as a string), each entry
    # containing an array of RevisionDetails objects. Sort the
    # revision keys in reverse order of associated date (i.e. most
    # recent first) and iterate through the resulting sorted list.

    parser    = RevisionParser.new(@@parser_url)
    revisions = parser.fetch_and_parse(true)
    sort_keys = revisions.keys.sort do |key_x, key_y|
                  revisions[key_y][0][:date] <=> revisions[key_x][0][:date]
                end

    # Create an array of items in sorted order.

    @output = []

    sort_keys.each do |revision|

      # For each revision we have an array of changed files. For the overall
      # item details, choose (arbitrarily) the first one - 'item' should only
      # be looked at in terms of the attributes it has which apply equally to
      # all files in this revision. Make sure we note the key name that was
      # used for this item within the item itself.

      item       = revisions[revision][0]
      item[:key] = revision

      @output.push(item)
    end

    # Render the default layout to create the revision list.

    render :layout => 'default'
  end

  def show
    # The 'list' action creates links that create a parameter 'ident' in the
    # @params hash. This is a key to a revision hash entry. Extract the relevant
    # hash and pass it to the view.

    parser    = RevisionParser.new(@@parser_url)
    revisions = parser.fetch_and_parse(true)
    @output   = revisions[@params[:ident]]

    # Sort the array of revised files by category of action then by path.

    @output.sort do |x,y|
      x[:category] <=> y[:category]
    end.sort do |x,y|
      x[:path] <=> y[:path]
    end

    # Create mappings between categories and Collaboa icons plus suffix text.
    #
    # TO DO: Move these icons to the shared pool and update Collaboa accordingly.

    @category_map = {
                      'Addition' => { :image => '/rails/collaboa/images/chg-icon_A.png', :text => '(+)' },
                      'Removal'  => { :image => '/rails/collaboa/images/chg-icon_D.png', :text => '(-)' },
                      'Commit'   => { :image => '/rails/collaboa/images/chg-icon_M.png', :text => ''    },
                      :unknown   => { :image => '/rails/collaboa/images/icon_file.gif',  :text => '?'   }
                    }

    render :layout => 'default'
  end
end
