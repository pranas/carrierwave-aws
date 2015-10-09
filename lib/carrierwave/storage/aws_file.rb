module CarrierWave
  module Storage
    class AWSFile
      attr_writer :file
      attr_accessor :uploader, :connection, :path, :aws_options

      delegate :content_type, :delete, :exists?, :size, to: :file

      def initialize(uploader, connection, path)
        @uploader    = uploader
        @connection  = connection
        @path        = path
        @aws_options = AWSOptions.new(uploader)
      end

      def file
        @file ||= bucket.object(path)
      end

      alias_method :to_file, :file

      def attributes
        file.data.to_h
      end

      def extension
        elements = path.split('.')
        elements.last if elements.size > 1
      end

      def filename(options = {})
        if file_url = url(options)
          CarrierWave::Support::UriFilename.filename(file_url)
        end
      end

      def read
        file.get(aws_options.read_options).body.read
      end

      def store(sanitized_file)
        file.upload_file(sanitized_file.file, aws_options.write_options(sanitized_file))
      end

      def copy_to(new_path)
        file.copy_to(bucket.object(new_path), aws_options.write_options(self))
      end

      def signed_url(options = {})
        signer.call(public_url, options)
      end

      def authenticated_url(options = {})
        file.presigned_url(:get, aws_options.expiration_options(options))
      end

      def public_url
        if uploader.asset_host
          "#{uploader.asset_host}/#{path}"
        else
          file.public_url.to_s
        end
      end

      def url(options = {})
        if signer
          signed_url(options)
        elsif uploader.aws_acl.to_s != 'public-read'
          authenticated_url(options)
        else
          public_url
        end
      end

      private

      def bucket
        @bucket ||= connection.bucket(uploader.aws_bucket)
      end

      def signer
        uploader.aws_signer
      end
    end
  end
end
