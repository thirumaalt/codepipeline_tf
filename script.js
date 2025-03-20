document.querySelector('form').addEventListener('submit', function(event) {
    event.preventDefault();

    const email = document.querySelector('input[type="text"]').value;
    const password = document.querySelector('input[type="password"]').value;

    if (!email || !password) {
        alert('Please fill in both fields.');
        return;
    }

    alert(`Login Attempt with:\nEmail/Phone: ${email}\nPassword: ${password}`);
});
