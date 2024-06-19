function showToast(toastId, message) {
    var toast = document.getElementById(toastId);
    toast.innerHTML = message;
    toast.classList.add("show");
    toast.classList.remove("hide");

    // After 1 seconds, hide the toast
    setTimeout(function() {
        toast.classList.remove("show");
        toast.classList.add("hide");
    }, 1000);
}