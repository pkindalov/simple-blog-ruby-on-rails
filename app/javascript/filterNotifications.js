// JavaScript function to filter notifications based on the read status
function filterNotifications() {
    const checkbox = document.getElementById('filterRead');
    const notifications = document.querySelectorAll('.list-group-item');

    notifications.forEach(notification => {
        const notificationStatus = +notification.getAttribute('data-readed');
        if(checkbox.checked && notificationStatus) {
            notification.style.visibility = "hidden";
        } else {
            notification.style.visibility = "visible";
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    try {
        filterNotifications();
    } catch (e) {
        console.error(e.message());
    }

    filterNotifications();
});