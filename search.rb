# frozen_string_literal: true

require 'text'
require './utils'

class Search
  include Script::Utils
  Article = Struct.new(:title, :text, :terms)

  attr_reader :matches

  def initialize(articles)
    query = normalize(ARGV[0])
    metaphone_query = Text::Metaphone.metaphone(query)
    @matches = articles.select do |article|
      article.terms.find do |term, _|
        Text::Levenshtein.distance(term, query) <= 1 ||
          Text::Metaphone.metaphone(term) == metaphone_query
      end
    end
  end
end
