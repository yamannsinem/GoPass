CREATE TABLE Firma (
    Firma_ID SERIAL PRIMARY KEY,
    Firma_Adi VARCHAR(150) NOT NULL,
    Firma_TelNo VARCHAR(20),
    Firma_email VARCHAR(150) UNIQUE,
    Islem_Durumu VARCHAR(50) DEFAULT 'Aktif'
);

CREATE TABLE Ulasim_Turu (
    Ulasim_Turu_ID SERIAL PRIMARY KEY,
    Aciklama TEXT,
    Koltuk_Tipi VARCHAR(50),
    Arac_Tipi VARCHAR(50) -- 'Otobüs', 'Uçak', 'Vapur' ayrımı için kritik
);

CREATE TABLE Arac (
    Arac_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID) ON UPDATE CASCADE ON DELETE SET NULL,
    Arac_Tipi VARCHAR(100), -- Frontend filtreleme buraya bakıyor
    Arac_No VARCHAR(50),
    Kapasite INT,
    Koltuk_Duzeni VARCHAR(100),
    Ulasim_Turu_ID INT REFERENCES Ulasim_Turu(Ulasim_Turu_ID)
);

CREATE TABLE Koltuk (
    Koltuk_ID SERIAL PRIMARY KEY,
    Arac_ID INT REFERENCES Arac(Arac_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    Koltuk_Turu VARCHAR(50),
    Durum VARCHAR(50) DEFAULT 'Boş',
    Koltuk_No VARCHAR(20)
);

CREATE TABLE Konum (
    Konum_ID SERIAL PRIMARY KEY,
    Sehir VARCHAR(100) NOT NULL,
    Sehir_Kodu INT
);

CREATE TABLE Rota (
    Rota_ID SERIAL PRIMARY KEY,
    Kalkis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Varis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Km NUMERIC(8,2)
);

-- Rota_Plan: Java Entity'sindeki eksik kolonlar eklendi
CREATE TABLE Rota_Plan (
    Rota_ID INT REFERENCES Rota(Rota_ID),
    Arac_ID INT REFERENCES Arac(Arac_ID),
    Firma_ID INT REFERENCES Firma(Firma_ID),
    -- Java tarafında aranan alanlar eklendi:
    Sefer_Tarihi DATE,
    Sefer_Saati TIME,      -- Java: seferSaati
    Varis_Saati TIME,      -- Java: varisSaati
    Tahmini_Sure VARCHAR(50),
    Bilet_Fiyati NUMERIC(10,2),
    -- Composite Key (Java RotaPlanId ile uyumlu olması için 3'lü tutuyoruz, 
    -- ancak gerçek hayatta tarih de olmalı. Veri girişini buna göre ayarladım.)
    PRIMARY KEY (Rota_ID, Arac_ID, Firma_ID) 
);

CREATE TABLE Kullanici (
    Kullanici_ID SERIAL PRIMARY KEY,
    Isim VARCHAR(100) NOT NULL,
    Soyisim VARCHAR(100) NOT NULL,
    Dogum_Tarihi DATE,
    Adres VARCHAR(255),
    Eposta VARCHAR(150) UNIQUE,
    Parola VARCHAR(100)
);

CREATE TABLE Rezervasyon (
    Rezervasyon_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    Koltuk_ID INT REFERENCES Koltuk(Koltuk_ID),
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    -- İlişkiyi yönetmek için ek alanlar (RotaPlan bağlantısı için)
    Rota_ID INT,
    Arac_ID INT,
    Fiyat NUMERIC(10,2),
    Durum VARCHAR(50) 
);

CREATE TABLE Odeme (
    Odeme_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    Odeme_Metodu VARCHAR(50),
    Odeme_Durumu VARCHAR(50) NOT NULL,
    Para_Birimi VARCHAR(20),
    Fiyat NUMERIC(10,2),
    Iade_Tutari NUMERIC(10,2) DEFAULT 0.00
);

CREATE TABLE Fatura (
    Fatura_ID SERIAL PRIMARY KEY,
    Odeme_ID INT REFERENCES Odeme(Odeme_ID),
    Tarih DATE,
    Tutar NUMERIC(10,2)
);

CREATE TABLE Bildirim (
    Bildirim_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Mesaj TEXT,
    Tarih DATE DEFAULT CURRENT_DATE,
    Gosterim_Durumu VARCHAR(50) DEFAULT 'Görülmedi',
    Tur VARCHAR(50)
);

CREATE TABLE Iptal_Politikasi (
    Iptal_Politikasi_ID SERIAL PRIMARY KEY,
    Politika TEXT,
    Fiyat NUMERIC(10,2),
    Durum VARCHAR(50),
    Arac_ID INT REFERENCES Arac(Arac_ID)
);

CREATE TABLE Kampanya (
    Kampanya_ID SERIAL PRIMARY KEY,
    Ad VARCHAR(100),
    Indirim_Orani NUMERIC(5,2),
    Baslangic DATE,
    Bitis DATE,
    Firma_ID INT REFERENCES Firma(Firma_ID)
);

CREATE TABLE Yolcu (
    Yolcu_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Yasi INT,
    Cinsiyet VARCHAR(10)
);

CREATE TABLE Bilet (
    Bilet_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Olusturulma_Tarihi DATE,
    QR_Kod VARCHAR(255),
    Bilet_No VARCHAR(50)
);

CREATE TABLE Indirim (
    Indirim_ID SERIAL PRIMARY KEY,
    Kod VARCHAR(50),
    Indirim_Degeri NUMERIC(5,2),
    Durum VARCHAR(50),
    Kullanim_Hakki VARCHAR(50),
    Indirim_Araligi VARCHAR(50)
);

CREATE TABLE Bilet_Indirim (
    Bilet_ID INT REFERENCES Bilet(Bilet_ID),
    Indirim_ID INT REFERENCES Indirim(Indirim_ID),
    PRIMARY KEY (Bilet_ID, Indirim_ID)
);

CREATE TABLE Ek_Hizmet (
    Ek_Hizmet_ID SERIAL PRIMARY KEY,
    Ad VARCHAR(100),
    Fiyat NUMERIC(10,2),
    Aciklama TEXT
);

CREATE TABLE Rezervasyon_Ek_Hizmet (
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
    Ek_Hizmet_ID INT REFERENCES Ek_Hizmet(Ek_Hizmet_ID),
    PRIMARY KEY (Rezervasyon_ID, Ek_Hizmet_ID)
);

-- Favori Tablosu: Eksik kolonlar (Arac_ID vb.) eklendi
CREATE TABLE Favori (
    Favori_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Favori_Tipi VARCHAR(100),
    Eklenme_Tarihi DATE,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    Rota_ID INT REFERENCES Rota(Rota_ID),
    Arac_ID INT REFERENCES Arac(Arac_ID)
);

CREATE TABLE Rol (
    Rol_ID SERIAL PRIMARY KEY,
    Rol_Adi VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Kullanici_Rol (
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE,
    Rol_ID INT REFERENCES Rol(Rol_ID) ON DELETE CASCADE,
    PRIMARY KEY (Kullanici_ID, Rol_ID)
);

CREATE TABLE Firma_Yonetici (
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID) ON DELETE CASCADE,
    Firma_ID INT REFERENCES Firma(Firma_ID) ON DELETE CASCADE,
    PRIMARY KEY (Kullanici_ID, Firma_ID)
);

CREATE TABLE Rapor (
    Rapor_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    Rapor_Tipi VARCHAR(100),
    Rapor_Veri TEXT,
    Tarih DATE
);

--------------------------------------------------
-- 2) FONKSİYONLAR VE TRIGGERLAR
--------------------------------------------------

