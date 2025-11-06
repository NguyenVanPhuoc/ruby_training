# app/services/file_upload_service.rb
class FileUploadService
  UPLOAD_DIR = Rails.root.join('public', 'uploads')
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .gif .webp]
  MAX_FILE_SIZE = 5.megabytes

  class << self
    def upload(file, folder: 'general')
      return nil unless file.present?
      
      validate_file!(file)
      
      # Tạo thư mục nếu chưa có
      upload_path = UPLOAD_DIR.join(folder)
      FileUtils.mkdir_p(upload_path) unless Dir.exist?(upload_path)
      
      # Tạo tên file unique
      filename = generate_unique_filename(file.original_filename)
      file_path = upload_path.join(filename)
      
      # Lưu file
      File.open(file_path, 'wb') do |f|
        f.write(file.read)
      end
      
      # Trả về URL tương đối
      "/uploads/#{folder}/#{filename}"
    rescue => e
      Rails.logger.error "File upload failed: #{e.message}"
      nil
    end

    def delete(file_url)
      return false unless file_url.present?
      
      file_path = Rails.root.join('public', file_url.delete_prefix('/'))
      
      if File.exist?(file_path)
        File.delete(file_path)
        true
      else
        false
      end
    rescue => e
      Rails.logger.error "File deletion failed: #{e.message}"
      false
    end

    private

    def validate_file!(file)
      # Kiểm tra extension
      ext = File.extname(file.original_filename).downcase
      unless ALLOWED_EXTENSIONS.include?(ext)
        raise "File type not allowed. Allowed types: #{ALLOWED_EXTENSIONS.join(', ')}"
      end

      # Kiểm tra file size
      if file.size > MAX_FILE_SIZE
        raise "File size too large. Maximum size: #{MAX_FILE_SIZE / 1.megabyte}MB"
      end
    end

    def generate_unique_filename(original_filename)
      ext = File.extname(original_filename)
      basename = File.basename(original_filename, ext)
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      random_string = SecureRandom.hex(8)
      
      "#{basename}_#{timestamp}_#{random_string}#{ext}"
    end
  end
end