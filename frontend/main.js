document.addEventListener("DOMContentLoaded", () => {
    
    // --- 1. GÜVENLİK KONTROLÜ ---
    // Hangi sayfadayız?
    const path = window.location.pathname;
    const isLogged = localStorage.getItem("isLoggedIn");
    const userName = localStorage.getItem("userName") || "Gezgin";

    // Eğer 'favorites' veya 'ticket' sayfasındaysak VE giriş yapılmamışsa:
    if ((path.includes("favorites.html") || path.includes("ticket.html")) && isLogged !== "true") {
        alert("Bu sayfayı görüntülemek için lütfen önce giriş yapınız.");
        window.location.href = "giris.html"; // Giriş sayfasına şutla
        return; // Aşağıdaki kodları çalıştırma
    }

    // --- 2. NAVBAR GÜNCELLEME (Giriş Yapılmışsa) ---
    const authBox = document.getElementById("auth-box");

    if (isLogged === "true" && authBox) {
        // Sağ paneli değiştir: Butonlar yerine İsim ve Çıkış butonu koy
        authBox.innerHTML = `
            <div style="display: flex; align-items: center; gap: 15px;">
                <span style="color: white; font-weight: 500; font-size: 0.95rem;">
                    <i class="fa-regular fa-user" style="color:var(--primary-light); margin-right:5px;"></i>
                    ${userName}
                </span>
                <button id="logoutBtn" class="btn-outline" style="border-color: #ff4757; color: #ff4757; padding: 6px 18px; font-size: 0.9rem;">
                    Çıkış
                </button>
            </div>
        `;

        // Çıkış Butonuna Basılınca Ne Olsun?
        document.getElementById("logoutBtn").addEventListener("click", () => {
            // Bilgileri sil
            localStorage.removeItem("isLoggedIn");
            localStorage.removeItem("userName");
            localStorage.removeItem("favorites"); // İstersen favorileri de silebilirsin
            
            // Ana sayfaya yönlendir
            window.location.href = "index.html";
        });
    }
});