DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

CREATE TABLE Firma (
    Firma_ID SERIAL PRIMARY KEY,
    Firma_Adi VARCHAR(150),
    Firma_TelNo VARCHAR(20),
    Firma_email VARCHAR(150),
    Islem_Durumu VARCHAR(50) DEFAULT 'Aktif'
);

CREATE TABLE Ulasim_Turu (
    Ulasim_Turu_ID SERIAL PRIMARY KEY,
    Aciklama TEXT,
    Koltuk_Tipi VARCHAR(50),
    Arac_Tipi VARCHAR(50)
);

CREATE TABLE Arac (
    Arac_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    Arac_No VARCHAR(50),
    Kapasite INT,
    Koltuk_Duzeni VARCHAR(100),
    Ulasim_Turu_ID INT REFERENCES Ulasim_Turu(Ulasim_Turu_ID)
);

CREATE TABLE Koltuk (
    Koltuk_ID SERIAL PRIMARY KEY,
    Arac_ID INT REFERENCES Arac(Arac_ID) ON DELETE CASCADE,
    Koltuk_Turu VARCHAR(50),
    Durum VARCHAR(50) DEFAULT 'Boş',
    Koltuk_No VARCHAR(20)
);

CREATE TABLE Konum (
    Konum_ID SERIAL PRIMARY KEY,
    Sehir VARCHAR(100),
    Sehir_Kodu INT
);

CREATE TABLE Rota (
    Rota_ID SERIAL PRIMARY KEY,
    Kalkis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Varis_Konum_ID INT REFERENCES Konum(Konum_ID),
    Km NUMERIC(8,2)
);

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

CREATE TABLE Kullanici (
    Kullanici_ID SERIAL PRIMARY KEY,
    Isim VARCHAR(100),
    Soyisim VARCHAR(100),
    Eposta VARCHAR(150),
    Parola VARCHAR(100)
);

CREATE TABLE Yolcu (
    Yolcu_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Yasi INT,
    Cinsiyet VARCHAR(10)
);

CREATE TABLE Rezervasyon (
    Rezervasyon_ID SERIAL PRIMARY KEY,
    Koltuk_ID INT REFERENCES Koltuk(Koltuk_ID),
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Rota_Plan_ID INT REFERENCES Rota_Plan(Rota_Plan_ID),
    Fiyat NUMERIC(10,2),
    Durum VARCHAR(50)
);

CREATE TABLE Odeme (
    Odeme_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
    Odeme_Metodu VARCHAR(50),
    Odeme_Durumu VARCHAR(50),
    Para_Birimi VARCHAR(20),
    Fiyat NUMERIC(10,2),
    Iade_Tutari NUMERIC(10,2) DEFAULT 0
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
    Gosterim_Durumu VARCHAR(50),
    Tur VARCHAR(50)
);

