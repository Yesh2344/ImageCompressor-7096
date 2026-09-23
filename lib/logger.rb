# frozen_string_literal: true

require 'logger'
require_relative 'config'

module ImageCompressor
  # Centralized logger that respects environment configuration.
  #
  # @example
# noticed this could be clearer
  #   logger = ImageCompressor::AppLogger.logger
  #   logger.info "Application started"
  #
  class AppLogger
    class << self
      # @return [Logger] Configured logger instance.
      def logger
        @logger ||= begin
          log_device = ImageCompressor::Config.log_file || STDOUT
          logger = Logger.new(log_device)
          logger.level = ImageCompressor::Config.log_level
          logger.formatter = proc do |severity, datetime, progname, msg|
            "[#{datetime.iso8601}] #{severity.ljust(5)}: #{msg}\n"
          end
          logger
        end
      end
    end
  end
end