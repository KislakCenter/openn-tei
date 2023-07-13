#/usr/bin/env ruby

require 'csv'
require 'nokogiri'

SHELFMARK_XPATH         = '//msIdentifier/idno[@type="call-number"]/text()'
TITLE_XPATH             = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem[1]/title/text()'
ADDITIONAL_TITLES_XPATH = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem[position() > 1]/title/text()'
AUTHORS_XPATH           = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem/author/persName[@type="authority"]/text()'
LANGUAGE_XPATH          = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
LANGUAGE_CODES_XPATH    = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@*[name()="mainLang" or name()="otherLangs"]'
DATE_XPATH              = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origDate'
PLACE_XPATH             = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origPlace'

def get_values xml, xpath, separator: '|'
  xml.xpath(xpath).filter_map { |s| s.text unless s.text.strip.empty? }.join(separator)
end

tei_files = STDIN.tty? ? ARGV : ARGF

headers = %w{
  shelfmark
  title
  additional_titles
  authors
  language
  language_codes
  date
  place
}
CSV headers: true do |csv|
  csv << headers
  tei_files.each do |file|
    xml = File.open (file.chomp) { |f| Nokogiri::XML f }
    xml.remove_namespaces!

    row = {}

    shelfmark         = get_values(xml, SHELFMARK_XPATH)
    title             = get_values(xml, TITLE_XPATH)
    additional_titles = get_values(xml, ADDITIONAL_TITLES_XPATH)
    authors           = get_values(xml, AUTHORS_XPATH)
    language          = get_values(xml, LANGUAGE_XPATH)
    language_codes    = get_values(xml, LANGUAGE_CODES_XPATH).gsub(' ', '|')
    date              = get_values(xml, DATE_XPATH)
    place             = get_values(xml, PLACE_XPATH)

    row['shelfmark']         = shelfmark
    row['title']             = title
    row['additional_titles'] = additional_titles
    row['authors']           = authors
    row['language']          = language
    row['language_codes']    = language_codes
    row['date']              = date
    row['place']             = place

    csv << row
  end
end