CREATE TABLE Iptal_Politikasi (
    Iptal_Politikasi_ID SERIAL PRIMARY KEY,
    Politika TEXT,
    Fiyat NUMERIC(5,2),
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

CREATE TABLE Bilet (
    Bilet_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT REFERENCES Rezervasyon(Rezervasyon_ID),
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



CREATE TABLE Favori (
    Favori_id SERIAL PRIMARY KEY,
    Kullanici_id INTEGER NOT NULL,
    Rota_id INTEGER NOT NULL,
    firma_id INTEGER NOT NULL, 
    Eklenme_tarihi DATE NOT NULL,


    CONSTRAINT uq_favori UNIQUE (Kullanici_id, Rota_id, Firma_id),

    CONSTRAINT fk_favori_kullanici
        FOREIGN KEY (Kullanici_id)
        REFERENCES Kullanici(Kullanici_id),

    CONSTRAINT fk_favori_rota
        FOREIGN KEY (Rota_id)
        REFERENCES Rota(Rota_id),
        
    CONSTRAINT fk_favori_firma
        FOREIGN KEY (Firma_id)
        REFERENCES Firma(Firma_ID)
);



CREATE TABLE Rol (
    Rol_ID SERIAL PRIMARY KEY,
    Rol_Adi VARCHAR(50)
);

CREATE TABLE Kullanici_Rol (
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Rol_ID INT REFERENCES Rol(Rol_ID),
    PRIMARY KEY (Kullanici_ID, Rol_ID)
);

CREATE TABLE Firma_Yonetici (
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
    Firma_ID INT REFERENCES Firma(Firma_ID),
    PRIMARY KEY (Kullanici_ID, Firma_ID)
);

CREATE TABLE Rapor (
    Rapor_ID SERIAL PRIMARY KEY,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    Rapor_Tipi VARCHAR(100),
    Rapor_Veri TEXT,
    Tarih DATE
);



-- Çifte rezervasyon kontrolü
CREATE OR REPLACE FUNCTION trg_cifte_rez()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Rezervasyon
        WHERE Rota_Plan_ID = NEW.Rota_Plan_ID
          AND Koltuk_ID = NEW.Koltuk_ID
          AND Durum <> 'İptal'
    ) THEN
        RAISE EXCEPTION 'Bu koltuk dolu!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_double_booking
BEFORE INSERT ON Rezervasyon
FOR EACH ROW EXECUTE FUNCTION trg_cifte_rez();


-- Koltuk durumunu güncelleme
CREATE OR REPLACE FUNCTION trg_koltuk_durum()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.Durum IN ('Tamamlandı','Biletlendi') THEN
        UPDATE Koltuk SET Durum='Dolu' WHERE Koltuk_ID=NEW.Koltuk_ID;

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.Durum IN ('Tamamlandı','Biletlendi') THEN
            UPDATE Koltuk SET Durum='Dolu' WHERE Koltuk_ID=NEW.Koltuk_ID;
        ELSIF NEW.Durum='İptal' THEN
            UPDATE Koltuk SET Durum='Boş' WHERE Koltuk_ID=OLD.Koltuk_ID;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_seat_state
AFTER INSERT OR UPDATE ON Rezervasyon
FOR EACH ROW EXECUTE FUNCTION trg_koltuk_durum();


-- İptal ve İade İşlemleri
CREATE OR REPLACE FUNCTION trg_iade()
RETURNS TRIGGER AS $$
DECLARE
    kesinti NUMERIC := 10;
    iade NUMERIC;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.Durum='İptal' AND OLD.Durum <> 'İptal' THEN
        -- İptal politikasını bul
        SELECT COALESCE(Fiyat,10) INTO kesinti
        FROM Iptal_Politikasi
        WHERE Arac_ID = (
            SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID=NEW.Rota_Plan_ID
        )
        LIMIT 1;

        iade := NEW.Fiyat * (1 - kesinti/100);

        UPDATE Odeme
        SET Odeme_Durumu='İade Edildi',
            Iade_Tutari=iade
        WHERE Rezervasyon_ID=NEW.Rezervasyon_ID;

        INSERT INTO Bildirim (Kullanici_ID,Mesaj,Tur)
        VALUES (NEW.Kullanici_ID, CONCAT('İade: ',iade,' TL'),'İptal');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cancel
AFTER UPDATE OF Durum ON Rezervasyon
FOR EACH ROW EXECUTE FUNCTION trg_iade();



-- Bilet satış prosedürü
CREATE OR REPLACE PROCEDURE sp_bilet_satis(
    p_kullanici INT,
    p_plan INT,
    p_koltuk INT,
    p_fiyat NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    rid INT;
    v_odeme_id INT;  
BEGIN
    INSERT INTO Rezervasyon
        (Koltuk_ID, Kullanici_ID, Rota_Plan_ID, Fiyat, Durum)
    VALUES
        (p_koltuk, p_kullanici, p_plan, p_fiyat, 'Biletlendi')
    RETURNING Rezervasyon_ID INTO rid;

    INSERT INTO Odeme
        (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
    VALUES
        (rid, 'Kredi Kartı', 'Tamamlandı', 'TRY', p_fiyat)
    RETURNING Odeme_ID INTO v_odeme_id;

    INSERT INTO Fatura
        (Odeme_ID, Tarih, Tutar)
    VALUES
        (v_odeme_id, CURRENT_DATE, p_fiyat);
END;
$$;



-- KONUM
INSERT INTO Konum (Sehir, Sehir_Kodu) VALUES
('İstanbul',34),('Ankara',6),('İzmir',35),('Antalya',7),('Bursa',16),
('Muğla',48),('Trabzon',61),('Adana',1),('Gaziantep',27),('Konya',42),
('Kayseri',38),('Eskişehir',26),('Diyarbakır',21),('Mersin',33),('Samsun',55),
('Denizli',20),('Şanlıurfa',63),('Sakarya',54),('Kocaeli',41),('Manisa',45),
('Hatay',31),('Balıkesir',10),('Van',65),('Aydın',9),('Tekirdağ',59),
('Erzurum',25),('Sivas',58),('Malatya',44),('Çanakkale',17),('Rize',53),
('Mardin',47),('Ordu',52),('Afyonkarahisar',3),('Kars',36),('Nevşehir',50);


-- FIRMA
INSERT INTO Firma (Firma_Adi, Firma_TelNo, Firma_email) VALUES
('Kamil Koç','4440562','iletisim@kamilkoc.com'),
('Pamukkale','08503333535','iletisim@pamukkale.com'),
('Metro Turizm','08502223455','iletisim@metro.com'),
('Türk Hava Yolları','4440849','contact@thy.com'),
('Pegasus','08882281212','contact@flypgs.com'),
('SunExpress','4440797','info@sunexpress.com'),
('İDO','08502224436','info@ido.com.tr'),
('BUDO','4449916','info@burulas.com.tr'),
('Varan Turizm','08502551515','iletisim@varan.com.tr'),
('AJet','08503332538','destek@ajet.com');


-- ULAŞIM TURU
INSERT INTO Ulasim_Turu (Aciklama, Koltuk_Tipi, Arac_Tipi) VALUES
('Karayolu Seyahati','Standart (2+2)','Otobüs'),
('Karayolu Seyahati','Suite (2+1)','Otobüs'),
('Havayolu Seyahati','Ekonomi','Uçak'),
('Havayolu Seyahati','Business','Uçak'),
('Denizyolu Seyahati','Salon','Vapur'),
('Denizyolu Seyahati','Güverte','Vapur');


-- ARAC 
INSERT INTO Arac (Firma_ID, Arac_No, Kapasite, Koltuk_Duzeni, Ulasim_Turu_ID) VALUES
(1,'34KMK01',40,'2+1',2),
(1,'06ANK02',46,'2+2',1),
(2,'35PMK01',40,'2+1',2),
(3,'34MTR01',50,'2+2',1),
(4,'TC-JFK',180,'3+3',3),
(4,'TC-IST',180,'3+3',3),
(4,'TC-GLB',300,'2+4+2',3),
(5,'TC-PGS',189,'3+3',3),
(7,'IDO-1',400,'Genel',5),
(8,'BUDO-1',350,'Genel',5);


-- KOLTUK
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 1,'Tekli',generate_series(1,40)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 2,'Çiftli',generate_series(1,46)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 3,'Tekli',generate_series(1,40)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 4,'Çiftli',generate_series(1,50)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 5,'Ekonomi',generate_series(1,180)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 6,'Ekonomi',generate_series(1,180)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 7,'Ekonomi',generate_series(1,300)::text;
INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No) SELECT 8,'Ekonomi',generate_series(1,189)::text;


-- ROTA
INSERT INTO Rota (Kalkis_Konum_ID, Varis_Konum_ID, Km) VALUES
(1,2,450),(1,3,480),(1,5,150),(2,4,500),(3,1,480),
(1,7,1000),(2,1,450),(3,2,580),(4,1,700),(5,1,150);


-- ROTA PLAN
INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Sefer_Tarihi, Sefer_Saati, Varis_Saati, Tahmini_Sure, Bilet_Fiyati) VALUES
(1,1,'2025-12-25','10:00','16:00','6 Saat',600),
(2,3,'2025-12-25','22:00','06:00','8 Saat',700),
(6,5,'2025-12-25','09:00','10:30','1s 30dk',1800),
(2,6,'2025-12-26','14:00','15:00','1 Saat',1500),
(3,1,'2025-12-25','07:30','09:00','1.5 Saat',250), 
(7,1,'2025-12-26','08:00','14:00','6 Saat',550),
(7,1,'2025-12-26','14:00','20:00','6 Saat',650),
(7,2,'2025-12-27','23:00','05:00','6 Saat',500);


-- ROL
INSERT INTO Rol (Rol_Adi) VALUES
('ADMIN'),
('FIRMA_YONETICISI'),
('KULLANICI');


-- KULLANICI
INSERT INTO Kullanici (Isim, Soyisim, Eposta, Parola) VALUES
('Mert','Pepele','mert@gmail.com','12345'),
('Zeynep','Yılmaz','zeynep@gmail.com','12345'),
('Ayşe','Demir','ayse.demir@gopass.com','123'),
('Can','Kaya','can.kaya@gopass.com','123'),
('Elif','Arslan','elif.arslan@gopass.com','123'),
('Burak','Koç','burak.koc@gopass.com','123'),
('Sena','Öztürk','sena.ozturk@gopass.com','123');


-- KULLANICI_ROL
INSERT INTO Kullanici_Rol VALUES
(1,3),(2,3),(3,3),
(5,3),(6,3),(7,3),(4,2);


-- FIRMA_YONETICI
INSERT INTO Firma_Yonetici VALUES
(4,1),
(3,4),
(6,3);


-- YOLCU
INSERT INTO Yolcu (Kullanici_ID, Yasi, Cinsiyet) VALUES
(1,25,'Erkek'),
(1,6,'Çocuk'),
(2,29,'Kadın'),
(3,21,'Kadın'),
(4,38,'Erkek'),
(4,35,'Kadın'),
(5,68,'Erkek'),
(6,26,'Erkek'),
(6,1,'Bebek'),
(7,30,'Kadın');


-- REZERVASYON
INSERT INTO Rezervasyon (Kullanici_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum) VALUES
(1,1,1,600,'Biletlendi'),
(5,8,42,500,'Biletlendi'),
(5,8,43,500,'Biletlendi'),
(2,6,15,600,'Beklemede'),
(7,5,150,250,'Beklemede'), 
(6,2,88,700,'Tamamlandı'),
(3,6,16,600,'Tamamlandı'),
(1,1,2,600,'Rezerve'),
(4,3,180,1800,'İptal');


-- BILET
INSERT INTO Bilet (Rezervasyon_ID, Olusturulma_Tarihi, QR_Kod, Bilet_No) VALUES
(1,CURRENT_DATE,'QR_DATA_123','PNR-001'),
(2,CURRENT_DATE,'QR_ELIF_42','PNR-002'),
(3,CURRENT_DATE,'QR_BABA_43','PNR-003'),
(5,CURRENT_DATE,'QR_UCAK_181','PNR-005'),
(6,CURRENT_DATE,'QR_BURAK_88','PNR-006'),
(7,CURRENT_DATE,'QR_DATA_456','PNR-007');


-- ODEME
INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat, Iade_Tutari) VALUES
(1,'Kredi Kartı','Tamamlandı','TRY',600,0),
(2,'Kredi Kartı','Tamamlandı','TRY',500,0),
(3,'Kredi Kartı','Tamamlandı','TRY',500,0),
(4,'Havale','Bekliyor','TRY',600,0),
(5,'Kredi Kartı','Bekliyor','TRY',250,0),
(6,'Havale','Tamamlandı','TRY',700,0),
(7,'Kredi Kartı','Tamamlandı','TRY',600,0),
(8,'Kredi Kartı','İade Edildi','TRY',1800,1620);


