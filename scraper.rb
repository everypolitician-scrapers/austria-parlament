#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pry'
require 'scraperwiki'

require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

LIST_PAGE = 'https://www.parlament.gv.at/WWER/NR/ABG/index.shtml?xdocumentUri=%2FWWER%2FNR%2FABG%2Findex.shtml&R_BW=BL&GP=ALLE&BL=ALLE&STEP=&FR=ALLE&M=M&NRBR=NR&FBEZ=FW_004&WK=ALLE&requestId=22CCE571C5&jsMode=&LISTE=&W=W&letter=&WP=ALLE&listeId=4&R_WF=FR'
LINK_SELECTOR = '.tabelle tr a[href*="/WWER/"]/@href'

# For now, only archive the pages. Parsing them can come later.
noko = noko_for(LIST_PAGE)
noko.css(LINK_SELECTOR).each do |href|
  _ = noko_for(URI.join(LIST_PAGE, href.text))
end

