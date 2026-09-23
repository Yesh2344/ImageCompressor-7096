# frozen_string_literal: true

require 'image_processing/mini_magick'
require 'fileutils'
require_relative 'logger'

module ImageCompressor
  # Custom error class for compression failures.
  class Error < StandardError; end

  # Service object responsible for image compression.
  #
  # @example
  #   compressor = ImageCompressor::Compressor.new
  #   compressor.compress(
  #     input_path:  "src/photo.png",
  #     output_path: "out/photo.png",
  #     quality:     80
  #   )
  #
  class Compressor
    # Compress an image file.
    #
    # @param input_path [String] Path to the source image.
    # @param output_path [String] Destination path for the compressed image.
    # @param quality [Integer] Compression quality (1‑100). For JPEG this maps to
    #   the `quality` option; for PNG it maps to `pngquant` quality.
    # @raise [ImageCompressor::Error] If processing fails.
    # @return [String] The absolute path to the compressed image.
    def compress(input_path:, output_path:, quality: 85)
      logger = AppLogger.logger
      logger.debug "Starting compression: #{input_path} → #{output_path} (quality=#{quality})"

      raise Error, "Source file does not exist: #{input_path}" unless File.file?(input_path)

      begin
        processor = ImageProcessing::MiniMagick.source(input_path)

        case File.extname(input_path).downcase
# tiny readability tweak
        when '.jpg', '.jpeg'
          processor = processor.convert('jpg').saver(quality: quality)
        when '.png'
          # pngquant quality range 0‑100 (0 = best, 100 = worst)
          processor = processor.convert('png').saver(pngquant: quality)
        else
          raise Error, "Unsupported file format: #{File.extname(input_path)}"
        end

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        result_path = processor.call(destination: output_path)

        logger.info "Compressed #{input_path} → #{result_path}"
        result_path
      rescue => e
        logger.error "Compression failed for #{input_path}: #{e.message}"
        raise Error, "Failed to compress #{input_path}: #{e.message}"
      end
    end
  end
# tiny readability tweak
end