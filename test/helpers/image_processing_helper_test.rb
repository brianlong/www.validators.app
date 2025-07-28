# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class ImageProcessingHelperTest < ActiveSupport::TestCase
  include ImageProcessingHelper

  class DummyImageObj
    IMAGE_TYPES = %w[image/png image/jpeg image/gif].freeze
    attr_accessor :avatar_url, :id, :class_name
    def initialize(url, id = 1)
      @avatar_url = url
      @id = id
    end
    def self.name
      'DummyImageObj'
    end
  end

  def setup
    @logger = Logger.new('/dev/null')
    @dummy = DummyImageObj.new('https://s3.amazonaws.com/keybase_processed_uploads/3af995d21a8fe4cec4d6e83104f87205_360_360.jpg', 123)
    @file_type = 'image/png'
    @tmp_file_path = Rails.root.join('tmp', 'dummyimageobj_123_tmp.png').to_s
    File.write(@tmp_file_path, 'test')
  end

  def teardown
    File.delete(@tmp_file_path) if File.exist?(@tmp_file_path)
    File.delete(@tmp_file_path.gsub('.png', '.svg')) if File.exist?(@tmp_file_path.gsub('.png', '.svg'))
    File.delete(@tmp_file_path.gsub('.png', '.png')) if File.exist?(@tmp_file_path.gsub('.png', '.png'))
  end

  test 'set_tmp_file_path returns correct path' do
    path = set_tmp_file_path(@file_type, @dummy)
    assert_equal @tmp_file_path, path
  end

  test 'image_file_md5 returns correct hash' do
    File.write(@tmp_file_path, 'abc')
    assert_equal Digest::MD5.hexdigest('abc'), image_file_md5(@tmp_file_path)
  end

  test 'process_image_file copies svg file' do
    svg_path = @tmp_file_path.gsub('.png', '.svg')
    File.write(svg_path, '<svg></svg>')
    dest_path = @tmp_file_path.gsub('.png', '_copy.svg')
    result = process_image_file(svg_path, @tmp_file_path.gsub('.png', '_copy'))
    assert File.exist?(dest_path)
    assert_equal dest_path, result
  end

  test 'process_and_save_image logs and returns file if exists' do
    File.write(@tmp_file_path, 'abc')
    result = process_and_save_image(@tmp_file_path, @tmp_file_path.gsub('.png', ''), @logger)
    assert result.nil? || File.exist?(result)
  end

  test 'download_tmp_file returns nil for wrong type' do
    stub_request(:get, 'https://example.com/bad').to_return(body: 'bad', headers: { 'Content-Type' => 'text/html' })
    dummy = DummyImageObj.new('https://example.com/bad', 456)
    assert_nil download_tmp_file('avatar_url', dummy, @logger)
  end

  test 'download_tmp_file downloads and saves actual image' do
    VCR.use_cassette('helpers/image_processing_helper/download_tmp_file') do
      file = download_tmp_file('avatar_url', @dummy, @logger)
      assert File.exist?(file)
      assert_match(/dummyimageobj_123_tmp\.\w+/, file)
      File.delete(file) if File.exist?(file)
    end
  end
end
