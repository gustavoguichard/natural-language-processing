# frozen_string_literal: true

class Script
  module Utils
    def output(task)
      puts "Preparing #{task}..."
      result = yield
      puts "#{task} finished!"
      result
    end

    def normalize(term)
      term.downcase.gsub('-', ' ')
    end
  end
end
