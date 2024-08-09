// Function to scroll to the bottom of the messages list
function scrollToBottom() {
    window.scrollTo(0, document.body.scrollHeight);
}

// Scroll to bottom on page load
document.addEventListener("turbo:load", function () {
    if (window.location.href.indexOf('/messages') !== -1) {
        scrollToBottom();

        // Attach reaction button handlers
        document.querySelectorAll('.reaction-button').forEach(button => {
            button.addEventListener('click', (event) => {
                event.preventDefault();
                const messageId = button.closest('.message').id.split('-')[1];
                const url = `/messages/${messageId}/reactions`;

                fetch(url, {
                    method: 'POST',
                    headers: {
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ reaction: { reaction_type: button.dataset.reactionType } })
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! Status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                        if (data.success) {
                            updateReactions(messageId, data.reactions_html);
                        }
                    })
                    .catch(error => console.error('Error:', error));
            });
        });

        // Scroll to bottom on new message send
        document.getElementById("new_message_form").addEventListener("submit", function (event) {
            event.preventDefault(); // Prevent the default form submission
            const form = this;

            // Delay to allow message to be added to DOM
            setTimeout(function () {
                form.submit(); // Submit the form after scrolling
                scrollToBottom();
            }, 100);
        });
    }
});

function updateReactions(messageId, reactionsHtml) {
    const reactionsContainer = document.querySelector(`#message-${messageId} .current-reactions`);
    if (reactionsContainer) {
        reactionsContainer.innerHTML = reactionsHtml;
    }
}
