document.addEventListener('turbo:load', function() {
    const downloadButtons = document.querySelectorAll('.download-pdf-button');
    downloadButtons.forEach(button => {
        button.addEventListener('click', async function(event) {
            const postId = this.getAttribute('data-post-id');
            const originalText = this.textContent;
            this.textContent = 'Loading...';
            this.disabled = true;

            await fetch(`/posts/${postId}/download_pdf`, {
                method: 'GET'
            })
                .then(response => {
                    if (response.ok) {
                        return response.blob();
                    }
                    throw new Error('Network response was not ok.');
                })
                .then(blob => {
                    const url = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = `post_${postId}.pdf`;
                    document.body.appendChild(a);
                    a.click();
                    a.remove();
                    window.URL.revokeObjectURL(url);
                    this.textContent = originalText;
                    this.disabled = false;

                })
                .then(() => {
                    window.location.reload()
                })
                .catch(error => {
                    const errorElement = document.createElement('p');
                    errorElement.textContent = error?.message;
                    errorElement.setAttribute('class', 'alert alert-danger');
                    document.body.prepend(errorElement);
                    console.error('Error:', error);
                    this.textContent = 'Download PDF';
                    this.disabled = false;
                });
        });

    });
});
