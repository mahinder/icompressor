class User < ActiveRecord::Base
  attr_accessible :name, :avtar
  
  has_attached_file :avtar, styles: { 
                    thumb: "150x150>",
                    medium: '300x300>'
                   },
                  url: "/assets/users/:id/:style/:basename.:extension",
                  path: ":rails_root/public/assets/users/:id/:style/:basename.:extension"

  validates :avtar, :attachment_presence => true
  validates_with AttachmentPresenceValidator, :attributes => :avtar
  
  #after_post_process :compress
  after_save :compress_with_ffmpeg
  
  private
  
  def compress
    current_format = File.extname(avtar.queued_for_write[:original].path)

    avtar.queued_for_write.each do |key, file|
      reg_jpegoptim = /(jpg|jpeg|jfif)/i
      reg_optipng = /(png|bmp|gif|pnm|tiff)/i

      logger.info("Processing compression: key: #{key} - file: #{file.path} - ext: #{current_format}")

      if current_format =~ reg_jpegoptim
        compress_with_jpegoptim(file)
      elsif current_format =~ reg_optipng
        compress_with_optpng(file)
      else
        logger.info("File: #{file.path} is not compressed!")
      end
    end
  end

  def compress_with_jpegoptim(file)
    current_size = File.size(file.path)
    Paperclip.run("jpegoptim", "-o --strip-all #{file.path}")
    compressed_size = File.size(file.path)
    compressed_ratio = (current_size - compressed_size) / current_size.to_f
    logger.debug("#{current_size} - #{compressed_size} - #{compressed_ratio}")
    logger.debug("JPEG family compressed, compressed: #{ '%.2f' % (compressed_ratio * 100) }%")
  end

  def compress_with_optpng(file)
    current_size = File.size(file.path)
    Paperclip.run("optipng", "-o7 --strip=all #{file.path}")
    compressed_size = File.size(file.path)
    compressed_ratio = (current_size - compressed_size) / current_size.to_f
    logger.debug("#{current_size} - #{compressed_size} - #{compressed_ratio}")
    logger.debug("PNG family compressed, compressed: #{ '%.2f' % (compressed_ratio * 100) }%")   
  end
  
  def compress_with_ffmpeg
    [:thumb, :original, :medium].each do |type|
      img_path = self.avtar.path(type)
      Paperclip.run("ffmpeg", " -i #{img_path} #{img_path}")
    end
  end

end