-- FAVORI
INSERT INTO Favori (Kullanici_id, Rota_id, Firma_id, Eklenme_tarihi) VALUES
(1, 1, 1, CURRENT_DATE),   
(2, 4, 1, CURRENT_DATE),   
(4, 3, 2, CURRENT_DATE),  
(7, 5, 7, CURRENT_DATE),   
(1, 6, 4, CURRENT_DATE);   


-- BILDIRIM
INSERT INTO Bildirim (Kullanici_ID, Mesaj, Gosterim_Durumu, Tur) VALUES
(1,'Biletiniz başarıyla oluşturuldu','Görülmedi','Bilgi'),
(4,'İptal işleminiz onaylandı','Görüldü','İptal'),
(2,'Kış indirimi başladı','Görülmedi','Kampanya'),
(3,'Seferiniz rötarlı','Görülmedi','Uyarı'),
(7,'Ödeme bekleniyor','Görülmedi','Hatırlatma');


-- RAPOR
INSERT INTO Rapor (Firma_ID, Rapor_Tipi, Rapor_Veri, Tarih) VALUES
(1,'Aylık Satış','150.000 TL',CURRENT_DATE),
(4,'Memnuniyet','4.8 / 5',CURRENT_DATE),
(3,'Şikayet','2 bagaj kaybı',CURRENT_DATE-1);


