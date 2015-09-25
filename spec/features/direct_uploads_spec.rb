require 'spec_helper'
require 'carrierwave/aws/direct_uploads'

RSpec.describe 'Direct Uploads', type: :feature do
  let(:uploader) { Class.new(FeatureUploader) { include CarrierWave::AWS::DirectUploads }.new }
  let(:image) { CarrierWave::SanitizedFile.new(File.open('spec/fixtures/image.png', 'r')) }

  let(:directly_uploaded_file) do
    CarrierWave::Storage::AWSFile.new(uploader, uploader.send(:storage).connection, 'test/original_file.jpg')
  end

  it 'copies the file and deletes the original' do
    directly_uploaded_file.store(image)

    uploader.directly_uploaded_file = 'test/original_file.jpg'
    uploader.store!

    expect(uploader.file.path).to eq('uploads/image.png')
    expect(uploader.file.size).to eq(image.size)
    expect(uploader.file.read).to eq(image.read)
    expect(directly_uploaded_file).to_not exist

    uploader.file.delete
  end

  context 'when path is wrong' do
    it 'raises error' do
      expect {
        uploader.directly_uploaded_file = 'test/test.jpg'
        uploader.store!
      }.to raise_error(CarrierWave::DownloadError)
    end
  end
end
