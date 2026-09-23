# frozen_string_literal: true

require 'dotenv/load'
require 'logger'

module ImageCompressor
  # Configuration singleton that reads from environment variables.
  #
  # @example
  #   ImageCompressor::Config.log_level # => Logger::INFO
  #
  class Config
    class << self
      # @return [Integer] Logger level constant.
      def log_level
        level_str = ENV.fetch('LOG_LEVEL', 'INFO').upcase
        Logger.const_get(level_str) rescue Logger::INFO
      end

      # @return [String, nil] Path to log file or nil for STDOUT.
      def log_file
        file = ENV['LOG_FILE']
        file && !file.strip.empty? ? file.strip : nil
      end

      # @return [String] Default output directory.
      def output_dir
        ENV.fetch('OUTPUT_DIR', 'compressed')
      end
    end
  end
end