-- A) Koltuk Durumu Yönetimi
CREATE OR REPLACE FUNCTION trg_koltuk_durum_yonetimi()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF NEW.Durum = 'Beklemede' THEN
            -- Sadece bu seferlik doluluk kontrolü Java tarafında yapılıyor, 
            -- burada fiziksel koltuğu güncellemeyebiliriz ama mantık olarak kalsın.
            UPDATE Koltuk SET Durum = 'Rezerve' WHERE Koltuk_ID = NEW.Koltuk_ID;
        ELSIF NEW.Durum = 'Tamamlandı' OR NEW.Durum = 'Biletlendi' THEN
            UPDATE Koltuk SET Durum = 'Dolu' WHERE Koltuk_ID = NEW.Koltuk_ID;
        END IF;
        RETURN NEW;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF NEW.Durum = 'İptal' AND OLD.Durum != 'İptal' THEN
            UPDATE Koltuk SET Durum = 'Boş' WHERE Koltuk_ID = OLD.Koltuk_ID;
        END IF;
        IF (NEW.Durum = 'Tamamlandı' OR NEW.Durum = 'Biletlendi') AND (OLD.Durum != 'Tamamlandı' AND OLD.Durum != 'Biletlendi') THEN
            UPDATE Koltuk SET Durum = 'Dolu' WHERE Koltuk_ID = OLD.Koltuk_ID;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_rezervasyon_state_machine