-- FATURA
INSERT INTO Fatura (Odeme_ID, Tarih, Tutar) VALUES
(1,CURRENT_DATE,600),
(2,CURRENT_DATE,500),
(3,CURRENT_DATE,500),
(6,CURRENT_DATE,700),
(7,CURRENT_DATE,600);


-- INDIRIM
INSERT INTO Indirim (Kod, Indirim_Degeri, Durum, Kullanim_Hakki, Indirim_Araligi) VALUES
('MERHABA10',10,'Aktif','Tek Sefer','2025'),
('OGRENCI25',25,'Aktif','Sınırsız','Eğitim'),
('YAZ2026',15,'Pasif','Tek Sefer','2026');


-- BILET_INDIRIM
INSERT INTO Bilet_Indirim VALUES 
(5,2),
(1,1),  
(3,3);


-- IPTAL POLITIKASI
INSERT INTO Iptal_Politikasi (Politika, Fiyat, Durum, Arac_ID) VALUES
('Son 24 saat %50 kesinti',50,'Aktif',1),
('Uçuştan 12 saat %30 kesinti',30,'Aktif',5),
('1 saat kala %10 kesinti',10,'Aktif',7);


-- EK HIZMET
INSERT INTO Ek_Hizmet (Ad, Fiyat, Aciklama) VALUES
('Seyahat Sigortası',75.50,'Tam kapsamlı koruma'),
('Evcil Hayvan Taşıma',150,'Kabin içi'),
('Ekstra Bagaj',100,'20 KG');


