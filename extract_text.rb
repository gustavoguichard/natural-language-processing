# frozen_string_literal: true

require 'open-uri'
require 'readability'
require 'phrasie'
require './utils'

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
    documents = urls.map do |url|
      output url do
        document = document_from_url url
        warn "Got: #{document.title}"
        document
      end
    end
    data_from_documents documents
  end

  def data_from_documents(documents)
    documents.map do |document|
      next unless document.respond_to? :title

      title = document.title.sub(/ - Wikipedia(.+)?$/, '')
      text = text_from_document document
      terms = extract_terms text
      Article.new(title, text, terms)
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
    Phrasie::Extractor.new.phrases(text).tap do |terms|
      terms
        .reject { |term| IGNORED.include? term.first }
        .each { |term| term.unshift normalize(term.first) }
    end
  end
end
