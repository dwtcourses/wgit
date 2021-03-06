# frozen_string_literal: true

require_relative 'url'
require_relative 'document'
require_relative 'utils'
require_relative 'assertable'
require_relative 'response'
require 'set'
require 'typhoeus'

module Wgit
  # The Crawler class provides a means of crawling web based HTTP Wgit::Url's,
  # serialising their HTML into Wgit::Document instances. This is the only Wgit
  # class which contains network logic e.g. HTTP request/response handling.
  class Crawler
    include Assertable

    # Set of supported file extensions for Wgit::Crawler#crawl_site.
    @supported_file_extensions = Set.new(
      %w[asp aspx cfm cgi htm html htmlx jsp php]
    )

    class << self
      # The URL file extensions (from `<a>` hrefs) which will be crawled by
      # `#crawl_site`. The idea is to omit anything that isn't HTML and therefore
      # doesn't keep the crawl of the site going. All URL's without a file
      # extension will be crawled, because they're assumed to be HTML.
      # The `#crawl` method will crawl anything since it's given the URL(s).
      # You can add your own site's URL file extension e.g.
      # `Wgit::Crawler.supported_file_extensions << 'html5'` etc.
      attr_reader :supported_file_extensions
    end

    # The amount of allowed redirects before raising an error. Set to 0 to
    # disable redirects completely; or you can pass `follow_redirects: false`
    # to any Wgit::Crawler.crawl_* method.
    attr_accessor :redirect_limit

    # The maximum amount of time (in seconds) a crawl request has to complete
    # before raising an error. Set to 0 to disable time outs completely.
    attr_accessor :time_out

    # Whether or not to UTF-8 encode the response body once crawled. Set to
    # false if crawling more than just HTML e.g. images.
    attr_accessor :encode

    # The Wgit::Response of the most recently crawled URL.
    attr_reader :last_response

    # Initializes and returns a Wgit::Crawler instance.
    #
    # @param redirect_limit [Integer] The amount of allowed redirects before
    #   raising an error. Set to 0 to disable redirects completely.
    # @param time_out [Integer, Float] The maximum amount of time (in seconds)
    #   a crawl request has to complete before raising an error. Set to 0 to
    #   disable time outs completely.
    # @param encode [Boolean] Whether or not to UTF-8 encode the response body
    #   once crawled. Set to false if crawling more than just HTML e.g. images.
    def initialize(redirect_limit: 5, time_out: 5, encode: true)
      @redirect_limit = redirect_limit
      @time_out       = time_out
      @encode         = encode
    end

    # Crawls an entire website's HTML pages by recursively going through
    # its internal `<a>` links. Each crawled Document is yielded to a block.
    # Use `doc.empty?` to determine if the crawled link is valid.
    #
    # Use the allow and disallow paths params to partially and selectively
    # crawl a site; the glob syntax is fully supported e.g. `'wiki/\*'` etc.
    # Note that each path must NOT start with a slash; the only exception being
    # a `/` on its own with no other characters, referring to the index page.
    #
    # Only redirects to the same host are followed. For example, the Url
    # 'http://www.example.co.uk/how' has a host of 'www.example.co.uk' meaning
    # a link which redirects to 'https://ftp.example.co.uk' or
    # 'https://www.example.com' will not be followed. The only exception to
    # this is the initially crawled url which is allowed to redirect anywhere;
    # it's host is then used for other link redirections on the site, as
    # described above.
    #
    # @param url [Wgit::Url] The base URL of the website to be crawled.
    #   It is recommended that this URL be the index page of the site to give a
    #   greater chance of finding all pages within that site/host.
    # @param allow_paths [String, Array<String>] Filters links by selecting
    #   them if their path `File.fnmatch?` one of allow_paths.
    # @param disallow_paths [String, Array<String>] Filters links by rejecting
    #   them if their path `File.fnmatch?` one of disallow_paths.
    # @yield [doc] Given each crawled page (Wgit::Document) of the site.
    #   A block is the only way to interact with each crawled Document.
    #   Use `doc.empty?` to determine if the page is valid.
    # @return [Array<Wgit::Url>, nil] Unique Array of external urls collected
    #   from all of the site's pages or nil if the given url could not be
    #   crawled successfully.
    def crawl_site(url, allow_paths: nil, disallow_paths: nil, &block)
      doc = crawl_url(url, &block)
      return nil if doc.nil?

      path_opts = { allow_paths: allow_paths, disallow_paths: disallow_paths }
      alt_url   = url.end_with?('/') ? url.chop : url + '/'

      crawled   = Set.new([url, alt_url])
      externals = Set.new(doc.external_links)
      internals = Set.new(get_internal_links(doc, path_opts))

      return externals.to_a if internals.empty?

      loop do
        links = internals - crawled
        break if links.empty?

        links.each do |link|
          orig_link = link.dup
          doc = crawl_url(link, follow_redirects: :host, &block)

          crawled += [orig_link, link] # Push both links in case of redirects.
          next if doc.nil?

          internals += get_internal_links(doc, path_opts)
          externals += doc.external_links
        end
      end

      externals.to_a
    end

    # Crawls one or more individual urls using Wgit::Crawler#crawl_url
    # underneath. See Wgit::Crawler#crawl_site for crawling entire sites.
    #
    # @param urls [*Wgit::Url] The Url's to crawl.
    # @param follow_redirects [Boolean, Symbol] Whether or not to follow
    #   redirects. Pass a Symbol to limit where the redirect is allowed to go
    #   e.g. :host only allows redirects within the same host. Choose from
    #   :base, :host, :domain or :brand. See Wgit::Url#relative? opts param.
    #   This value will be used for all urls crawled.
    # @yield [doc] Given each crawled page (Wgit::Document); this is the only
    #   way to interact with them.
    # @raise [StandardError] If no urls are provided.
    # @return [Wgit::Document] The last Document crawled.
    def crawl_urls(*urls, follow_redirects: true, &block)
      raise 'You must provide at least one Url' if urls.empty?

      opts = { follow_redirects: follow_redirects }
      doc = nil

      Wgit::Utils.each(urls) { |url| doc = crawl_url(url, opts, &block) }

      doc
    end

    # Crawl the url returning the response Wgit::Document or nil, if an error
    # occurs.
    #
    # @param url [Wgit::Url] The Url to crawl; which will likely be modified.
    # @param follow_redirects [Boolean, Symbol] Whether or not to follow
    #   redirects. Pass a Symbol to limit where the redirect is allowed to go
    #   e.g. :host only allows redirects within the same host. Choose from
    #   :base, :host, :domain or :brand. See Wgit::Url#relative? opts param.
    # @yield [doc] The crawled HTML page (Wgit::Document) regardless if the
    #   crawl was successful or not. Therefore, Document#url etc. can be used.
    # @return [Wgit::Document, nil] The crawled HTML Document or nil if the
    #   crawl was unsuccessful.
    def crawl_url(url, follow_redirects: true)
      # A String url isn't allowed because it's passed by value not reference,
      # meaning a redirect isn't reflected; A Wgit::Url is passed by reference.
      assert_type(url, Wgit::Url)

      html = fetch(url, follow_redirects: follow_redirects)
      doc  = Wgit::Document.new(url, html, encode: @encode)

      yield(doc) if block_given?

      doc.empty? ? nil : doc
    end

    protected

    # Returns the url HTML String or nil. Handles any errors that arise
    # and sets the @last_response. Errors or any HTTP response that doesn't
    # return a HTML body will be ignored, returning nil.
    #
    # @param url [Wgit::Url] The URL to fetch. This Url object is passed by
    #   reference and gets modified as a result of the fetch/crawl.
    # @param follow_redirects [Boolean, Symbol] Whether or not to follow
    #   redirects. Pass a Symbol to limit where the redirect is allowed to go
    #   e.g. :host only allows redirects within the same host. Choose from
    #   :base, :host, :domain or :brand. See Wgit::Url#relative? opts param.
    # @raise [StandardError] If url isn't valid and absolute.
    # @return [String, nil] The crawled HTML or nil if the crawl was
    #   unsuccessful.
    def fetch(url, follow_redirects: true)
      response = Wgit::Response.new
      raise "Invalid url: #{url}" if url.invalid?

      resolve(url, response, follow_redirects: follow_redirects)
      response.body_or_nil
    rescue StandardError => e
      Wgit.logger.debug("Wgit::Crawler#fetch('#{url}') exception: #{e}")

      nil
    ensure
      url.crawled        = true # Sets date_crawled underneath.
      url.crawl_duration = response.total_time

      @last_response = response
    end

    # GETs the given url, resolving any redirects. The given response object
    # will be enriched.
    #
    # @param url [Wgit::Url] The URL to GET and resolve.
    # @param response [Wgit::Response] The response to enrich. Modifies by
    #   reference.
    # @param follow_redirects [Boolean, Symbol] Whether or not to follow
    #   redirects. Pass a Symbol to limit where the redirect is allowed to go
    #   e.g. :host only allows redirects within the same host. Choose from
    #   :base, :host, :domain or :brand. See Wgit::Url#relative? opts param.
    # @raise [StandardError] If a redirect isn't allowed etc.
    def resolve(url, response, follow_redirects: true)
      orig_url_base = url.to_url.to_base # Recorded before any redirects.
      follow_redirects, within = redirect?(follow_redirects)

      loop do
        get_response(url, response)
        break unless response.redirect?

        # Handle response 'Location' header.
        location = Wgit::Url.new(response.headers.fetch(:location, ''))
        raise 'Encountered redirect without Location header' if location.empty?

        yield(url, response, location) if block_given?

        # Validate if the redirect is allowed.
        raise "Redirect not allowed: #{location}" unless follow_redirects

        if within && !location.relative?(within => orig_url_base)
          raise "Redirect (outside of #{within}) is not allowed: '#{location}'"
        end

        raise "Too many redirects, exceeded: #{@redirect_limit}" \
        if response.redirect_count >= @redirect_limit

        # Process the location to be crawled next.
        location = url.to_base.concat(location) if location.relative?
        response.redirections[url.to_s] = location.to_s
        url.replace(location) # Update the url on redirect.
      end
    end

    # Makes a HTTP request and enriches the given Wgit::Response from it.
    #
    # @param url [String] The url to GET. Will call url#normalize if possible.
    # @param response [Wgit::Response] The response to enrich. Modifies by
    #   reference.
    # @raise [StandardError] If a response can't be obtained.
    # @return [Wgit::Response] The enriched HTTP Wgit::Response object.
    def get_response(url, response)
      # Perform a HTTP GET request.
      orig_url = url.to_s
      url      = url.normalize if url.respond_to?(:normalize)

      http_response = http_get(url)

      # Enrich the given Wgit::Response object.
      response.adapter_response = http_response
      response.url              = orig_url
      response.status           = http_response.code
      response.headers          = http_response.headers
      response.body             = http_response.body
      response.ip_address       = http_response.primary_ip
      response.add_total_time(http_response.total_time)

      # Log the request/response details.
      log_http(response)

      # Handle a failed response.
      raise "No response (within timeout: #{@time_out} second(s))" \
      if response.failure?
    end

    # Performs a HTTP GET request and returns the response.
    #
    # @param url [String] The url to GET.
    # @return [Typhoeus::Response] The HTTP response object.
    def http_get(url)
      opts = {
        followlocation: false,
        timeout: @time_out,
        accept_encoding: 'gzip',
        headers: {
          'User-Agent' => "wgit/#{Wgit::VERSION}",
          'Accept'     => 'text/html'
        }
      }

      # See https://rubydoc.info/gems/typhoeus for more info.
      Typhoeus.get(url, opts)
    end

    # Returns a doc's internal HTML page links in absolute form; used when
    # crawling a site. Use the allow and disallow paths params to partially
    # and selectively crawl a site; the glob syntax is supported e.g.
    # `'wiki/\*'` etc. Note that each path should NOT start with a slash.
    #
    # Override this method in a subclass to change how a site
    # is crawled, not what is extracted from each page (Document extensions
    # should be used for this purpose instead). Just remember that only HTML
    # files containing `<a>` links keep the crawl going beyond the base URL.
    #
    # @param doc [Wgit::Document] The document from which to extract it's
    #   internal (absolute) page links.
    # @param allow_paths [String, Array<String>] Filters links by selecting
    #   them if their path `File.fnmatch?` one of allow_paths.
    # @param disallow_paths [String, Array<String>] Filters links by rejecting
    #   them if their path `File.fnmatch?` one of disallow_paths.
    # @return [Array<Wgit::Url>] The internal page links from doc.
    def get_internal_links(doc, allow_paths: nil, disallow_paths: nil)
      links = doc
              .internal_absolute_links
              .map(&:omit_fragment) # Because fragments don't alter content.
              .uniq
              .select do |link|
        ext = link.to_extension
        ext ?
          Wgit::Crawler.supported_file_extensions.include?(ext.downcase) :
          true # URLs without an extension are assumed HTML.
      end

      return links if allow_paths.nil? && disallow_paths.nil?

      process_paths(links, allow_paths, disallow_paths)
    end

    private

    # Returns whether or not to follow redirects, and within what context e.g.
    # :host, :domain etc.
    def redirect?(follow_redirects)
      return [true, follow_redirects] if follow_redirects.is_a?(Symbol)

      unless [true, false].include?(follow_redirects)
        raise "follow_redirects: must be a Boolean or Symbol, not: \
#{follow_redirects}"
      end

      [follow_redirects, nil]
    end

    # Log (at debug level) the HTTP request/response details.
    def log_http(response)
      resp_template  = '[http] Response: %s (%s bytes in %s seconds)'
      log_status     = (response.status || 0)
      log_total_time = response.total_time.truncate(3)

      Wgit.logger.debug("[http] Request:  #{response.url}")
      Wgit.logger.debug(
        format(resp_template, log_status, response.size, log_total_time)
      )
    end

    # Validate and filter by the given URL paths.
    def process_paths(links, allow_paths, disallow_paths)
      if allow_paths
        paths = validate_paths(allow_paths)
        filter_links(links, :select!, paths)
      end

      if disallow_paths
        paths = validate_paths(disallow_paths)
        filter_links(links, :reject!, paths)
      end

      links
    end

    # Validate the paths are suitable for filtering.
    def validate_paths(paths)
      paths = [paths] unless paths.is_a?(Array)
      raise 'The provided paths must all be Strings' \
      unless paths.all? { |path| path.is_a?(String) }

      Wgit::Utils.process_arr(paths, encode: false)
      raise 'The provided paths cannot be empty' if paths.empty?

      paths
    end

    # Filters links by selecting/rejecting them based on their path.
    # Uses File.fnmatch? so that globbing is supported.
    def filter_links(links, filter_method, paths)
      links.send(filter_method) do |link|
        # Turn http://example.com into / meaning index.
        link = link.to_endpoint == '/' ? '/' : link.omit_base

        match = false
        paths.each do |pattern|
          match = File.fnmatch?(pattern, link, File::FNM_EXTGLOB)
          break if match
        end

        match
      end
    end

    alias crawl       crawl_urls
    alias crawl_pages crawl_urls
    alias crawl_page  crawl_url
    alias crawl_r     crawl_site
  end
end
