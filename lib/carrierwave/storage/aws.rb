require 'aws-sdk-resources'

module CarrierWave
  module Storage
    class AWS < Abstract
      def self.connection_cache
        @connection_cache ||= {}
      end

      def self.clear_connection_cache!
        @connection_cache = {}
      end

      def store!(sanitized_file)
        AWSFile.new(uploader, connection, uploader.store_path).tap do |new_aws_file|
          if sanitized_file.file.is_a?(AWSFile)
            aws_file = sanitized_file.file
            aws_file.copy_to(new_aws_file.path)
            aws_file.delete
          else
            new_aws_file.store(sanitized_file)
          end
        end
      rescue ::Aws::S3::Errors::NotFound => e
        raise CarrierWave::DownloadError, I18n.translate(:"errors.messages.carrierwave_download_error", e: e)
      end

      def retrieve!(identifier)
        AWSFile.new(uploader, connection, uploader.store_path(identifier))
      end

      def connection
        @connection ||= begin
          self.class.connection_cache[credentials] ||= ::Aws::S3::Resource.new(*credentials)
        end
      end

      def credentials
        [uploader.aws_credentials].compact
      end
    end
  end
end