AFTER INSERT OR UPDATE ON Rezervasyon
FOR EACH ROW
EXECUTE FUNCTION trg_koltuk_durum_yonetimi();

-- B) İptal ve İade Hesaplama
CREATE OR REPLACE FUNCTION rezervasyon_iptal_sonrasi()
RETURNS TRIGGER AS $$
DECLARE
    v_oran NUMERIC(5,2) := 0;
    v_iade NUMERIC(10,2) := 0;
    v_odeme_id INT;
    v_odeme_tutar NUMERIC(10,2);
BEGIN
    SELECT odeme_id, fiyat INTO v_odeme_id, v_odeme_tutar
    FROM odeme WHERE rezervasyon_id = NEW.rezervasyon_id LIMIT 1;

    IF v_odeme_id IS NOT NULL THEN
        -- İptal politikası varsa oran al, yoksa %10 kesinti varsay
        SELECT COALESCE(ip.fiyat, 10) INTO v_oran
        FROM iptal_politikasi ip
        WHERE ip.arac_id = NEW.arac_id LIMIT 1;

        v_iade := v_odeme_tutar * (1 - (v_oran / 100));

        UPDATE odeme SET odeme_durumu = 'İade Edildi', iade_tutari = v_iade WHERE odeme_id = v_odeme_id;
        
        INSERT INTO bildirim (kullanici_id, mesaj, tur)
        VALUES (NEW.kullanici_id, CONCAT('İade Tutarınız: ', v_iade, ' TL'), 'İptal');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_rezervasyon_iptal
AFTER UPDATE OF durum ON rezervasyon
FOR EACH ROW
WHEN (NEW.durum = 'İptal' AND OLD.durum IS DISTINCT FROM 'İptal')
EXECUTE FUNCTION rezervasyon_iptal_sonrasi();

