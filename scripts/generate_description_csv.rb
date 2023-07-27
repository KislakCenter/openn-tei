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
INSTITUTION_XPATH       = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/institution/text()'
REPOSITORY_XPATH        = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository/text()'
TITLE_XPATH             = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem[1]/title/text()'
ADDITIONAL_TITLES_XPATH = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem[position() > 1]/title/text()'
AUTHORS_XPATH           = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem/author/persName[@type="authority"]/text()'
LANGUAGE_XPATH          = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
LANGUAGE_CODES_XPATH    = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@*[name()="mainLang" or name()="otherLangs"]'
SUPPORT_XPATH           = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p/text()'
DATE_XPATH              = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origDate'
PLACE_XPATH             = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origPlace'
SUBJECTS_XPATH          = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="subjects"]/term/text()'
GENRES_XPATH            = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="form/genre"]/term/text()'
KEYWORDS_XPATH          = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="keywords"]/term/text()'

def get_values xml, xpath, separator: '|'
  xml.xpath(xpath).filter_map { |s| s.text unless s.text.strip.empty? }.join(separator)
end

tei_files = STDIN.tty? ? ARGV : ARGF

headers = %w{
  shelfmark
  institution
  repository
  repository_number
  title
  additional_titles
  authors
  language
  language_codes
  support
  date
  place
  source_file
  subjects
  genre/form
  keywords
}
CSV headers: true do |csv|
  csv << headers
  tei_files.each do |tei_file|
    file = tei_file.chomp
    file_array = file.split(/\//)
    repo_number = file_array[1]
    xml = File.open (file) { |f| Nokogiri::XML f }
    xml.remove_namespaces!

    row = {}

    shelfmark         = get_values(xml, SHELFMARK_XPATH)
    institution       = get_values(xml, INSTITUTION_XPATH)
    repository        = get_values(xml, REPOSITORY_XPATH)
    repository_number = repo_number
    title             = get_values(xml, TITLE_XPATH)
    additional_titles = get_values(xml, ADDITIONAL_TITLES_XPATH)
    authors           = get_values(xml, AUTHORS_XPATH)
    language          = get_values(xml, LANGUAGE_XPATH)
    language_codes    = get_values(xml, LANGUAGE_CODES_XPATH).gsub(' ', '|')
    support           = get_values(xml, SUPPORT_XPATH)
    date              = get_values(xml, DATE_XPATH)
    place             = get_values(xml, PLACE_XPATH)
    subjects          = get_values(xml, SUBJECTS_XPATH)
    genres            = get_values(xml, GENRES_XPATH)
    keywords          = get_values(xml, KEYWORDS_XPATH)
    source_file       = file.sub(%r{^.*/Data}, 'Data')

    row['shelfmark']         = shelfmark
    row['institution']       = institution
    row['repository']        = repository
    row['repository_number'] = repo_number
    row['title']             = title
    row['additional_titles'] = additional_titles
    row['authors']           = authors
    row['language']          = language
    row['language_codes']    = language_codes
    row['support']           = support
    row['date']              = date
    row['place']             = place
    row['subjects']          = subjects
    row['genre/form']        = genres
    row['keywords']          = keywords
    row['source_file']       = source_file

    csv << row
  end
end