# frozen_string_literal: true

class Script
  module Utils
    def output(task)
      warn "Preparing #{task}..."
      result = yield
      warn "#{task} finished!"
      result
    end

    def normalize(term)
      term.downcase.gsub('-', ' ')
    end
  end
end