-- C) Rota Bulma Fonksiyonu
CREATE OR REPLACE FUNCTION fn_rota_bul(p_kalkis_sehir VARCHAR, p_varis_sehir VARCHAR)
RETURNS TABLE (
    Firma VARCHAR,
    Arac_Tipi VARCHAR,  
    Kalkis VARCHAR,
    Varis VARCHAR,
    Mesafe_KM NUMERIC,
    Tahmini_Sure_Saat NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.Firma_Adi,
        a.Arac_Tipi::VARCHAR, 
        k1.Sehir,
        k2.Sehir,
        r.Km,
        ROUND((r.Km / 90.0), 1) 
    FROM Rota r
    JOIN Konum k1 ON r.Kalkis_Konum_ID = k1.Konum_ID
    JOIN Konum k2 ON r.Varis_Konum_ID = k2.Konum_ID
    JOIN Rota_Plan rp ON r.Rota_ID = rp.Rota_ID
    JOIN Arac a ON rp.Arac_ID = a.Arac_ID
    JOIN Firma f ON rp.Firma_ID = f.Firma_ID
    WHERE k1.Sehir ILIKE p_kalkis_sehir AND k2.Sehir ILIKE p_varis_sehir;
END;
$$ LANGUAGE plpgsql;



-- 1. FİRMALAR (Otobüs, Uçak, Vapur)
INSERT INTO Firma (Firma_Adi, Firma_TelNo, Firma_email) VALUES 
('Kamil Koç', '4440562', 'iletisim@kamilkoc.com'),
('Pamukkale', '08503333535', 'iletisim@pamukkale.com'),
('Metro Turizm', '08502223455', 'iletisim@metro.com'),
('Türk Hava Yolları', '4440849', 'contact@thy.com'),
('Pegasus', '08882281212', 'contact@flypgs.com'),
('SunExpress', '4440797', 'info@sunexpress.com'),
('İDO', '08502224436', 'info@ido.com.tr'),
('BUDO', '4449916', 'info@burulas.com.tr');

-- 2. ULAŞIM TÜRLERİ
INSERT INTO Ulasim_Turu (Aciklama, Koltuk_Tipi, Arac_Tipi) VALUES 
('Karayolu Seyahati', 'Standart', 'Otobüs'),
('Havayolu Seyahati', 'Ekonomi', 'Uçak'),
('Denizyolu Seyahati', 'Salon', 'Vapur');

-- 3. KONUMLAR
INSERT INTO Konum (Sehir, Sehir_Kodu) VALUES 
('İstanbul', 34), ('Ankara', 6), ('İzmir', 35), ('Antalya', 7), 
('Bursa', 16), ('Muğla', 48), ('Trabzon', 61), ('Adana', 1);

-- 4. ARAÇLAR (Her firmaya uygun araçlar)
INSERT INTO Arac (Firma_ID, Arac_Tipi, Arac_No, Kapasite, Koltuk_Duzeni, Ulasim_Turu_ID) VALUES 
-- Otobüsler
(1, 'Otobüs', '34KMK01', 40, '2+1', 1), (1, 'Otobüs', '06ANK02', 46, '2+2', 1),
(2, 'Otobüs', '35PMK01', 40, '2+1', 1), (3, 'Otobüs', '34MTR01', 50, '2+2', 1),
-- Uçaklar
(4, 'Uçak', 'TC-JFK', 180, '3+3', 2), (4, 'Uçak', 'TC-IST', 180, '3+3', 2),
(5, 'Uçak', 'TC-PGS', 189, '3+3', 2),
-- Vapurlar
(7, 'Vapur', 'IDO-1', 400, 'Genel', 3), (8, 'Vapur', 'BUDO-1', 350, 'Genel', 3);

-- 5. KOLTUKLAR (Otomatik oluşturma)
-- Kamil Koç (40 Koltuk)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 1, 'Tekli', generate_series(1,40)::text;
-- Pamukkale (40 Koltuk)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 3, 'Tekli', generate_series(1,40)::text;
-- THY Uçak (100 Koltuk Örnek)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 5, 'Ekonomi', generate_series(1,100)::text;
-- İDO Vapur (100 Koltuk Örnek)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 8, 'Salon', generate_series(1,100)::text;

-- 6. ROTALAR
INSERT INTO Rota (Kalkis_Konum_ID, Varis_Konum_ID, Km) VALUES 
(1, 2, 450.00), -- İst -> Ank
(1, 3, 480.00), -- İst -> İzm
(1, 5, 150.00), -- İst -> Bursa (Vapur için)
(2, 4, 500.00), -- Ank -> Ant
(3, 1, 480.00), -- İzm -> İst
(1, 7, 1000.00); -- İst -> Trabzon (Uçak için)

-- 7. ROTA PLANLARI (Seferler) - Java'daki eksik alanlarla birlikte
-- Otobüs Seferleri
INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Firma_ID, Sefer_Tarihi, Sefer_Saati, Varis_Saati, Tahmini_Sure, Bilet_Fiyati) VALUES
(1, 1, 1, '2025-12-25', '10:00:00', '16:00:00', '6 Saat', 600.00), -- İst-Ank Kamil Koç
(2, 3, 2, '2025-12-25', '22:00:00', '06:00:00', '8 Saat', 700.00); -- İst-İzm Pamukkale

