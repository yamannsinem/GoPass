// ========================================
// AUTH.JS – Login / Register
// ========================================

document.addEventListener("DOMContentLoaded", () => {

    // LOGIN
    const loginForm = document.getElementById("login-form");
    if (loginForm) {
        loginForm.addEventListener("submit", (e) => {
            e.preventDefault();

            const email = document.getElementById("email").value.trim();
            const pass = document.getElementById("password").value.trim();

            if (!email || !pass) return alert("Tüm alanları doldurunuz.");

            // Buraya backend bağlanacak →
            // const res = await login(email, pass);

            localStorage.setItem("isLoggedIn", "true");
            localStorage.setItem("userName", email.split("@")[0]);

            window.location.href = "index.html";
        });
    }

    // REGISTER
    const regForm = document.getElementById("register-form");
    if (regForm) {
        regForm.addEventListener("submit", (e) => {
            e.preventDefault();

            const full = document.getElementById("full_name").value.trim();
            const mail = document.getElementById("email").value.trim();
            const pass1 = document.getElementById("password").value.trim();
            const pass2 = document.getElementById("password2").value.trim();

            if (pass1 !== pass2) return alert("Şifreler eşleşmiyor!");

        

            localStorage.setItem("isLoggedIn", "true");
            localStorage.setItem("userName", full);

            window.location.href = "index.html";
        });
    }

});
