document.addEventListener("DOMContentLoaded", () => {
    const list = document.getElementById("ticket-list");

    if (!list) return;

    // Biletleri Listeleme Fonksiyonu
    function renderMyTickets() {
        list.innerHTML = ""; // Listeyi temizle
        
        // LocalStorage'dan gerçek biletleri çek
        const myTickets = JSON.parse(localStorage.getItem("myTickets") || "[]");

        // Eğer hiç bilet yoksa
        if (myTickets.length === 0) {
            list.innerHTML = `
                <div style="text-align:center; padding: 50px; color:var(--text-dim);">
                    <i class="fa-solid fa-ticket" style="font-size: 3rem; margin-bottom: 20px; opacity: 0.5;"></i>
                    <p style="font-size: 1.1rem;">Henüz aktif bir seyahatiniz bulunmuyor.</p>
                    <a href="index.html" class="btn-outline" style="margin-top:20px; display:inline-block; border-color:var(--text-dim); color:var(--text-dim);">
                        Yeni Sefer Ara
                    </a>
                </div>`;
            return;
        }

        // Biletleri Döngüye Sok ve Ekrana Bas
        myTickets.forEach((t, index) => {
            const card = document.createElement("div");
            card.classList.add("ticket-card");

            card.innerHTML = `
                <div class="ticket-info">
                    <div class="company-name">
                        <i class="fa-solid fa-bus"></i> ${t.company}
                    </div>
                    <div class="route-info">
                        ${t.from} <i class="fa-solid fa-arrow-right-long" style="font-size:0.8rem; margin:0 5px;"></i> ${t.to}
                    </div>
                    <div class="time-info">
                        <i class="fa-regular fa-calendar"></i> ${t.date} 
                        <i class="fa-regular fa-clock" style="margin-left:10px;"></i> ${t.time}
                        <span style="display:block; margin-top:5px; color:var(--primary); font-size: 0.9rem;">
                            <i class="fa-solid fa-chair"></i> Koltuk: <strong>${t.seat || "?"}</strong>
                        </span>
                    </div>
                </div>
                
                <div class="ticket-action">
                    <div class="price" style="margin-bottom:10px; font-size: 1.2rem; font-weight:bold; color: white;">${t.price}</div>
                    
                    <button class="remove-btn" onclick="cancelTicket(${index})">
                        <i class="fa-solid fa-xmark"></i> İptal Et
                    </button>
                </div>
            `;

            list.appendChild(card);
        });
    }

    // İPTAL ETME FONKSİYONU
    window.cancelTicket = function(index) {
        if(confirm("Bileti iptal etmek istediğinize emin misiniz?")) {
            // Mevcut listeyi çek
            let myTickets = JSON.parse(localStorage.getItem("myTickets") || "[]");
            
            // Seçilen bileti sil
            myTickets.splice(index, 1);
            
            // Yeni listeyi kaydet
            localStorage.setItem("myTickets", JSON.stringify(myTickets));
            
            // Ekranı yenile
            renderMyTickets();
        }
    };

    // Sayfa açıldığında çalıştır
    renderMyTickets();
});
