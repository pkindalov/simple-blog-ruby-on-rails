document.addEventListener('DOMContentLoaded', function() {
    const sortSelect = document.getElementById('sort_by');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            const selectedValue = this.value;
            window.location.href = '/?sort_by=' + selectedValue;
        });
    }
});
