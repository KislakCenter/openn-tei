#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'nokogiri'

SURFACE_XPATH        = '/TEI/facsimile/surface'
PAGE_NO_XPATH        = './@n'
ARCHIVAL_TIFF_XPATH  = './graphic[contains(@url, "master")]/@url'
WEB_JPEG_XPATH       = './graphic[contains(@url, "web")]/@url'
THUMBNAIL_JPEG_XPATH = './graphic[contains(@url, "thumb")]/@url'

def get_values xml, xpath, separator: '|'
  # require 'pry'; binding.pry
  xml.xpath(xpath).filter_map { |s| s.text unless s.text.strip.empty? }.join(separator)
end

file = ARGV.shift
xml = File.open (file) { |f| Nokogiri::XML f }
xml.remove_namespaces!

headers = %w{ postion page_no archival_tiff web_jpeg thumbnail_jpeg }
CSV headers: true do |csv|
  csv << headers

  xml.xpath(SURFACE_XPATH).each_with_index do |surface, ndx|
    row = {}

    page_no        = get_values(surface, PAGE_NO_XPATH)
    archival_tiff  = get_values(surface, ARCHIVAL_TIFF_XPATH)
    web_jpeg       = get_values(surface, WEB_JPEG_XPATH)
    thumbnail_jpeg = get_values(surface, THUMBNAIL_JPEG_XPATH)

    row['postion']        = ndx + 1
    row['page_no']        = page_no
    row['archival_tiff']  = archival_tiff
    row['web_jpeg']       = web_jpeg
    row['thumbnail_jpeg'] = thumbnail_jpeg

    csv << row
  end
end