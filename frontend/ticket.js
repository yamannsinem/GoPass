document.addEventListener("DOMContentLoaded", () => {
    const list = document.getElementById("ticket-list");

    if (!list) return;

    
    const mockTickets = [
        { company: "Pamukkale", from: "İstanbul", to: "Ankara", date: "12 Ara", time: "14:30", price: "450 ₺" },
        { company: "Kamil Koç", from: "Eskişehir", to: "İzmir", date: "10 Ara", time: "09:00", price: "380 ₺" },
        { company: "Metro", from: "Bursa", to: "Antalya", date: "22 Ara", time: "23:45", price: "520 ₺" },
    ];

    mockTickets.forEach(t => {
        const card = document.createElement("div");
        card.classList.add("ticket-card");

    
        card.innerHTML = `
            <div class="ticket-info">
                <div class="company-name">
                    <i class="fa-solid fa-bus"></i> ${t.company}
                </div>
                <div class="route-info">${t.from} <i class="fa-solid fa-arrow-right-long" style="font-size:0.8rem; margin:0 5px;"></i> ${t.to}</div>
                <div class="time-info">
                    <i class="fa-regular fa-calendar"></i> ${t.date} 
                    <i class="fa-regular fa-clock" style="margin-left:10px;"></i> ${t.time}
                </div>
            </div>
            
            <div class="ticket-action">
                <div class="price">${t.price}</div>
                <button class="btn-buy">
                    Satın Al <i class="fa-solid fa-chevron-right"></i>
                </button>
            </div>
        `;

        list.appendChild(card);
    });
});