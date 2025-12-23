-- ==========================================
-- 1. TEMİZLİK VE ŞEMA HAZIRLIĞI
-- ==========================================
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ==========================================
-- 2. TABLO OLUŞTURMA (DDL)
-- ==========================================

-- --- BAĞIMSIZ TABLOLAR ---
CREATE TABLE Konum (
    Konum_ID SERIAL PRIMARY KEY,
    Sehir VARCHAR(100) NOT NULL,
    Sehir_Kodu INT
);

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
    Arac_Tipi VARCHAR(50) -- 'Otobüs', 'Uçak', 'Vapur'
);

CREATE TABLE Rol (
    Rol_ID SERIAL PRIMARY KEY,
    Rol_Adi VARCHAR(50) UNIQUE NOT NULL
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

CREATE TABLE Ek_Hizmet (
    Ek_Hizmet_ID SERIAL PRIMARY KEY,
    Ad VARCHAR(100),
    Fiyat NUMERIC(10,2),
    Aciklama TEXT
);

CREATE TABLE Indirim (
    Indirim_ID SERIAL PRIMARY KEY,
    Kod VARCHAR(50),
    Indirim_Degeri NUMERIC(5,2),
    Durum VARCHAR(50),
    Kullanim_Hakki VARCHAR(50),
    Indirim_Araligi VARCHAR(50)
);

-- --- BAĞIMLI TABLOLAR (SEVİYE 1) ---

CREATE TABLE Arac (
    Arac_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID) ON UPDATE CASCADE ON DELETE SET NULL,
    Arac_Tipi VARCHAR(100),
    Arac_No VARCHAR(50),
    Kapasite INT,
    Koltuk_Duzeni VARCHAR(100),
    Ulasim_Turu_ID INT REFERENCES Ulasim_Turu(Ulasim_Turu_ID)
);

