document.addEventListener("DOMContentLoaded", () => {

    // --- DOM ELEMENTLERİ ---
    const heroSection = document.querySelector(".hero");
    const resultsSection = document.getElementById("results");
    const seatSection = document.getElementById("seat-selection-section");
    
    // Varsa diğer bölümleri de seçelim (Hata vermemesi için kontrol edeceğiz)
    const newStatsBar = document.querySelector(".stats-bar");
    const visionSection = document.querySelector(".vision-section");
    const gallerySection = document.querySelector(".gallery-section");
    const featureSection = document.querySelector(".feature-split");
    
    // --- 1. ARAMA İŞLEMİ ---
    const searchBtn = document.getElementById("searchBtn");
    const resultsList = document.getElementById("results-list");

    if (searchBtn) {
        const mockTrips = [
            { id: 1, company: "Pamukkale", time: "14:00", route: "İst -> Ank", price: 450 },
            { id: 2, company: "Kamil Koç", time: "15:30", route: "İst -> Ank", price: 480 },
            { id: 3, company: "Metro", time: "18:00", route: "İst -> Ank", price: 520 },
            { id: 4, company: "Varan", time: "21:00", route: "İst -> Ank", price: 600 }
        ];

        searchBtn.addEventListener("click", () => {
            renderResults(mockTrips);
        });

        function renderResults(trips) {
            resultsList.innerHTML = "";
            trips.forEach(t => {
                const card = document.createElement("div");
                card.classList.add("ticket-card");
                card.innerHTML = `
                    <div class="ticket-info">
                        <div class="company-name">${t.company}</div>
                        <div class="time-info">
                            <i class="fa-regular fa-clock"></i> ${t.time} 
                            <span style="margin-left:10px; color:#aaa;">${t.route}</span>
                        </div>
                    </div>
                    <div class="ticket-action">
                        <div class="price">${t.price} ₺</div>
                        <button class="btn-buy" onclick="goToSeatSelection('${t.company}', ${t.price})">
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

    // --- 2. KOLTUK SEÇİM EKRANINA GEÇİŞ (BURASI KRİTİK) ---
    let selectedSeatNum = null;

    // Fonksiyonu window'a atadık ki HTML'den erişilebilsin
    window.goToSeatSelection = function(company, price) {
        // 1. Sayfadaki diğer her şeyi GİZLE
        heroSection.classList.add("hidden");
        resultsSection.classList.add("hidden");
        if(newStatsBar) newStatsBar.classList.add("hidden");
        if(visionSection) visionSection.classList.add("hidden");
        if(gallerySection) gallerySection.classList.add("hidden");
        if(featureSection) featureSection.classList.add("hidden");

        // 2. Koltuk Seçim Ekranını AÇ
        seatSection.classList.remove("hidden");
        
        // Bilgileri Güncelle
        document.getElementById("summaryCompany").innerText = company;
        document.getElementById("summaryPrice").innerText = price + " ₺";
        document.getElementById("summarySeat").innerText = "--";
        selectedSeatNum = null;

        // 3. Koltukları Oluştur
        const grid = document.getElementById("mainSeatsGrid");
        grid.innerHTML = ""; // Temizle
        
        for(let i=1; i<=40; i++) {
            const seat = document.createElement("div");
            
            // CSS sınıflarını ekle (seat sınıfı CSS'te tanımlı olmalı!)
            seat.classList.add("seat");
            seat.innerText = i;
            
            // Stil Ayarları (JS ile zorla stil veriyoruz ki CSS hatası varsa bile çalışsın)
            seat.style.display = "flex";
            seat.style.justifyContent = "center";
            seat.style.alignItems = "center";
            seat.style.cursor = "pointer"; // Tıklanabilir el işareti çıksın
            
            // Rastgele Doluluk
            if(Math.random() < 0.3) {
                seat.classList.add("occupied");
            }

            // --- TIKLAMA OLAYI (EVENT LISTENER) ---
            seat.addEventListener("click", function() {
                // Eğer doluysa (occupied) işlem yapma
                if(this.classList.contains("occupied")) {
                    alert("Bu koltuk dolu!");
                    return;
                }

                // Önceki seçimi kaldır
                const previouslySelected = grid.querySelector(".seat.selected");
                if (previouslySelected) {
                    previouslySelected.classList.remove("selected");
                }
                
                // Yeni seçimi yap
                this.classList.add("selected");
                selectedSeatNum = i;
                
                // Özeti güncelle
                document.getElementById("summarySeat").innerText = i;
            });

            grid.appendChild(seat);
        }

        window.scrollTo(0, 0);
    };

    // --- 3. GERİ DÖN BUTONU ---
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

    // --- 4. ONAYLA VE BİTİR ---
    const finishBtn = document.getElementById("finishSeatSelection");
    if(finishBtn) {
        finishBtn.addEventListener("click", () => {
            if(!selectedSeatNum) {
                alert("Lütfen bir koltuk seçiniz!");
                return;
            }
            alert(`✅ İşlem Tamam!\n${selectedSeatNum} numaralı koltuk alındı.`);
            location.reload(); 
        });
    }
    
    // --- 5. SEKME GEÇİŞLERİ (Tabs) ---
    const tabs = document.querySelectorAll(".tab-btn");
    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            tabs.forEach(t => t.classList.remove("active"));
            tab.classList.add("active");
        });
    });
});