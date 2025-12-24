document.addEventListener("DOMContentLoaded", () => {

    function renderFavorites() {
        const favList = document.getElementById("fav-list");
        if (!favList) return;
        
        favList.innerHTML = "";

        // Artık "favorites" değil "favoriteRoutes" key'ini kullanıyoruz
        let favs = JSON.parse(localStorage.getItem("favoriteRoutes") || "[]");

        if (favs.length === 0) {
            favList.innerHTML = `
                <div style="text-align:center; color:#888; padding:40px;">
                    <i class="fa-regular fa-map" style="font-size:3rem; margin-bottom:15px; opacity:0.5;"></i>
                    <p>Henüz favori bir rota eklemediniz.</p>
                </div>`;
            return;
        }

        favs.forEach((f, index) => {
            const card = document.createElement("div");
            card.classList.add("fav-card");

            card.innerHTML = `
                <div class="ticket-info" style="display:flex; align-items:center; gap:15px;">
                    <div style="width:50px; height:50px; background:rgba(138,43,226,0.1); border-radius:12px; display:flex; justify-content:center; align-items:center; color:var(--primary); font-size:1.5rem;">
                        <i class="fa-solid fa-route"></i>
                    </div>
                    <div>
                        <div class="company-name" style="font-size:1.2rem; color:white; margin-bottom:5px;">
                            ${f.from} <i class="fa-solid fa-arrow-right" style="font-size:0.9rem; color:var(--text-dim); margin:0 5px;"></i> ${f.to}
                        </div>
                        <div class="route-info" style="font-size:0.9rem;">Favori Rota</div>
                    </div>
                </div>
                
                <div style="display:flex; gap:10px;">
                    <button class="ticket-button" onclick="searchRoute('${f.from}', '${f.to}')" style="font-size:0.9rem; padding:8px 15px;">
                        <i class="fa-solid fa-magnifying-glass"></i> Seferleri Gör
                    </button>
                    
                    <button class="remove-btn" data-index="${index}" style="padding:8px 15px;">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </div>
            `;

            favList.appendChild(card);
        });
    }

    // Silme İşlemi
    const favList = document.getElementById("fav-list");
    if (favList) {
        favList.addEventListener("click", function(e) {
            const btn = e.target.closest(".remove-btn");
            if (btn) {
                let favs = JSON.parse(localStorage.getItem("favoriteRoutes") || "[]");
                favs.splice(btn.dataset.index, 1);
                localStorage.setItem("favoriteRoutes", JSON.stringify(favs));
                renderFavorites();
            }
        });
    }

    // Rotayı Ara Fonksiyonu (Ana sayfaya o bilgilerle gitmek için)
    window.searchRoute = function(from, to) {
        // İstersen burada localStorage'a arama bilgisini kaydedip index.html'de okuyabilirsin
        // Şimdilik sadece ana sayfaya atalım
        window.location.href = "index.html"; 
    };

    renderFavorites();
});