-- Uçak Seferleri (Filtrede "Uçak" çıkması için)
INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Firma_ID, Sefer_Tarihi, Sefer_Saati, Varis_Saati, Tahmini_Sure, Bilet_Fiyati) VALUES
(6, 5, 4, '2025-12-25', '09:00:00', '10:30:00', '1s 30dk', 1800.00), -- İst-Trabzon THY
(2, 6, 4, '2025-12-26', '14:00:00', '15:00:00', '1 Saat', 1500.00); -- İst-İzm THY

-- Vapur Seferleri (Filtrede "Vapur" çıkması için)
INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Firma_ID, Sefer_Tarihi, Sefer_Saati, Varis_Saati, Tahmini_Sure, Bilet_Fiyati) VALUES
(3, 8, 7, '2025-12-25', '07:30:00', '09:00:00', '1.5 Saat', 250.00); -- İst-Bursa İDO

-- 8. KULLANICILAR VE ROLLER
INSERT INTO Rol (Rol_Adi) VALUES ('ADMIN'), ('FIRMA_YONETICISI'), ('KULLANICI');

INSERT INTO Kullanici (Isim, Soyisim, Dogum_Tarihi, Adres, Eposta, Parola) VALUES
('Mert', 'Pepele', '1999-01-01', 'İstanbul', 'mert@gmail.com', '12345'),
('Zeynep', 'Yılmaz', '1995-05-05', 'Ankara', 'zeynep@gmail.com', '12345');

INSERT INTO Kullanici_Rol (Kullanici_ID, Rol_ID) VALUES (1, 3), (2, 3);

-- 9. ÖRNEK REZERVASYON (Dolu koltuk göstermek için)
-- Mert, Kamil Koç (Arac 1) 1 numaralı koltuğu aldı.
INSERT INTO Rezervasyon (Firma_ID, Koltuk_ID, Kullanici_ID, Rota_ID, Arac_ID, Fiyat, Durum)
VALUES (1, 1, 1, 1, 1, 600.00, 'Biletlendi');

-- 10. ÖDEME VE FATURA
INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
VALUES (1, 'Kredi Kartı', 'Tamamlandı', 'TRY', 600.00);

INSERT INTO Fatura (Odeme_ID, Tarih, Tutar)
VALUES (1, '2025-12-20', 600.00);

-- 11. BİLET OLUŞTURMA
INSERT INTO Bilet (Rezervasyon_ID, Kullanici_ID, Olusturulma_Tarihi, QR_Kod, Bilet_No)
VALUES (1, 1, '2025-12-20', 'QR_CODE_DATA', 'PNR123456');

-- 12. FAVORİLER (Eksik kolonlar eklenmiş haliyle)
INSERT INTO Favori (Kullanici_ID, Favori_Tipi, Eklenme_Tarihi, Firma_ID, Rota_ID, Arac_ID)
VALUES (1, 'Sefer', '2025-12-20', 1, 1, 1);

-- 13. RAPORLAR
INSERT INTO Rapor (Firma_ID, Rapor_Tipi, Rapor_Veri, Tarih) VALUES
(1, 'Aylık Satış Raporu', 'Toplam satış: 2500 bilet', '2025-10-01'),
(2, 'Yıllık Finans Raporu', 'Toplam gelir: 5.000.000₺', '2025-07-08');

-- 14. İPTAL POLİTİKASI
INSERT INTO Iptal_Politikasi (Politika, Fiyat, Durum, Arac_ID)
VALUES ('Son 24 saat %50 kesinti', 50.00, 'Aktif', 1);

-- 15. EK HİZMETLER
INSERT INTO Ek_Hizmet (Ad, Fiyat, Aciklama) VALUES 
('Ekstra Bagaj', 100.00, '20KG Ekstra'),
('VIP Lounge', 300.00, 'Özel Bekleme Salonu');