-- KAMPANYA
INSERT INTO Kampanya (Ad, Indirim_Orani, Baslangic, Bitis, Firma_ID) VALUES
('Erken Rezervasyon Fırsatı',15,CURRENT_DATE,'2026-06-01',5),
('Bahar Kampanyası',10,CURRENT_DATE,'2026-05-15',3),
('Kış İndirimi',20,CURRENT_DATE,'2026-03-01',1);


-- PROCEDURE TEST
CALL sp_bilet_satis(6,1,5,600);
CALL sp_bilet_satis(3,4,45,500);
CALL sp_bilet_satis(6,5,180,250);




-- Firma Bazlı Toplam Satış ve Rezervasyon Durumu
SELECT 
    f.Firma_Adi,
    COUNT(r.Rezervasyon_ID) AS Toplam_Rezervasyon,
    SUM(r.Fiyat) AS Toplam_Ciro,
    SUM(CASE WHEN r.Durum = 'Tamamlandı' THEN 1 ELSE 0 END) AS Tamamlanan,
    SUM(CASE WHEN r.Durum = 'İptal' THEN 1 ELSE 0 END) AS Iptal_Edilen
FROM Firma f
JOIN Arac a ON f.Firma_ID = a.Firma_ID
JOIN Rota_Plan rp ON a.Arac_ID = rp.Arac_ID
JOIN Rezervasyon r ON rp.Rota_Plan_ID = r.Rota_Plan_ID
GROUP BY f.Firma_Adi
ORDER BY Toplam_Ciro DESC;


--Sefer Bazlı Koltuk Doluluk Oranı
SELECT 
    rp.Rota_Plan_ID,
    rp.Sefer_Tarihi,
    a.Arac_No,
    COUNT(k.Koltuk_ID) AS Toplam_Koltuk,
    SUM(CASE WHEN k.Durum='Dolu' THEN 1 ELSE 0 END) AS Dolu_Koltuk,
    SUM(CASE WHEN k.Durum='Boş' THEN 1 ELSE 0 END) AS Bos_Koltuk,
    ROUND(SUM(CASE WHEN k.Durum='Dolu' THEN 1 ELSE 0 END)::NUMERIC / COUNT(k.Koltuk_ID) * 100, 2) AS Doluluk_Orani
FROM Rota_Plan rp
JOIN Arac a ON rp.Arac_ID = a.Arac_ID
JOIN Koltuk k ON a.Arac_ID = k.Arac_ID
GROUP BY rp.Rota_Plan_ID, rp.Sefer_Tarihi, a.Arac_No
ORDER BY Doluluk_Orani DESC;


