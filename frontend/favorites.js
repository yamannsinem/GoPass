document.addEventListener("DOMContentLoaded", () => {

    function renderFavorites() {
        const favList = document.getElementById("fav-list");
        if (!favList) return;
        
        favList.innerHTML = "";

        let favs = JSON.parse(localStorage.getItem("favorites") || "[]");

        if (favs.length === 0) {
            favList.innerHTML = "<p style='color:#ccc; text-align:center;'>Henüz favori eklemediniz.</p>";
            return;
        }

        favs.forEach((f, index) => {
            const card = document.createElement("div");
            card.classList.add("fav-card");

           
            card.innerHTML = `
                <div class="ticket-info">
                    <div class="company-name">${f.company}</div>
                    <div class="route-info">${f.time}</div> 
                    </div>
                <button class="btn-remove" data-index="${index}">
                    <i class="fa-solid fa-trash"></i> Sil
                </button>
            `;

            favList.appendChild(card);
        });
    }

    // SİLME İŞLEMİ
    const favList = document.getElementById("fav-list");
    if (favList) {
        favList.addEventListener("click", function(e) {
            // Tıklanan elementin kendisi veya kapsayıcısı .btn-remove ise
            const btn = e.target.closest(".btn-remove");
            if (btn) {
                let favs = JSON.parse(localStorage.getItem("favorites") || "[]");
                favs.splice(btn.dataset.index, 1);
                localStorage.setItem("favorites", JSON.stringify(favs));
                renderFavorites();
            }
        });
    }

    renderFavorites();
});