require 'open-uri'
require 'prawn'
require 'mini_magick'
include Rails.application.routes.url_helpers

class UserPostsPdfGenerator
  def initialize(user)
    @user = user
  end

  def generate_pdf
    Prawn::Document.new do |pdf|
      setup_fonts(pdf)
      pdf.text "Posts by #{@user.email}", size: 18, style: :bold
      @user.posts.each do |post|
        pdf.move_down 10
        pdf.text post.title, size: 14, style: :bold
        pdf.move_down 5
        pdf.text post.description, size: 12
        pdf.move_down 10
        process_images(post, pdf)
      end
      pdf.render_file "public/#{@user.email}_posts.pdf"
    end
  end

  private

  def setup_fonts(pdf)
    pdf.font_families.update("DejaVu" => {
      normal: Rails.root.join('app/assets/fonts/DejaVuSans.ttf').to_s,
      bold: Rails.root.join('app/assets/fonts/DejaVuSans-Bold.ttf').to_s
    })
    pdf.font "DejaVu"
  end

  def process_images(post, pdf)
    post.photos.each_with_index do |photo, index|
      pdf.start_new_page if index > 0
      image = convert_image(photo.blob)
      pdf.image image.path, width: 500, height: 300
      pdf.move_down 10
    end
  end

  def convert_image(blob)
    image = MiniMagick::Image.open(url_for(blob))
    image.format "png" if image.type.eql?('WEBP')
    image
  end
end
