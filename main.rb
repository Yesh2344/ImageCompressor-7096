# frozen_string_literal: true

require 'optparse'
require 'fileutils'
require_relative 'lib/compressor'
require_relative 'lib/logger'
require_relative 'lib/config'

module ImageCompressor
  # CLI driver for the image compression tool.
  class CLI
    def self.run(argv = ARGV)
      options = parse_options(argv)

      input_pattern = options[:input]
      output_dir    = options[:output] || ImageCompressor::Config.output_dir
      quality       = options[:quality]

      logger = AppLogger.logger
      logger.info "ImageCompressor started"

      files = Dir.glob(input_pattern).select { |f| File.file?(f) }
      if files.empty?
        logger.warn "No files matched pattern: #{input_pattern}"
        exit 1
      end

      compressor = Compressor.new

      files.each do |src|
        basename = File.basename(src)
        dest = File.join(output_dir, basename)

        begin
          compressor.compress(
            input_path: src,
            output_path: dest,
            quality: quality
          )
        rescue Error => e
          logger.error e.message
        end
      end

      logger.info "Processing complete. #{files.size} file(s) handled."
    end

    # @return [Hash] Parsed command‑line options.
    def self.parse_options(argv)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: ruby main.rb [options]"

        opts.on("-iPATH", "--input=PATH", "Input file or glob pattern (required)") do |v|
          options[:input] = v
        end

        opts.on("-oDIR", "--output=DIR", "Output directory (default: #{ImageCompressor::Config.output_dir})") do |v|
          options[:output] = v
        end

        opts.on("-qN", "--quality=N", Integer, "Compression quality (1‑100, default: 85)") do |v|
          options[:quality] = v
        end

        opts.on("-lFILE", "--log=FILE", "Optional log file (overrides LOG_FILE env)") do |v|
          ENV['LOG_FILE'] = v
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(argv)

      unless options[:input]
        puts opt_parser
        exit 1
      end

      options[:quality] ||= 85
      options
    end
  end
end

# Execute CLI only if this file is run directly.
if __FILE__ == $PROGRAM_NAME
  ImageCompressor::CLI.run
end