function filterNotifications() {
    const checkbox = document.getElementById('filterRead');
    const notifications = document.querySelectorAll('.list-group-item');


    notifications.forEach(notification => {
        const notificationStatus = +notification.getAttribute('data-readed');
        if (checkbox.checked) {
            if (notificationStatus) {
                notification.classList.add('class', 'd-none');
            } else {
                if (!notification.classList.contains('d-none')) {
                    notification.classList.remove('d-none');
                }
            }

        } else {
            if (notification.classList.contains('d-none')) {
                notification.classList.remove('d-none');
            }
        }
    });
}

function refreshFiltersAfterClickActionBtn() {
    const actionBtns = Array.from(document.getElementsByClassName('.notifications__action-btn'));
    actionBtns.forEach(actionBtn => {
        actionBtn.addEventListener('click', function (e) {
            console.log(actionBtn.innerText + ' clicked');
            filterNotifications();
        });
    })
}

document.addEventListener('turbo:load', () => {
    try {
        filterNotifications();
        refreshFiltersAfterClickActionBtn();
    } catch (e) {
        console.error(e.message);
    }
});
