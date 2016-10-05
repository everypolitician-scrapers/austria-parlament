#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'field_serializer'
require 'nokogiri'
require 'pry'
require 'scraperwiki'

# require 'open-uri/cached'
require 'scraped_page_archive/open-uri'

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

class AllMembersPage < Page
  field :members do
    member_table.css('tr').drop(1).map do |tr|
      td = tr.css('td')
      {
        name:    td[0].text.tidy,
        faction: td[1].text.split(/,\s+/).map(&:tidy),
        terms:   td[2].text.split(/,\s+/).map(&:tidy),
        state:   td[3].text.split(/,\s+/).map(&:tidy),
        url:     absolute_url(td[0].css('a/@href').text),
      }
    end
  end

  private

  def member_table
    mt = noko.css('.tabelle') or raise 'No member table'
    raise 'Too many member tables' if mt.count > 1
    mt
  end
end

class MemberPage < Page
  field :id do
    url.to_s[/PAD_(\d+)/, 1]
  end

  field :name do
    noko.css('h1#inhalt').text.tidy
  end

  field :source do
    url.to_s
  end
end

LIST_PAGE = 'https://www.parlament.gv.at/WWER/NR/ABG/index.shtml?xdocumentUri=%2FWWER%2FNR%2FABG%2Findex.shtml&R_BW=BL&GP=ALLE&BL=ALLE&STEP=&FR=ALLE&M=M&NRBR=NR&FBEZ=FW_004&WK=ALLE&requestId=22CCE571C5&jsMode=&LISTE=&W=W&letter=&WP=ALLE&listeId=4&R_WF=FR'

data = AllMembersPage.new(LIST_PAGE).to_h
warn "Found #{data[:members].count} members"

data[:members].shuffle.each do |mem|
  member = MemberPage.new(mem[:url]).to_h
  ScraperWiki.save_sqlite(%i(id), member)
end
