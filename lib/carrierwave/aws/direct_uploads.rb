module CarrierWave
  module AWS
    module DirectUploads
      def directly_uploaded_file=(remote_path)
        remote_file = CarrierWave::Storage::AWSFile.new(self, storage.connection, remote_path)
        sanitized_file = CarrierWave::SanitizedFile.new(remote_file)

        if remote_file.exists?
          with_callbacks(:cache, sanitized_file) do
            self.cache_id = CarrierWave.generate_cache_id unless cache_id

            @filename = sanitized_file.filename
            self.original_filename = sanitized_file.filename
            @file = sanitized_file
          end
        end
      end
    end
  end
end
