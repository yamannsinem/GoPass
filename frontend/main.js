document.addEventListener("DOMContentLoaded", () => {
    
    // --- 1. LOGO YÖNLENDİRMESİ ---
    // Navbar içindeki logoyu bul
    const logoBtn = document.querySelector(".navbar .logo");
    if (logoBtn) {
        // Tıklanabilir olduğunu gösteren stil
        logoBtn.style.cursor = "pointer"; 
        
        // Tıklama olayı ekle
        logoBtn.addEventListener("click", () => {
            window.location.href = "index.html";
        });
    }

    // --- 2. GÜVENLİK KONTROLÜ ---
    const path = window.location.pathname;
    const isLogged = localStorage.getItem("isLoggedIn");
    // Kullanıcı adını al
    const userName = localStorage.getItem("userName") || "Gezgin";

    // Profil, Favoriler veya Bilet sayfasındaysak ve giriş yoksa:
    if ((path.includes("favorites.html") || path.includes("ticket.html") || path.includes("profil.html")) && isLogged !== "true") {
        alert("Bu sayfayı görüntülemek için lütfen önce giriş yapınız.");
        window.location.href = "giris.html";
        return;
    }

    // --- 3. NAVBAR GÜNCELLEME (Giriş Yapılmışsa) ---
    const authBox = document.getElementById("auth-box");

    if (isLogged === "true" && authBox) {
        // İsmin baş harfini al
        const initial = userName.charAt(0).toUpperCase();

        // Sağ paneli güncelle: İsim linki + Çıkış butonu
        authBox.innerHTML = `
            <div style="display: flex; align-items: center; gap: 15px;">
                
                <a href="profil.html" style="text-decoration: none; display: flex; align-items: center; gap: 10px; transition: 0.3s;" onmouseover="this.style.opacity='0.8'" onmouseout="this.style.opacity='1'">
                    <div style="width: 32px; height: 32px; background: linear-gradient(135deg, var(--primary), var(--primary-light)); border-radius: 50%; display: flex; justify-content: center; align-items: center; color: white; font-weight: bold; box-shadow: 0 0 10px rgba(138, 43, 226, 0.4);">
                        ${initial}
                    </div>
                    <span style="color: white; font-weight: 500; font-size: 0.95rem;">
                        ${userName}
                    </span>
                </a>

                <div style="width: 1px; height: 20px; background: rgba(255,255,255,0.2);"></div>

                <button id="logoutBtn" class="btn-outline" style="border-color: rgba(255, 71, 87, 0.5); color: #ff4757; padding: 5px 15px; font-size: 0.85rem; background: transparent;">
                    Çıkış
                </button>
            </div>
        `;

        // Çıkış İşlemi
        document.getElementById("logoutBtn").addEventListener("click", () => {
            if(confirm("Çıkış yapmak istediğinize emin misiniz?")) {
                localStorage.removeItem("isLoggedIn");
                localStorage.removeItem("userName");
                // localStorage.removeItem("favorites"); // Favorileri silmek istersen açabilirsin
                window.location.href = "index.html";
            }
        });
    }
});
