// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

import Rails from "@rails/ujs"

Rails.start()


document.addEventListener('turbo:load', () => {
    document.querySelectorAll('.ckeditor').forEach(editor => {
        ClassicEditor
            .create(editor)
            .catch(error => {
                console.error(error);
            });
    });
});