-- İade ve Kesinti Analizi
SELECT 
    r.Rezervasyon_ID,
    k.Isim || ' ' || k.Soyisim AS Yolcu,
    r.Fiyat AS Orijinal_Fiyat,
    o.Iade_Tutari,
    ROUND((r.Fiyat - o.Iade_Tutari)::NUMERIC / r.Fiyat * 100, 2) AS Kesinti_Orani
FROM Rezervasyon r
JOIN Odeme o ON r.Rezervasyon_ID = o.Rezervasyon_ID
JOIN Kullanici k ON r.Kullanici_ID = k.Kullanici_ID
WHERE r.Durum='İptal'
ORDER BY Kesinti_Orani DESC;


-- Kampanya Etkisi ve Kullanımı
SELECT 
    k.Ad AS Kampanya,
    f.Firma_Adi,
    COUNT(b.Bilet_ID) AS Kullanilan_Bilet_Sayisi,
    SUM(r.Fiyat) AS Toplam_Ciro,
    k.Indirim_Orani
FROM Kampanya k
JOIN Firma f ON k.Firma_ID = f.Firma_ID
JOIN Arac a ON f.Firma_ID = a.Firma_ID
JOIN Rota_Plan rp ON a.Arac_ID = rp.Arac_ID
JOIN Rezervasyon r ON rp.Rota_Plan_ID = r.Rota_Plan_ID
JOIN Bilet b ON r.Rezervasyon_ID = b.Rezervasyon_ID
GROUP BY k.Ad, f.Firma_Adi, k.Indirim_Orani
ORDER BY Toplam_Ciro DESC;


-- Araca Göre Ek Hizmet Geliri
SELECT 
    a.Arac_No,
    COUNT(reh.Ek_Hizmet_ID) AS Ek_Hizmet_Sayisi,
    SUM(eh.Fiyat) AS Toplam_Ek_Hizmet_Geliri
FROM Arac a
JOIN Rota_Plan rp ON a.Arac_ID = rp.Arac_ID
JOIN Rezervasyon r ON rp.Rota_Plan_ID = r.Rota_Plan_ID
JOIN Rezervasyon_Ek_Hizmet reh ON r.Rezervasyon_ID = reh.Rezervasyon_ID
JOIN Ek_Hizmet eh ON reh.Ek_Hizmet_ID = eh.Ek_Hizmet_ID
GROUP BY a.Arac_No
ORDER BY Toplam_Ek_Hizmet_Geliri DESC;


-- Rota Bazlı Ortalama Bilet Fiyatı ve Doluluk Oranı
WITH Koltuk_Durum AS (
    SELECT 
        rp.Rota_ID,
        COUNT(k.Koltuk_ID) AS Toplam_Koltuk,
        SUM(CASE WHEN k.Durum='Dolu' THEN 1 ELSE 0 END) AS Dolu_Koltuk
    FROM Rota_Plan rp
    JOIN Arac a ON rp.Arac_ID = a.Arac_ID
    JOIN Koltuk k ON a.Arac_ID = k.Arac_ID
    GROUP BY rp.Rota_ID
)
SELECT 
    r.Rota_ID,
    AVG(rp.Bilet_Fiyati) AS Ortalama_Bilet_Fiyati,
    kd.Dolu_Koltuk,
    kd.Toplam_Koltuk,
    ROUND(kd.Dolu_Koltuk::NUMERIC / kd.Toplam_Koltuk * 100, 2) AS Doluluk_Orani
FROM Rota r
JOIN Rota_Plan rp ON r.Rota_ID = rp.Rota_ID
JOIN Koltuk_Durum kd ON r.Rota_ID = kd.Rota_ID
GROUP BY r.Rota_ID, kd.Dolu_Koltuk, kd.Toplam_Koltuk
ORDER BY Doluluk_Orani DESC;


-- En Çok Kazandıran Kullanıcılar ve Ortalama Harcama
WITH Kullanici_Analiz AS (
    SELECT 
        k.Kullanici_ID,
        k.Isim || ' ' || k.Soyisim AS Kullanici,
        COUNT(r.Rezervasyon_ID) AS Rezervasyon_Sayisi,
        SUM(r.Fiyat) AS Toplam_Harcama,
        AVG(r.Fiyat) AS Ortalama_Harcama
    FROM Kullanici k
    JOIN Rezervasyon r ON k.Kullanici_ID = r.Kullanici_ID
    GROUP BY k.Kullanici_ID
)
SELECT *
FROM Kullanici_Analiz
ORDER BY Toplam_Harcama DESC
LIMIT 10;


