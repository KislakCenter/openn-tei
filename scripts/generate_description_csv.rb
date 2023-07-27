#/usr/bin/env ruby

require 'csv'
require 'nokogiri'

##
# Generate a CSV for all input OPenn TEI files.
#
# USAGE
#
# There are two ways to pass a list of files to the script.
#
# 1. As an argument list:
#
#   ruby script/generate_description_csv.rb TEI_XML [TEI_XML ...] > output.csv
#
# Example, generate a CSV for all LJS Manuscripts:
#
#  ruby script/generate_description_csv.rb $(find Data/0001 -name "*_TEI.xml") > ljs_mss.csv
#
# 2. As a piped list of files:
#
#   cat list_of_tei_files.txt | ruby script/generate_description_csv.rb > output.csv
#
# Example, as before generate a CSV for all LJS Manuscripts:
#
#   find Data/0001 -name "*_TEI.xml" | ruby script/generate_description_csv.rb > ljs_mss.csv
#
# NOTE: If you want to generate a CSV for all the OPenn MSS, you may have to use
# method two. Bash and other shells have an argument list limit and the list of
# ~13,000 OPenn TEI files may exceed this limit.

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
  source_file
}
CSV headers: true do |csv|
  csv << headers
  tei_files.each do |tei_file|
    file = tei_file.chomp
    xml = File.open (file) { |f| Nokogiri::XML f }
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
    source_file       = file.sub(%r{^.*/Data}, 'Data')

    row['shelfmark']         = shelfmark
    row['title']             = title
    row['additional_titles'] = additional_titles
    row['authors']           = authors
    row['language']          = language
    row['language_codes']    = language_codes
    row['date']              = date
    row['place']             = place
    row['source_file']       = source_file

    csv << row
  end
end