document.addEventListener("DOMContentLoaded", () => {

    // --- DOM ELEMENTLERİ ---
    const heroSection = document.querySelector(".hero");
    const resultsSection = document.getElementById("results");
    const seatSection = document.getElementById("seat-selection-section");
    
    const newStatsBar = document.querySelector(".stats-bar");
    const visionSection = document.querySelector(".vision-section");
    const gallerySection = document.querySelector(".gallery-section");
    const featureSection = document.querySelector(".feature-split");
    
    // --- TARİH AYARI ---
    const dateInput = document.getElementById("date");
    if (dateInput) {
        const today = new Date().toISOString().split("T")[0];
        dateInput.min = today;
    }

    // --- 1. ARAMA İŞLEMİ VE FAVORİLER (GÜNCELLENDİ: ROTA BAZLI) ---
    const searchBtn = document.getElementById("searchBtn");
    const resultsList = document.getElementById("results-list");

    // Rota Favorileme Fonksiyonu
    window.toggleFavorite = function(btn, from, to) {
        // Görünüm güncelle
        btn.classList.toggle("active");
        
        const icon = btn.querySelector("i");
        if (btn.classList.contains("active")) {
            icon.classList.remove("fa-regular");
            icon.classList.add("fa-solid");
        } else {
            icon.classList.remove("fa-solid");
            icon.classList.add("fa-regular");
        }

        // LocalStorage İşlemleri
        let favs = JSON.parse(localStorage.getItem("favoriteRoutes") || "[]");
        
        // Bu rota zaten var mı?
        const existsIndex = favs.findIndex(f => f.from === from && f.to === to);

        if (existsIndex > -1) {
            // Varsa sil
            favs.splice(existsIndex, 1);
        } else {
            // Yoksa ekle (Sadece Rota Bilgisi)
            favs.push({ from: from, to: to });
        }
        
        localStorage.setItem("favoriteRoutes", JSON.stringify(favs));
    };

    if (searchBtn) {
        const mockTrips = [
            { id: 1, company: "Pamukkale", time: "14:00", route: "İst -> Ank", price: 450 },
            { id: 2, company: "Kamil Koç", time: "15:30", route: "İst -> Ank", price: 480 },
            { id: 3, company: "Metro", time: "18:00", route: "İst -> Ank", price: 520 },
            { id: 4, company: "Varan", time: "21:00", route: "İst -> Ank", price: 600 }
        ];

        searchBtn.addEventListener("click", () => {
            if(dateInput && !dateInput.value) {
                alert("Lütfen bir yolculuk tarihi seçiniz.");
                return;
            }
            renderResults(mockTrips);
        });

        function renderResults(trips) {
            resultsList.innerHTML = "";
            
            // Arama kutularındaki değerleri al (Varsayılan değerlerle)
            const originVal = document.getElementById("origin").value || "İstanbul";
            const destVal = document.getElementById("destination").value || "Ankara";

            // Mevcut favori rotaları çek
            let favs = JSON.parse(localStorage.getItem("favoriteRoutes") || "[]");
            
            // Şu an aranan rota favorilerde var mı?
            const isRouteFav = favs.some(f => f.from === originVal && f.to === destVal);

            trips.forEach(t => {
                // Eğer rota favoriyse tüm kartlardaki kalp dolu olsun
                const activeClass = isRouteFav ? "active" : "";
                const iconClass = isRouteFav ? "fa-solid" : "fa-regular";

                const card = document.createElement("div");
                card.classList.add("ticket-card");
                card.innerHTML = `
                    <div class="ticket-info">
                        <div class="company-name">${t.company}</div>
                        <div class="time-info">
                            <i class="fa-regular fa-clock"></i> ${t.time} 
                            <span style="margin-left:10px; color:#aaa;">${originVal} > ${destVal}</span>
                        </div>
                    </div>
                    
                    <div class="ticket-action" style="display:flex; align-items:center;">
                        
                        <button class="btn-fav ${activeClass}" onclick="toggleFavorite(this, '${originVal}', '${destVal}')" title="Bu Rotayı Favorilere Ekle">
                            <i class="${iconClass} fa-heart"></i>
                        </button>

                        <div class="price" style="margin-right:15px;">${t.price} ₺</div>
                        
                        <button class="btn-buy" onclick="goToSeatSelection('${t.company}', ${t.price}, '${t.time}')">
                            Koltuk Seç <i class="fa-solid fa-chevron-right"></i>
                        </button>
                    </div>
                `;
                resultsList.appendChild(card);
            });
            resultsSection.classList.remove("hidden");
            resultsSection.scrollIntoView({ behavior: 'smooth' });
        }
    }

    // --- 2. KOLTUK SEÇİM EKRANINA GEÇİŞ ---
    let selectedSeatNum = null;
    let currentTripTime = "14:00";

    window.goToSeatSelection = function(company, price, time) {
        if(time) currentTripTime = time;

        heroSection.classList.add("hidden");
        resultsSection.classList.add("hidden");
        if(newStatsBar) newStatsBar.classList.add("hidden");
        if(visionSection) visionSection.classList.add("hidden");
        if(gallerySection) gallerySection.classList.add("hidden");
        if(featureSection) featureSection.classList.add("hidden");

        seatSection.classList.remove("hidden");
        
        document.getElementById("summaryCompany").innerText = company;
        document.getElementById("summaryPrice").innerText = price + " ₺";
        document.getElementById("summarySeat").innerText = "--";
        selectedSeatNum = null;

        const grid = document.getElementById("mainSeatsGrid");
        grid.innerHTML = "";
        
        for(let i=1; i<=40; i++) {
            const seat = document.createElement("div");
            seat.classList.add("seat");
            seat.innerText = i;
            seat.style.display = "flex";
            seat.style.justifyContent = "center";
            seat.style.alignItems = "center";
            seat.style.cursor = "pointer";
            
            if(Math.random() < 0.3) seat.classList.add("occupied");

            seat.addEventListener("click", function() {
                if(this.classList.contains("occupied")) {
                    alert("Bu koltuk dolu!");
                    return;
                }
                const previouslySelected = grid.querySelector(".seat.selected");
                if (previouslySelected) previouslySelected.classList.remove("selected");
                
                this.classList.add("selected");
                selectedSeatNum = i;
                document.getElementById("summarySeat").innerText = i;
            });
            grid.appendChild(seat);
        }
        window.scrollTo(0, 0);
    };

    // --- GERİ DÖN ---
    const backBtn = document.getElementById("backToSearchBtn");
    if(backBtn) {
        backBtn.addEventListener("click", () => {
            seatSection.classList.add("hidden");
            heroSection.classList.remove("hidden");
            resultsSection.classList.remove("hidden");
            if(newStatsBar) newStatsBar.classList.remove("hidden");
            if(visionSection) visionSection.classList.remove("hidden");
            if(gallerySection) gallerySection.classList.remove("hidden");
            if(featureSection) featureSection.classList.remove("hidden");
        });
    }

    // --- ONAYLA VE ÖDEMEYE GİT ---
    const finishBtn = document.getElementById("finishSeatSelection");
    if(finishBtn) {
        finishBtn.addEventListener("click", () => {
            if(!selectedSeatNum) return alert("Lütfen bir koltuk seçiniz!");

            const isLogged = localStorage.getItem("isLoggedIn");
            if(isLogged !== "true") {
                alert("Bilet alabilmek için lütfen önce giriş yapınız.");
                window.location.href = "giris.html";
                return;
            }
            
            const company = document.getElementById("summaryCompany").innerText;
            const price = document.getElementById("summaryPrice").innerText;
            const date = document.getElementById("date").value || new Date().toISOString().split("T")[0];
            
            const pendingTicket = {
                company: company,
                from: document.getElementById("origin").value || "İstanbul",
                to: document.getElementById("destination").value || "Ankara",
                date: date,
                time: currentTripTime,
                price: price,
                seat: selectedSeatNum
            };

            localStorage.setItem("pendingTicket", JSON.stringify(pendingTicket));
            window.location.href = "odeme.html"; 
        });
    }
    
    // Tablar
    const tabs = document.querySelectorAll(".tab-btn");
    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            tabs.forEach(t => t.classList.remove("active"));
            tab.classList.add("active");
        });
    });
});