-- Rota ve Araca Göre Doluluk ve Ortalama Bilet Fiyatı
WITH Koltuk_Durum AS (
    SELECT 
        rp.Rota_Plan_ID,
        a.Arac_No,
        COUNT(k.Koltuk_ID) AS Toplam_Koltuk,
        SUM(CASE WHEN k.Durum='Dolu' THEN 1 ELSE 0 END) AS Dolu_Koltuk
    FROM Rota_Plan rp
    JOIN Arac a ON rp.Arac_ID = a.Arac_ID
    JOIN Koltuk k ON a.Arac_ID = k.Arac_ID
    GROUP BY rp.Rota_Plan_ID, a.Arac_No
),
Rota_Analiz AS (
    SELECT 
        r.Rota_ID,
        kd.Arac_No,
        kd.Toplam_Koltuk,
        kd.Dolu_Koltuk,
        ROUND(kd.Dolu_Koltuk::NUMERIC / kd.Toplam_Koltuk * 100, 2) AS Doluluk_Orani,
        AVG(rp.Bilet_Fiyati) AS Ortalama_Bilet_Fiyati
    FROM Rota r
    JOIN Rota_Plan rp ON r.Rota_ID = rp.Rota_ID
    JOIN Koltuk_Durum kd ON rp.Rota_Plan_ID = kd.Rota_Plan_ID
    GROUP BY r.Rota_ID, kd.Arac_No, kd.Toplam_Koltuk, kd.Dolu_Koltuk
)
SELECT *
FROM Rota_Analiz
ORDER BY Doluluk_Orani DESC;


-- Kampanya Kullanımı ve Etkisi
WITH Kampanya_Analiz AS (
    SELECT 
        k.Kampanya_ID,
        k.Ad AS Kampanya,
        COUNT(b.Bilet_ID) AS Kullanilan_Bilet_Sayisi,
        SUM(r.Fiyat) AS Toplam_Ciro,
        AVG(k.Indirim_Orani) AS Ortalama_Indirim
    FROM Kampanya k
    JOIN Firma f ON k.Firma_ID = f.Firma_ID
    JOIN Arac a ON f.Firma_ID = a.Firma_ID
    JOIN Rota_Plan rp ON a.Arac_ID = rp.Arac_ID
    JOIN Rezervasyon r ON rp.Rota_Plan_ID = r.Rota_Plan_ID
    JOIN Bilet b ON r.Rezervasyon_ID = b.Rezervasyon_ID
    GROUP BY k.Kampanya_ID
)
SELECT *
FROM Kampanya_Analiz
ORDER BY Toplam_Ciro DESC;


-- Kullanıcı Başına Bildirim ve Rezervasyon Durumu
WITH Kullanici_Bildirim AS (
    SELECT 
        k.Kullanici_ID,
        k.Isim || ' ' || k.Soyisim AS Kullanici,
        COUNT(b.Bildirim_ID) AS Bildirim_Sayisi,
        STRING_AGG(DISTINCT b.Tur, ', ') AS Bildirim_Turleri
    FROM Kullanici k
    LEFT JOIN Bildirim b ON k.Kullanici_ID = b.Kullanici_ID
    GROUP BY k.Kullanici_ID
),
Kullanici_Res AS (
    SELECT 
        k.Kullanici_ID,
        COUNT(r.Rezervasyon_ID) AS Rezervasyon_Sayisi,
        SUM(CASE WHEN r.Durum='Tamamlandı' THEN 1 ELSE 0 END) AS Tamamlanan,
        SUM(CASE WHEN r.Durum='İptal' THEN 1 ELSE 0 END) AS Iptal
    FROM Kullanici k
    LEFT JOIN Rezervasyon r ON k.Kullanici_ID = r.Kullanici_ID
    GROUP BY k.Kullanici_ID
)
SELECT 
    kb.Kullanici,
    kb.Bildirim_Sayisi,
    kb.Bildirim_Turleri,
    kr.Rezervasyon_Sayisi,
    kr.Tamamlanan,
    kr.Iptal
FROM Kullanici_Bildirim kb
JOIN Kullanici_Res kr ON kb.Kullanici_ID = kr.Kullanici_ID
ORDER BY kr.Rezervasyon_Sayisi DESC;
