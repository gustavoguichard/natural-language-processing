# frozen_string_literal: true

require './utils'
require 'open-uri'
require 'readability'
require 'phrasie'

WIKI_BASE = 'http://en.wikipedia.org/wiki'
IGNORED = ['^', '', 'p', '"', 'pp', 'link', 'citation', 'ISBN', '[edit', 'Retrieved', 'eds .).', '.).', 'c', '5'].freeze

class ExtractText
  include Script::Utils
  Article = Struct.new(:title, :text, :terms)

  attr_reader :data

  def initialize(genres)
    @genres = genres
    output 'Content from wikipedia' do
      @data ||= fetch(urls)
    end
  end

  def urls
    @genres.map { |genre| "#{WIKI_BASE}/#{genre.gsub(' ', '_')}" }
  end

  def fetch(urls)
    urls.map do |url|
      output url do
        document = document_from_url url
        next unless document.respond_to? :title

        title = document.title.sub(/ - Wikipedia(.+)?$/, '')
        warn "Got: #{title}"
        text = text_from_document document
        terms = extract_terms text
        terms.each do |term|
          term.unshift normalize(term.first)
        end

        Article.new(title, text, terms)
      end
    end
  end

  def document_from_url(url)
    html = URI.open(url).read
    Readability::Document.new(html)
  rescue OpenURI::HTTPError
    nil
  end

  def text_from_document(document)
    Nokogiri::HTML(document.content).text.strip
  end

  def extract_terms(text)
    terms = Phrasie::Extractor.new.phrases(text)
    terms.reject { |term| IGNORED.include? term.first }
  end
end
