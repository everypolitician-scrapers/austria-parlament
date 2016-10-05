# frozen_string_literal: true

require 'field_serializer'
require 'nokogiri'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

class Page
  include FieldSerializer

  def initialize(url)
    @url = url
  end

  def noko
    @noko ||= Nokogiri::HTML(open(url).read)
  end

  private

  attr_reader :url

  def absolute_url(rel)
    return if rel.to_s.empty?
    URI.join(url, URI.encode(URI.decode(rel)))
  end
end
