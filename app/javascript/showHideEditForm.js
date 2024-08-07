document.addEventListener("turbo:load", function () {
    document.querySelectorAll('.toggle-edit-form').forEach(button => {
        button.addEventListener('click', function () {
            const messageDiv = this.closest('.message');
            const editForm = messageDiv.querySelector('.edit-form');
            const messageText = messageDiv.querySelector('p');

            // Toggle edit form visibility
            if (editForm.style.display === 'none') {
                editForm.style.display = 'block';
                messageText.style.display = 'none'; // Hide message text
                this.style.display = 'none'; // Hide edit button
            } else {
                editForm.style.display = 'none';
                messageText.style.display = 'block'; // Show message text
                this.style.display = 'inline-block'; // Show edit button
            }
        });
    });

    document.querySelectorAll('.cancel-edit-form').forEach(button => {
        button.addEventListener('click', function () {
            const editForm = this.closest('.edit-form');
            const messageDiv = this.closest('.message');
            const messageText = messageDiv.querySelector('p');

            editForm.style.display = 'none'; // Hide edit form
            messageText.style.display = 'block'; // Show message text
            messageDiv.querySelector('.toggle-edit-form').style.display = 'inline-block'; // Show edit button
        });
    });
});
