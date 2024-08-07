// Function to scroll to the bottom of the messages list
function scrollToBottom() {
    window.scrollTo(0, document.body.scrollHeight);
}

// Scroll to bottom on page load
document.addEventListener("turbo:load", function () {
    if(window.location.href.indexOf('/messages') !== -1)  scrollToBottom();
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