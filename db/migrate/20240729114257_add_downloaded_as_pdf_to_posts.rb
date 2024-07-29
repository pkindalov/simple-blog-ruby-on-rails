class AddDownloadedAsPdfToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :downloaded_as_pdf, :integer, default: 0
  end
end