CREATE TABLE Koltuk (
    Koltuk_ID SERIAL PRIMARY KEY,
    Arac_ID INT REFERENCES Arac(Arac_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    Koltuk_Turu VARCHAR(50),
    Durum VARCHAR(50) DEFAULT 'Aktif', 
    Koltuk_No VARCHAR(20)
);

CREATE TABLE Rota (
    Rota_ID SERIAL PRIMARY KEY,
    Kalkis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Varis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Km NUMERIC(8,2)
);

CREATE TABLE Kampanya (
    Kampanya_ID SERIAL PRIMARY KEY,
    Ad VARCHAR(100),
    Indirim_Orani NUMERIC(5,2),
    Baslangic DATE,
    Bitis DATE,
    Firma_ID INT REFERENCES Firma(Firma_ID)
);

CREATE TABLE Rapor (
    Rapor_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    Rapor_Tipi VARCHAR(100),
    Rapor_Veri TEXT,
    Tarih DATE
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

CREATE TABLE Yolcu (
    Yolcu_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Yasi INT,
    Cinsiyet VARCHAR(10)
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

-- --- BAĞIMLI TABLOLAR (SEVİYE 2 - Rota Planı ve Rezervasyon) ---

CREATE TABLE Rota_Plan (
    Rota_Plan_ID SERIAL PRIMARY KEY,
    Rota_ID INT REFERENCES Rota(Rota_ID),
    Arac_ID INT REFERENCES Arac(Arac_ID),
    Sefer_Tarihi DATE,
    Sefer_Saati TIME,
    Varis_Saati TIME,
    Tahmini_Sure VARCHAR(50),
    Bilet_Fiyati NUMERIC(10,2)
);

CREATE TABLE Rezervasyon (
    Rezervasyon_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Rota_Plan_ID INT REFERENCES Rota_Plan(Rota_Plan_ID),
    Koltuk_ID INT REFERENCES Koltuk(Koltuk_ID),
    Fiyat NUMERIC(10,2),
    Durum VARCHAR(50) -- 'Beklemede', 'Tamamlandı', 'İptal'
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

CREATE TABLE Bilet (
    Bilet_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Olusturulma_Tarihi DATE,
    QR_Kod VARCHAR(255),
    Bilet_No VARCHAR(50)
);

CREATE TABLE Bilet_Indirim (
    Bilet_ID INT REFERENCES Bilet(Bilet_ID),
    Indirim_ID INT REFERENCES Indirim(Indirim_ID),
    PRIMARY KEY (Bilet_ID, Indirim_ID)
);

CREATE TABLE Rezervasyon_Ek_Hizmet (
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
    Ek_Hizmet_ID INT REFERENCES Ek_Hizmet(Ek_Hizmet_ID),
    PRIMARY KEY (Rezervasyon_ID, Ek_Hizmet_ID)
);

CREATE TABLE Favori (
    Favori_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Favori_Tipi VARCHAR(100),
    Eklenme_Tarihi DATE,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    Rota_ID INT REFERENCES Rota(Rota_ID),
    Arac_ID INT REFERENCES Arac(Arac_ID)
);

-- ==========================================
-- 3. FONKSİYONLAR VE TRIGGERLAR
-- ==========================================

-- [TRIGGER 1] Çifte Rezervasyon Kontrolü (Double Booking Check)
CREATE OR REPLACE FUNCTION trg_cifte_rezervasyon_kontrol()
RETURNS TRIGGER AS $$
BEGIN
    -- Eğer aynı sefer ve aynı koltuk için iptal edilmemiş bir kayıt varsa hata ver
    IF EXISTS (
        SELECT 1 FROM Rezervasyon 
        WHERE Rota_Plan_ID = NEW.Rota_Plan_ID 
          AND Koltuk_ID = NEW.Koltuk_ID 
          AND Durum != 'İptal'
    ) THEN
        RAISE EXCEPTION 'HATA: % Numaralı koltuk bu sefer için zaten dolu!', NEW.Koltuk_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_double_booking
BEFORE INSERT ON Rezervasyon
FOR EACH ROW
EXECUTE FUNCTION trg_cifte_rezervasyon_kontrol();

-- [TRIGGER 2] Koltuk ve Araç Uyuşmazlık Kontrolü
-- Mantık: Seçilen koltuk, o seferi yapan araca ait olmalıdır.
CREATE OR REPLACE FUNCTION trg_koltuk_arac_uyumu()
RETURNS TRIGGER AS $$
DECLARE
    v_sefer_arac_id INT;
    v_koltuk_arac_id INT;
BEGIN
    SELECT Arac_ID INTO v_sefer_arac_id FROM Rota_Plan WHERE Rota_Plan_ID = NEW.Rota_Plan_ID;
    SELECT Arac_ID INTO v_koltuk_arac_id FROM Koltuk WHERE Koltuk_ID = NEW.Koltuk_ID;

    IF v_sefer_arac_id != v_koltuk_arac_id THEN
        RAISE EXCEPTION 'HATA: Seçilen koltuk (ID: %) bu sefere atanan araca (ID: %) ait değil!', NEW.Koltuk_ID, v_sefer_arac_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_seat_vehicle
BEFORE INSERT ON Rezervasyon
FOR EACH ROW
EXECUTE FUNCTION trg_koltuk_arac_uyumu();

-- [TRIGGER 3] İptal ve İade Hesaplama
CREATE OR REPLACE FUNCTION rezervasyon_iptal_sonrasi()
RETURNS TRIGGER AS $$
DECLARE
    v_oran NUMERIC(5,2) := 0;
    v_iade NUMERIC(10,2) := 0;
    v_odeme_id INT;
    v_odeme_tutar NUMERIC(10,2);
    v_arac_id INT;
BEGIN
    SELECT odeme_id, fiyat INTO v_odeme_id, v_odeme_tutar
    FROM odeme WHERE rezervasyon_id = NEW.rezervasyon_id LIMIT 1;

    -- BCNF uyumlu: Arac ID'yi Rota Plan'dan çekiyoruz
    SELECT rp.Arac_ID INTO v_arac_id
    FROM Rota_Plan rp
    WHERE rp.Rota_Plan_ID = NEW.Rota_Plan_ID;

    IF v_odeme_id IS NOT NULL THEN
        -- İptal politikası yoksa %10 varsayılan kesinti
        SELECT COALESCE(ip.fiyat, 10) INTO v_oran
        FROM iptal_politikasi ip
        WHERE ip.arac_id = v_arac_id LIMIT 1;

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

-- [FONKSİYON 1] Rota Arama (JOIN'li Detaylı Sorgu)
CREATE OR REPLACE FUNCTION fn_rota_bul(p_kalkis_sehir VARCHAR, p_varis_sehir VARCHAR)
RETURNS TABLE (
    Firma VARCHAR,
    Arac_Tipi VARCHAR,  
    Kalkis VARCHAR,
    Varis VARCHAR,
    Mesafe_KM NUMERIC,
    Sefer_Tarihi DATE,
    Sefer_Saati TIME,
    Fiyat NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.Firma_Adi,
        a.Arac_Tipi::VARCHAR, 
        k1.Sehir,
        k2.Sehir,
        r.Km,
        rp.Sefer_Tarihi,
        rp.Sefer_Saati,
        rp.Bilet_Fiyati
    FROM Rota r
    JOIN Konum k1 ON r.Kalkis_Konum_ID = k1.Konum_ID
    JOIN Konum k2 ON r.Varis_Konum_ID = k2.Konum_ID
    JOIN Rota_Plan rp ON r.Rota_ID = rp.Rota_ID
    JOIN Arac a ON rp.Arac_ID = a.Arac_ID
    JOIN Firma f ON a.Firma_ID = f.Firma_ID
    WHERE k1.Sehir ILIKE p_kalkis_sehir AND k2.Sehir ILIKE p_varis_sehir;
END;
$$ LANGUAGE plpgsql;

-- [FONKSİYON 2] Doluluk Oranı Hesaplama
CREATE OR REPLACE FUNCTION fn_sefer_doluluk_orani(p_rota_plan_id INT)
RETURNS TABLE (
    Sefer_ID INT,
    Toplam_Kapasite INT,
    Dolu_Koltuk INT,
    Doluluk_Yuzdesi NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rp.Rota_Plan_ID,
        a.Kapasite,
        (SELECT COUNT(*)::INT FROM Rezervasyon r WHERE r.Rota_Plan_ID = rp.Rota_Plan_ID AND r.Durum != 'İptal'),
        ROUND(
            ((SELECT COUNT(*) FROM Rezervasyon r WHERE r.Rota_Plan_ID = rp.Rota_Plan_ID AND r.Durum != 'İptal')::NUMERIC 
            / NULLIF(a.Kapasite, 0)::NUMERIC) * 100, 2
        )
    FROM Rota_Plan rp
    JOIN Arac a ON rp.Arac_ID = a.Arac_ID
    WHERE rp.Rota_Plan_ID = p_rota_plan_id;
END;
$$ LANGUAGE plpgsql;

-- [PROCEDURE] Bilet Satış Prosedürü (Transaction Yönetimi)
-- Bu prosedür hem rezervasyonu hem de ödemeyi tek seferde yapar.
CREATE OR REPLACE PROCEDURE sp_bilet_satis(
    p_kullanici_id INT,
    p_rota_plan_id INT,
    p_koltuk_id INT,
    p_odeme_metodu VARCHAR,
    p_tutar NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rezervasyon_id INT;
BEGIN
    -- 1. Rezervasyon Kaydı Oluştur
    INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum)
    VALUES (p_kullanici_id, p_rota_plan_id, p_koltuk_id, p_tutar, 'Tamamlandı')
    RETURNING Rezervasyon_ID INTO v_rezervasyon_id;

    -- 2. Ödeme Kaydı Oluştur
    INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
    VALUES (v_rezervasyon_id, p_odeme_metodu, 'Tamamlandı', 'TRY', p_tutar);

    -- 3. Opsiyonel: Bilet Oluştur
    INSERT INTO Bilet (Rezervasyon_ID, Kullanici_ID, Olusturulma_Tarihi, Bilet_No)
    VALUES (v_rezervasyon_id, p_kullanici_id, CURRENT_DATE, CONCAT('PNR-', v_rezervasyon_id));
    
    RAISE NOTICE 'Bilet satışı başarılı! Rezervasyon ID: %', v_rezervasyon_id;
END;
$$;

-- ==========================================
-- 4. VERİ EKLEME (INSERT DATA)
-- ==========================================

-- A) GENİŞLETİLMİŞ KONUM LİSTESİ
INSERT INTO Konum (Sehir, Sehir_Kodu) VALUES 
('İstanbul', 34), ('Ankara', 6), ('İzmir', 35), ('Antalya', 7), ('Bursa', 16), 
('Muğla', 48), ('Trabzon', 61), ('Adana', 1), ('Gaziantep', 27), ('Konya', 42), 
('Kayseri', 38), ('Eskişehir', 26), ('Diyarbakır', 21), ('Mersin', 33), ('Samsun', 55),
('Denizli', 20), ('Şanlıurfa', 63), ('Sakarya', 54), ('Kocaeli', 41), ('Manisa', 45), 
('Hatay', 31), ('Balıkesir', 10), ('Van', 65), ('Aydın', 9), ('Tekirdağ', 59), 
('Erzurum', 25), ('Sivas', 58), ('Malatya', 44), ('Çanakkale', 17), ('Rize', 53);

-- B) FİRMALAR ve TURLAR
INSERT INTO Firma (Firma_Adi, Firma_TelNo, Firma_email) VALUES 
('Kamil Koç', '4440562', 'iletisim@kamilkoc.com'),
('Pamukkale', '08503333535', 'iletisim@pamukkale.com'),
('Metro Turizm', '08502223455', 'iletisim@metro.com'),
('Türk Hava Yolları', '4440849', 'contact@thy.com'),
('Pegasus', '08882281212', 'contact@flypgs.com'),
('SunExpress', '4440797', 'info@sunexpress.com'),
('İDO', '08502224436', 'info@ido.com.tr'),
('BUDO', '4449916', 'info@burulas.com.tr');

INSERT INTO Ulasim_Turu (Aciklama, Koltuk_Tipi, Arac_Tipi) VALUES 
('Karayolu Seyahati', 'Standart', 'Otobüs'),
('Havayolu Seyahati', 'Ekonomi', 'Uçak'),
('Denizyolu Seyahati', 'Salon', 'Vapur');

-- C) ARAÇLAR (ID'ler Önemli!)
INSERT INTO Arac (Firma_ID, Arac_Tipi, Arac_No, Kapasite, Koltuk_Duzeni, Ulasim_Turu_ID) VALUES 
(1, 'Otobüs', '34KMK01', 40, '2+1', 1), -- ID: 1
(1, 'Otobüs', '06ANK02', 46, '2+2', 1), -- ID: 2
(2, 'Otobüs', '35PMK01', 40, '2+1', 1), -- ID: 3
(3, 'Otobüs', '34MTR01', 50, '2+2', 1), -- ID: 4
(4, 'Uçak', 'TC-JFK', 180, '3+3', 2),    -- ID: 5
(4, 'Uçak', 'TC-IST', 180, '3+3', 2),    -- ID: 6
(5, 'Uçak', 'TC-PGS', 189, '3+3', 2),    -- ID: 7
(7, 'Vapur', 'IDO-1', 400, 'Genel', 3),  -- ID: 8
(8, 'Vapur', 'BUDO-1', 350, 'Genel', 3); -- ID: 9

-- D) KOLTUKLAR (Araçlara göre düzenli ID'ler)
-- Arac 1: ID 1-40
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 1, 'Tekli', generate_series(1,40)::text;
-- Arac 2: ID 41-86
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 2, 'Çiftli', generate_series(1,46)::text; 
-- Arac 3: ID 87-126
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 3, 'Tekli', generate_series(1,40)::text;
-- Arac 5: ID 127-226 (Uçak örnek 100 koltuk)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 5, 'Ekonomi', generate_series(1,100)::text;
-- Arac 8: ID 227-326 (Vapur örnek 100 koltuk)
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 8, 'Salon', generate_series(1,100)::text;

-- E) ROTALAR (Şehir ID'lerine göre - Konum tablosundaki sıraya bağlı)
INSERT INTO Rota (Kalkis_Konum_ID, Varis_Konum_ID, Km) VALUES 
(1, 2, 450.00), -- İst -> Ank (Rota 1)
(1, 3, 480.00), -- İst -> İzm (Rota 2)
(1, 5, 150.00), -- İst -> Bursa (Rota 3)
(2, 4, 500.00), -- Ank -> Ant (Rota 4)
(3, 1, 480.00), -- İzm -> İst (Rota 5)
(1, 7, 1000.00), -- İst -> Trabzon (Rota 6)
(2, 1, 450.00), -- Ank -> İst (Rota 7)
(3, 2, 580.00), -- İzm -> Ank (Rota 8)
(4, 1, 700.00), -- Ant -> İst (Rota 9)
(5, 1, 150.00); -- Bursa -> İst (Rota 10)

-- F) ROTA PLANLARI (Seferler)
INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Sefer_Tarihi, Sefer_Saati, Varis_Saati, Tahmini_Sure, Bilet_Fiyati) VALUES
(1, 1, '2025-12-25', '10:00:00', '16:00:00', '6 Saat', 600.00),   -- Plan 1: Arac 1
(2, 3, '2025-12-25', '22:00:00', '06:00:00', '8 Saat', 700.00),   -- Plan 2: Arac 3
(6, 5, '2025-12-25', '09:00:00', '10:30:00', '1s 30dk', 1800.00), -- Plan 3: Arac 5 (Uçak)
(2, 6, '2025-12-26', '14:00:00', '15:00:00', '1 Saat', 1500.00),  -- Plan 4: Arac 6
(3, 8, '2025-12-25', '07:30:00', '09:00:00', '1.5 Saat', 250.00), -- Plan 5: Arac 8
(7, 1, '2025-12-26', '08:00:00', '14:00:00', '6 Saat', 550.00),   -- Plan 6: Arac 1
(7, 1, '2025-12-26', '14:00:00', '20:00:00', '6 Saat', 650.00),   -- Plan 7: Arac 1
(7, 2, '2025-12-27', '23:00:00', '05:00:00', '6 Saat', 500.00);   -- Plan 8: Arac 2

-- G) ROLLER ve KULLANICILAR (Sabit ID'ler ile)
INSERT INTO Rol (Rol_Adi) VALUES ('ADMIN'), ('FIRMA_YONETICISI'), ('KULLANICI');

-- ID'leri manuel veriyoruz ki rezervasyonda hata çıkmasın.
INSERT INTO Kullanici (Kullanici_ID, Isim, Soyisim, Dogum_Tarihi, Adres, Eposta, Parola) VALUES
(1, 'Mert', 'Pepele', '1999-01-01', 'İstanbul', 'mert@gmail.com', '12345'),
(2, 'Zeynep', 'Yılmaz', '1995-05-05', 'Ankara', 'zeynep@gmail.com', '12345'),
(3, 'Ayşe', 'Demir', '2001-02-14', 'İzmir', 'ayse.demir@gopass.com', '123'),
(4, 'Can', 'Kaya', '1987-11-22', 'Bursa', 'can.kaya@gopass.com', '123'),
(5, 'Elif', 'Arslan', '1996-06-05', 'Antalya', 'elif.arslan@gopass.com', '123'),
(6, 'Burak', 'Koç', '2000-01-18', 'Trabzon', 'burak.koc@gopass.com', '123'),
(7, 'Sena', 'Öztürk', '1994-09-30', 'Muğla', 'sena.ozturk@gopass.com', '123');

-- ID sayacını düzeltme (Sonraki kayıtlar çakışmasın)
PERFORM setval('kullanici_kullanici_id_seq', (SELECT MAX(kullanici_id) FROM kullanici));

INSERT INTO Kullanici_Rol (Kullanici_ID, Rol_ID) VALUES (1, 3), (2, 3);
INSERT INTO Yolcu (Kullanici_ID, Yasi, Cinsiyet) VALUES (1, 25, 'Erkek'), (1, 6, 'Çocuk'), (2, 29, 'Kadın');

INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum)
VALUES (1, 1, 1, 600.00, 'Biletlendi');

INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum)
VALUES (2, 6, 15, 600.00, 'Beklemede');

INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum)
VALUES (3, 6, 16, 600.00, 'Tamamlandı');

INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum)
VALUES (4, 3, 130, 1800.00, 'İptal');

-- I) ÖDEMELER
INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
VALUES 
(1, 'Kredi Kartı', 'Tamamlandı', 'TRY', 600.00),
(3, 'Kredi Kartı', 'Tamamlandı', 'TRY', 600.00),
(4, 'Kredi Kartı', 'Tamamlandı', 'TRY', 1800.00);

-- J) DİĞER
INSERT INTO Iptal_Politikasi (Politika, Fiyat, Durum, Arac_ID) VALUES ('Son 24 saat %50 kesinti', 50.00, 'Aktif', 1);
INSERT INTO Ek_Hizmet (Ad, Fiyat, Aciklama) VALUES ('Ekstra Bagaj', 100.00, '20KG Ekstra');

-- K) PROCEDURE TESTİ (Yeni bir satış yapalım)
CALL sp_bilet_satis(6, 1, 2, 'Kredi Kartı', 600.00);
