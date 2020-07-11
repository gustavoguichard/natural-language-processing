# frozen_string_literal: true

require 'byebug'
require 'json'
require 'json/add/core'
require './data_fetcher'
require './extract_text'
require './search'

class Script
  Article = Struct.new(:title, :text, :terms)
  def initialize
    search(rock_data)
  end

  def search(data)
    results = Search.new(data)

    puts "Results:\n"
    if results.matches.any?
      puts results.matches.map(&:title)
      puts "\nFirst document:\n\n"
      puts "#{results.matches.first.text[0..100]}..."
    else
      puts 'No matches'
    end
  end

  def rock_data
    if File.exist? 'data/content.json'
      content = File.read('data/content.json')
      JSON.parse(content, create_additions: true)
    else
      data = DataFetcher.new
      text = ExtractText.new(data.genres)
      save_data text.data
      puts "\n\n\n"
      rock_data
    end
  end

  def save_data(data)
    File.open('data/content.json', 'w') do |file|
      file.write(JSON.generate(data))
    end
  end
end

Script.new
