document.addEventListener('turbo:load', function () {
    const downloadButtons = document.querySelectorAll('.download-pdf-button');
    downloadButtons.forEach(button => {
        button.addEventListener('click', async function (event) {
            const url = this.getAttribute('data-url');
            const originalText = this.textContent;

            if (!url) {
                displayError('Invalid URL provided.');
                return;
            }

            this.textContent = 'Loading...';
            this.disabled = true;

            await fetch(url, {
                method: 'GET'
            })
                .then(response => {
                    if (response.ok) {
                        return response.blob();
                    }
                    throw new Error('Network response was not ok.');
                })
                .then(blob => {
                    const downloadUrl = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = downloadUrl;
                    a.download = `post_${this.getAttribute('data-post-id')}.pdf`;
                    document.body.appendChild(a);
                    a.click();
                    a.remove();
                    window.URL.revokeObjectURL(downloadUrl);
                    this.textContent = originalText;
                    this.disabled = false;
                })
                .then(() => {
                    window.location.reload();
                })
                .catch(error => {
                    displayError(error?.message, button);
                });
        });
    });

    function displayError(message, button) {
        const errorElement = document.createElement('p');
        errorElement.textContent = message;
        errorElement.setAttribute('class', 'alert alert-danger');
        document.body.prepend(errorElement);
        console.error('Error:', message);
        button.textContent = 'Download PDF';
        button.disabled = false;
    }
});
