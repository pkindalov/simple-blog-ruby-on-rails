// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

import Rails from "@rails/ujs"

Rails.start()


document.addEventListener('turbo:load', () => {
    document.querySelectorAll('.ckeditor').forEach(editor => {
        ClassicEditor
            .create(editor, {
                // toolbar: [
                //     'bold', 'italic', 'underline', 'strikeThrough', '|',
                //     'alignment', 'numberedList', 'bulletedList', 'outdent', 'indent', '|',
                //     'link', 'insertTable', '|',
                //     'blockQuote', 'undo', 'redo', 'clearFormatting', 'htmlEmbed'
                // ],
                removePlugins: ['ImageUpload', 'MediaEmbed', 'EasyImage']
            })
            .catch(error => {
                console.error(error);
            });
    });
});



