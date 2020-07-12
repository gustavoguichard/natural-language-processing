# frozen_string_literal: true

require 'json'
require 'rest-client'
require './utils'

API_BASE = 'https://rbdb.io/v3'

class DataFetcher
  include Script::Utils

  def initialize
    output 'RBDB API' do
      result = parse(response)
      warn genres.join(', ')
    end
  end

  def genres
    @genres ||= genres_from_json
  end

  def each(*args, &block)
    genres.each(*args, &block)
  end

  def response
    @response ||= RestClient.get "#{API_BASE}/genres"
  end

  def parse(response)
    @json ||= JSON.parse response.body
  end

  private

  def genres_from_json
    names = json_collection.each_with_object([]) do |style, result|
      result.push style.split('/')
    end
    names.flatten.reject { |genre| genre == 'Unknown' }
  end

  def json_collection
    @json['collection'].map { |style| style['name'] }
  end
end
