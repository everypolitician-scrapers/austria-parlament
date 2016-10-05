#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraperwiki'

# require 'open-uri/cached'
require 'scraped_page_archive/open-uri'
require_rel 'lib'

require 'open-uri/cached'
# require 'scraped_page_archive/open-uri'

LIST_PAGE = 'https://www.parlament.gv.at/WWER/NR/ABG/index.shtml?xdocumentUri=%2FWWER%2FNR%2FABG%2Findex.shtml&R_BW=BL&GP=ALLE&BL=ALLE&STEP=&FR=ALLE&M=M&NRBR=NR&FBEZ=FW_004&WK=ALLE&requestId=22CCE571C5&jsMode=&LISTE=&W=W&letter=&WP=ALLE&listeId=4&R_WF=FR'

data = AllMembersPage.new(LIST_PAGE).to_h
warn "Found #{data[:members].count} members"

data[:members].shuffle.each do |mem|
  member = MemberPage.new(mem[:url]).to_h
  ScraperWiki.save_sqlite(%i(id), member)
end
