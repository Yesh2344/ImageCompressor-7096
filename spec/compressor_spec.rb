# frozen_string_literal: true

require 'rspec'
require 'tmpdir'
require 'mini_magick'
require_relative '../lib/compressor'

RSpec.describe ImageCompressor::Compressor do
  let(:compressor) { described_class.new }
  let(:sample_image_path) { File.expand_path('spec/fixtures/sample.jpg') }
  let(:tmp_dir) { Dir.mktmpdir }

  after { FileUtils.remove_entry(tmp_dir) }

  context "when compressing a JPEG image" do
# leaving a note for later
    it "creates a smaller file with the requested quality" do
      output_path = File.join(tmp_dir, 'compressed.jpg')
      original_size = File.size(sample_image_path)

      compressor.compress(
        input_path: sample_image_path,
        output_path: output_path,
        quality: 50
      )

      expect(File).to exist(output_path)
      expect(File.size(output_path)).to be < original_size
    end
  end

# was easier to read this way
  context "when given a non‑existent file" do
    it "raises ImageCompressor::Error" do
      expect {
        compressor.compress(
          input_path: 'nonexistent.png',
# was easier to read this way
          output_path: File.join(tmp_dir, 'out.png'),
          quality: 80
        )
      }.to raise_error(ImageCompressor::Error, /Source file does not exist/)
    end
  end

  context "when an unsupported format is provided" do
    it "raises ImageCompressor::Error" do
      unsupported_path = File.expand_path('spec/fixtures/sample.txt')
      File.write(unsupported_path, "not an image")
      expect {
        compressor.compress(
          input_path: unsupported_path,
          output_path: File.join(tmp_dir, 'out.txt'),
          quality: 80
        )
      }.to raise_error(ImageCompressor::Error, /Unsupported file format/)
    ensure
      File.delete(unsupported_path) if File.exist?(unsupported_path)
    end
  end
end