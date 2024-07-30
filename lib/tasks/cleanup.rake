# frozen_string_literal: true

# lib/tasks/cleanup.rake
namespace :cleanup do
  desc 'Remove old PDF files'
  task remove_old_pdfs: :environment do
    puts 'Starting to remove old PDF files...'
    Dir.glob(Rails.root.join('public', '*.pdf')).each do |file_path|
      # if File.mtime(file_path) < 1.week.ago
      if File.mtime(file_path) < 1.day.ago
        File.delete(file_path)
        puts "Deleted: #{file_path}"
      else
        # puts "Skipping: #{file_path}. The file is planned to be deleted on: #{File.mtime(file_path) + 1.week}"
        puts "Skipping: #{file_path}. The file is planned to be deleted on: #{File.mtime(file_path) + 1.day}"
      end
    rescue StandardError => e
      puts "Failed to delete #{file_path}: #{e.message}"
    end
    puts 'Done!'
  end

  task remove_pdf_files: :environment do
    puts 'Starting to remove PDF files from public directory...'
    Dir.glob(Rails.root.join('public', '*.pdf')).each do |file_path|
      File.delete(file_path)
      puts "Deleted: #{file_path}"
    rescue StandardError => e
      puts "Failed to delete #{file_path}: #{e.message}"
    end
    puts 'Done!'
  end
end
