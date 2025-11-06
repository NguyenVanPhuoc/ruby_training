# app/services/user_service.rb
class UserService
  class << self
    def create_user(params)
      avatar_url = handle_avatar_upload(params[:avatar])
      
      user_params = params.except(:avatar)
      user_params[:avatar] = avatar_url if avatar_url.present?
      
      user = User.new(user_params)
      
      if user.save
        user
      else
        # Xóa file đã upload nếu tạo user thất bại
        FileUploadService.delete(avatar_url) if avatar_url.present?
        user
      end
    end

    def update_user(user_id, params)
      user = UserRepository.find(user_id)
      return false unless user
      
      old_avatar = user.avatar
      
      # Xử lý upload avatar mới
      if params[:avatar].present?
        new_avatar_url = handle_avatar_upload(params[:avatar])
        params[:avatar] = new_avatar_url if new_avatar_url.present?
      else
        params = params.except(:avatar)
      end
      
      if user.update(params)
        # Xóa avatar cũ nếu update thành công và có avatar mới
        if params[:avatar].present? && old_avatar.present?
          FileUploadService.delete(old_avatar)
        end
        true
      else
        # Xóa avatar mới nếu update thất bại
        FileUploadService.delete(params[:avatar]) if params[:avatar].present?
        false
      end
    end

    def destroy_user(user_id)
      user = UserRepository.find(user_id)
      return false unless user
      
      old_avatar = user.avatar
      
      if user.destroy
        # Xóa avatar khi xóa user
        FileUploadService.delete(old_avatar) if old_avatar.present?
        true
      else
        false
      end
    end

    private

    def handle_avatar_upload(avatar_param)
      return nil unless avatar_param.present?
      
      # Nếu là uploaded file (có method read), thì upload
      if avatar_param.respond_to?(:read)
        FileUploadService.upload(avatar_param, folder: 'avatars')
      else
        # Nếu là string (giữ nguyên avatar cũ), return nil
        nil
      end
    end
  end
end