document.addEventListener('turbo:load', () => {
    const allNotifications = [
        ...Array.from(document.getElementsByClassName("alert-success")),
        ...Array.from(document.getElementsByClassName("alert-danger"))
    ];

    allNotifications.length > 0 && allNotifications.forEach((notification) => {
        notification.addEventListener("click", (event) => {
            notification.style.display = "none";
        })
        setTimeout(function () {
            notification.style.display = "none";
        }, 1500)
    })
});