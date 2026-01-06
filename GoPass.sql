DROP SCHEMA IF EXISTS public CASCADE;    
CREATE SCHEMA public;

CREATE TABLE Sehir (
    Sehir_Kodu INT PRIMARY KEY, 
    Sehir_Adi VARCHAR(100) NOT NULL
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
    Arac_Tipi VARCHAR(50)
);

CREATE TABLE Arac (
    Arac_ID SERIAL PRIMARY KEY,
    Firma_ID INT NOT NULL REFERENCES Firma(Firma_ID),
    Arac_No VARCHAR(50) NOT NULL UNIQUE,
    Kapasite INT CHECK (Kapasite > 0),
    Koltuk_Duzeni VARCHAR(100),
    Ulasim_Turu_ID INT NOT NULL REFERENCES Ulasim_Turu(Ulasim_Turu_ID)
);

CREATE TABLE Koltuk (
    Koltuk_ID SERIAL PRIMARY KEY,
    Arac_ID INT NOT NULL REFERENCES Arac(Arac_ID) ON DELETE CASCADE,
    Koltuk_Turu VARCHAR(50),
    Durum VARCHAR(50) DEFAULT 'Boş',
    Koltuk_No VARCHAR(20) NOT NULL,
    UNIQUE (Arac_ID, Koltuk_No)
);

CREATE TABLE Konum (
    Konum_ID SERIAL PRIMARY KEY,
    Konum_Adi VARCHAR(100) NOT NULL, 
    Sehir_Kodu INT NOT NULL REFERENCES Sehir(Sehir_Kodu)
);

CREATE TABLE Rota (
    Rota_ID SERIAL PRIMARY KEY,
    Kalkis_Konum_ID INT NOT NULL REFERENCES Konum(Konum_ID),
    Varis_Konum_ID INT NOT NULL REFERENCES Konum(Konum_ID),
    Km NUMERIC(8,2) CHECK (Km > 0),
	Tahmini_Sure INTERVAL NOT NULL,
    CHECK (Kalkis_Konum_ID <> Varis_Konum_ID),
	UNIQUE (Kalkis_Konum_ID, Varis_Konum_ID)
);

CREATE TABLE Rota_Plan (
    Rota_Plan_ID SERIAL PRIMARY KEY,
    Rota_ID INT NOT NULL REFERENCES Rota(Rota_ID),
    Arac_ID INT NOT NULL REFERENCES Arac(Arac_ID),
    Sefer_Tarihi DATE NOT NULL,
    Sefer_Saati TIME NOT NULL,
    Bilet_Fiyati NUMERIC(10,2) NOT NULL CHECK (Bilet_Fiyati > 0),
	UNIQUE (Arac_ID, Sefer_Tarihi, Sefer_Saati)
);

CREATE TABLE Kullanici (
    Kullanici_ID SERIAL PRIMARY KEY,
    Isim VARCHAR(100),
    Soyisim VARCHAR(100),
    Eposta VARCHAR(150) NOT NULL UNIQUE,
    Parola VARCHAR(100) NOT NULL
);

CREATE TABLE Yolcu (
    Yolcu_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT REFERENCES Kullanici(Kullanici_ID),
	Ad VARCHAR(100) NOT NULL,
    Soyad VARCHAR(100) NOT NULL,
    Yasi INT CHECK (Yasi >= 0),
    Cinsiyet VARCHAR(10)
);

CREATE TABLE Rezervasyon (
    Rezervasyon_ID SERIAL PRIMARY KEY,
    Koltuk_ID INT NOT NULL REFERENCES Koltuk(Koltuk_ID),
    Yolcu_ID INT NOT NULL REFERENCES Yolcu(Yolcu_ID),
    Rota_Plan_ID INT NOT NULL REFERENCES Rota_Plan(Rota_Plan_ID),
	Fiyat NUMERIC(10,2),
    Durum VARCHAR(50) NOT NULL
        CHECK (Durum IN ('Beklemede','Rezerve','Biletlendi','Tamamlandı','İptal'))
);

CREATE UNIQUE INDEX uq_aktif_koltuk
ON Rezervasyon (Rota_Plan_ID, Koltuk_ID)
WHERE Durum <> 'İptal';

CREATE TABLE Odeme (
    Odeme_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT NOT NULL REFERENCES Rezervasyon(Rezervasyon_ID),
    Odeme_Metodu VARCHAR(50),
    Odeme_Durumu VARCHAR(50)
        CHECK (Odeme_Durumu IN ('Bekliyor','Tamamlandı','İade Edildi')),
    Para_Birimi VARCHAR(20),
    Fiyat NUMERIC(10,2),
    Iade_Tutari NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE Fatura (
    Fatura_ID SERIAL PRIMARY KEY,
    Odeme_ID INT NOT NULL REFERENCES Odeme(Odeme_ID),
    Tarih DATE,
    Tutar NUMERIC(10,2)
);

CREATE TABLE Bilet (
    Bilet_ID SERIAL PRIMARY KEY,
    Rezervasyon_ID INT NOT NULL REFERENCES Rezervasyon(Rezervasyon_ID),
    Olusturulma_Tarihi DATE,
    QR_Kod VARCHAR(255) UNIQUE,
    Bilet_No VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Bildirim (
    Bildirim_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL REFERENCES Kullanici(Kullanici_ID),
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
    Firma_ID INT NOT NULL REFERENCES Firma(Firma_ID)
);

CREATE TABLE Kampanya (
    Kampanya_ID SERIAL PRIMARY KEY,
    Ad VARCHAR(100),
    Indirim_Orani NUMERIC(5,2),
    Baslangic DATE,
    Bitis DATE,
    Firma_ID INT REFERENCES Firma(Firma_ID),
    CHECK (Baslangic <= Bitis)
);

CREATE TABLE Indirim (
    Indirim_ID SERIAL PRIMARY KEY,
    Kod VARCHAR(50) UNIQUE,
    Indirim_Degeri NUMERIC(5,2),
    Durum VARCHAR(50),
    Kullanim_Hakki VARCHAR(50),
    Indirim_Araligi VARCHAR(50)
);

CREATE TABLE Bilet_Indirim (
    Bilet_ID INT NOT NULL,
    Indirim_ID INT NOT NULL,
    PRIMARY KEY (Bilet_ID, Indirim_ID),
    CONSTRAINT fk_bilet_indirim_bilet
        FOREIGN KEY (Bilet_ID)
        REFERENCES Bilet(Bilet_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_bilet_indirim_indirim
        FOREIGN KEY (Indirim_ID)
        REFERENCES Indirim(Indirim_ID)
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
    Favori_ID SERIAL PRIMARY KEY,
    Kullanici_ID INT NOT NULL REFERENCES Kullanici(Kullanici_ID),
    Rota_ID INT NOT NULL REFERENCES Rota(Rota_ID),
    Firma_ID INT NOT NULL REFERENCES Firma(Firma_ID),
    Eklenme_Tarihi DATE NOT NULL,
    UNIQUE (Kullanici_ID, Rota_ID, Firma_ID)
);

CREATE TABLE Rol (
    Rol_ID SERIAL PRIMARY KEY,
    Rol_Adi VARCHAR(50) UNIQUE
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

CREATE TABLE Silinen_Sefer_Log (
    Log_ID SERIAL PRIMARY KEY,
    Rota_Plan_ID INT REFERENCES Rota_Plan(Rota_Plan_ID) ON DELETE SET NULL,
    Silinme_Tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Kullanici VARCHAR(100) NOT NULL
);

CREATE INDEX idx_sefer_tarihi ON Rota_Plan(Sefer_Tarihi);
CREATE INDEX idx_kullanici_email ON Kullanici(Eposta);
CREATE INDEX idx_bilet_pnr ON Bilet(Bilet_No);
CREATE INDEX idx_rota_kalkis_varis ON Rota(Kalkis_Konum_ID, Varis_Konum_ID);
CREATE INDEX idx_plan_rota_tarih ON Rota_Plan(Rota_ID, Sefer_Tarihi);




CREATE OR REPLACE FUNCTION trg_cifte_rez()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Rezervasyon
        WHERE Rota_Plan_ID = NEW.Rota_Plan_ID
          AND Koltuk_ID    = NEW.Koltuk_ID
          AND Durum <> 'İptal'
    ) THEN
        RAISE EXCEPTION 'Bu koltuk dolu!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_double_booking ON Rezervasyon;

CREATE TRIGGER trg_double_booking
BEFORE INSERT ON Rezervasyon
FOR EACH ROW
EXECUTE FUNCTION trg_cifte_rez();




CREATE OR REPLACE FUNCTION trg_iade()
RETURNS TRIGGER AS $$
DECLARE
    kesinti NUMERIC := 10;
    iade    NUMERIC;
    v_kullanici_id INT; 
BEGIN
    IF NEW.Durum = 'İptal' AND OLD.Durum <> 'İptal' THEN

        SELECT COALESCE(ip.Fiyat, 10) 
        INTO kesinti
        FROM Iptal_Politikasi ip
        INNER JOIN Firma f ON ip.Firma_ID = f.Firma_ID
        INNER JOIN Arac a ON f.Firma_ID = a.Firma_ID
        INNER JOIN Rota_Plan rp ON a.Arac_ID = rp.Arac_ID
        WHERE rp.Rota_Plan_ID = NEW.Rota_Plan_ID
          AND ip.Durum = 'Aktif'
        ORDER BY ip.Iptal_Politikasi_ID DESC
        LIMIT 1;

        iade := NEW.Fiyat * (1 - kesinti / 100);

        UPDATE Odeme
        SET Odeme_Durumu = 'İade Edildi',
            Iade_Tutari  = iade
        WHERE Rezervasyon_ID = NEW.Rezervasyon_ID;

        SELECT Kullanici_ID INTO v_kullanici_id
        FROM Yolcu
        WHERE Yolcu_ID = NEW.Yolcu_ID;

        IF v_kullanici_id IS NOT NULL THEN
            INSERT INTO Bildirim (Kullanici_ID, Mesaj, Tur)
            VALUES (v_kullanici_id, CONCAT('İade işleminiz yapıldı: ', iade, ' TL'), 'İptal');
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cancel
AFTER UPDATE OF Durum ON Rezervasyon
FOR EACH ROW
EXECUTE FUNCTION trg_iade();




CREATE OR REPLACE FUNCTION trg_sefer_sil_log()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Silinen_Sefer_Log (Rota_Plan_ID, Kullanici)
    VALUES (OLD.Rota_Plan_ID, current_user); 

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_delete_sefer ON Rota_Plan;

CREATE TRIGGER trg_delete_sefer
AFTER DELETE ON Rota_Plan
FOR EACH ROW
EXECUTE FUNCTION trg_sefer_sil_log();




CREATE OR REPLACE PROCEDURE sp_bilet_satis(
    p_yolcu_id INT,  
    p_plan     INT,
    p_koltuk   INT,
    p_fiyat    NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE 
    rid             INT;
    oid             INT; 
    v_kullanici_id  INT; 
    v_bilet_no      VARCHAR(50);
    v_qr_string     VARCHAR(255);
    v_koltuk_dolu_mu BOOLEAN;
BEGIN
    SELECT Kullanici_ID INTO v_kullanici_id FROM Yolcu WHERE Yolcu_ID = p_yolcu_id;
    
    IF v_kullanici_id IS NULL THEN 
        RAISE EXCEPTION 'Geçersiz Yolcu ID!'; 
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM Rezervasyon 
        WHERE Koltuk_ID = p_koltuk AND Rota_Plan_ID = p_plan AND Durum <> 'İptal'
    ) INTO v_koltuk_dolu_mu;

    IF v_koltuk_dolu_mu THEN RAISE EXCEPTION 'Koltuk zaten dolu!'; END IF;
    IF p_fiyat <= 0 THEN RAISE EXCEPTION 'Geçersiz fiyat!'; END IF;

    INSERT INTO Rezervasyon (Koltuk_ID, Yolcu_ID, Rota_Plan_ID, Fiyat, Durum)
    VALUES (p_koltuk, p_yolcu_id, p_plan, p_fiyat, 'Biletlendi')
    RETURNING Rezervasyon_ID INTO rid;

    INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
    VALUES (rid, 'Kredi Kartı', 'Tamamlandı', 'TRY', p_fiyat)
    RETURNING Odeme_ID INTO oid; 

    INSERT INTO Fatura (Odeme_ID, Tarih, Tutar)
    VALUES (oid, CURRENT_DATE, p_fiyat);

    v_bilet_no  := 'PNR-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT), 1, 8));
    v_qr_string := CONCAT('PNR:', v_bilet_no, '|UID:', v_kullanici_id, '|RID:', rid);

    INSERT INTO Bilet (Rezervasyon_ID, Olusturulma_Tarihi, QR_Kod, Bilet_No)
    VALUES (rid, CURRENT_DATE, v_qr_string, v_bilet_no);

    RAISE NOTICE 'Bilet başarıyla oluşturuldu. Bilet No: %', v_bilet_no;
END;
$$;




CREATE OR REPLACE PROCEDURE sp_sefer_saati_guncelle(
    p_rota_plan_id INT,
    p_yeni_saat TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_yolcu RECORD;
BEGIN
    UPDATE Rota_Plan
    SET Sefer_Saati = p_yeni_saat
    WHERE Rota_Plan_ID = p_rota_plan_id;

    FOR v_yolcu IN
        SELECT DISTINCT y.Kullanici_ID
        FROM Rezervasyon r
        JOIN Yolcu y ON r.Yolcu_ID = y.Yolcu_ID
        WHERE r.Rota_Plan_ID = p_rota_plan_id
          AND r.Durum = 'Biletlendi'
          AND y.Kullanici_ID IS NOT NULL
    LOOP
        INSERT INTO Bildirim (Kullanici_ID, Mesaj, Tur)
        VALUES (
            v_yolcu.Kullanici_ID,
            CONCAT('Sefer saatiniz ', p_yeni_saat, ' olarak güncellendi.'),
            'Uyarı'
        );
    END LOOP;

    RAISE NOTICE 'Sefer saati güncellendi ve yolculara bildirim gitti.';
END;
$$;




CREATE OR REPLACE FUNCTION fn_detayli_satis_raporu(
    p_baslangic_tarihi DATE,
    p_bitis_tarihi DATE
)
RETURNS TABLE (
    Firma_Adi VARCHAR,
    Toplam_Sefer_Sayisi BIGINT,
    Satilan_Bilet_Sayisi BIGINT,
    Toplam_Hasilat NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.Firma_Adi,
        COUNT(DISTINCT rp.Rota_Plan_ID) AS Sefer_Sayisi,
        COUNT(r.Rezervasyon_ID)         AS Bilet_Sayisi,
        COALESCE(SUM(o.Fiyat), 0)       AS Hasilat
    FROM Firma f
    LEFT JOIN Arac a       ON f.Firma_ID = a.Firma_ID
    LEFT JOIN Rota_Plan rp ON a.Arac_ID  = rp.Arac_ID
    LEFT JOIN Rezervasyon r
            ON rp.Rota_Plan_ID = r.Rota_Plan_ID
           AND r.Durum = 'Biletlendi'
    LEFT JOIN Odeme o
            ON r.Rezervasyon_ID = o.Rezervasyon_ID
           AND o.Odeme_Durumu = 'Tamamlandı'
    WHERE rp.Sefer_Tarihi BETWEEN p_baslangic_tarihi AND p_bitis_tarihi
    GROUP BY f.Firma_Adi
    ORDER BY Hasilat DESC;
END;
$$ LANGUAGE plpgsql;




INSERT INTO Sehir (Sehir_Kodu, Sehir_Adi) VALUES 
(34, 'İstanbul'),(6, 'Ankara'),(35, 'İzmir'),(7, 'Antalya'),(16, 'Bursa'),
(1, 'Adana'),(61, 'Trabzon'),(27, 'Gaziantep'),(55, 'Samsun'),(38, 'Kayseri');


INSERT INTO Konum (Konum_Adi, Sehir_Kodu) VALUES 
('İstanbul',34), 
('Ankara',6),    
('İzmir',35),    
('Antalya',7),   
('Bursa',16),    
('Adana',1),     
('Trabzon',61),  
('Gaziantep',27),
('Samsun',55),   
('Kayseri',38);  


INSERT INTO Firma (Firma_Adi, Firma_TelNo, Firma_email) VALUES
('Kamil Koç','4440562','kamil@kamilkoc.com'),      
('Pamukkale','08503333535','pamukkale@pamukkale.com'), 
('Metro Turizm','08502223455','metro@metro.com'),  
('Türk Hava Yolları','4440849','thy@thy.com'),    
('Pegasus','08882281212','pgs@flypgs.com'),        
('SunExpress','4440797','sx@sunexpress.com'),      
('İDO','08502224436','ido@ido.com.tr'),            
('BUDO','4449916','budo@budo.com.tr');             


INSERT INTO Ulasim_Turu (Aciklama, Koltuk_Tipi, Arac_Tipi) VALUES
('Karayolu','2+1','Otobüs'), 
('Karayolu','2+2','Otobüs'), 
('Havayolu','Ekonomi','Uçak'), 
('Havayolu','Business','Uçak'),
('Denizyolu','Salon','Vapur'); 


INSERT INTO Arac (Firma_ID, Arac_No, Kapasite, Koltuk_Duzeni, Ulasim_Turu_ID) VALUES
(1,'KK-01',40,'2+1',1),
(2,'PM-01',46,'2+2',2),
(3,'MT-01',50,'2+2',2),
(4,'THY-01',180,'3+3',3),
(5,'PGS-01',189,'3+3',3),
(6,'SX-01',200,'3+3',4),
(7,'IDO-01',300,'Salon',5),
(8,'BUDO-01',280,'Salon',5);


INSERT INTO Koltuk (Arac_ID, Koltuk_Turu, Koltuk_No)
SELECT Arac_ID, 
       CASE  
           WHEN Arac_ID <= 3 THEN 'Otobüs'
           WHEN Arac_ID <= 6 THEN 'Uçak'
           ELSE 'Vapur'
       END,
       generate_series(1, Kapasite)::text
FROM Arac;


INSERT INTO Rota (Kalkis_Konum_ID, Varis_Konum_ID, Km, Tahmini_Sure) VALUES 
(1,2,450, '6 hours'),    
(1,3,480, '6 hours'),    
(1,5,150, '2 hours'),    
(2,4,500, '8 hours'),    
(3,1,480, '6 hours'),    
(4,1,700, '9 hours');    


INSERT INTO Rota_Plan (Rota_ID, Arac_ID, Sefer_Tarihi, Sefer_Saati, Bilet_Fiyati) VALUES 
(1,1,'2025-12-01','08:00',550), 
(2,2,'2025-12-02','09:00',600), 
(3,3,'2025-12-03','22:00',700), 
(4,1,'2025-12-04','10:00',650), 
(5,2,'2025-12-05','07:30',300), 
(1,4,'2025-12-06','11:00',1500),
(2,5,'2025-12-07','14:00',1450),
(3,6,'2025-12-08','09:30',1600),
(4,4,'2025-12-09','20:00',1550),
(6,5,'2025-12-10','07:00',1700),
(5,7,'2025-12-11','08:00',250), 
(5,8,'2025-12-12','12:00',260),
(6,7,'2025-12-13','16:00',300),
(1,8,'2025-12-14','18:00',280),
(2,7,'2025-12-15','07:00',320);


INSERT INTO Rol (Rol_Adi) VALUES ('ADMIN'),('FIRMA_YONETICISI'),('KULLANICI');


INSERT INTO Kullanici (Isim,Soyisim,Eposta,Parola) VALUES
('Mert','Pepele','mert@mail.com','123'), 
('Zeynep','Yılmaz','zeynep@mail.com','123'), 
('Ayşe','Demir','ayse@mail.com','123'), 
('Can','Kaya','can@mail.com','123'), 
('Elif','Arslan','elif@mail.com','123'),
('Ali','Emeksiz','ali@mail.com','123');


INSERT INTO Kullanici_Rol VALUES
(1,3),(2,3),(3,3),(4,2),(5,3);


INSERT INTO Firma_Yonetici VALUES (4,1),(4,4);


INSERT INTO Yolcu (Kullanici_ID,Yasi,Cinsiyet, Ad, Soyad) VALUES
(1,25,'Erkek', 'Mert', 'Pepele'), 
(2,29,'Kadın', 'Zeynep', 'Yılmaz'), 
(3,21,'Kadın', 'Ayşe', 'Demir'), 
(4,38,'Erkek', 'Can', 'Kaya'), 
(5,30,'Kadın', 'Elif', 'Arslan'), 
(6,25,'Erkek', 'Ali','Emeksiz');


INSERT INTO Rezervasyon (Yolcu_ID, Rota_Plan_ID, Koltuk_ID, Fiyat, Durum) VALUES 
(1, 1,  (SELECT MIN(Koltuk_ID) FROM Koltuk WHERE Arac_ID = (SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID = 1)), 550, 'Biletlendi'), 
(2, 2,  (SELECT MIN(Koltuk_ID) FROM Koltuk WHERE Arac_ID = (SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID = 2)), 600, 'Beklemede'), 
(3, 3,  (SELECT MIN(Koltuk_ID) FROM Koltuk WHERE Arac_ID = (SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID = 3)), 700, 'Rezerve'),
(4, 6,  (SELECT MIN(Koltuk_ID) FROM Koltuk WHERE Arac_ID = (SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID = 6)), 1500, 'Biletlendi'), 
(5, 11, (SELECT MIN(Koltuk_ID) FROM Koltuk WHERE Arac_ID = (SELECT Arac_ID FROM Rota_Plan WHERE Rota_Plan_ID = 11)), 250, 'Biletlendi'); 


INSERT INTO Odeme (Rezervasyon_ID,Odeme_Metodu,Odeme_Durumu,Para_Birimi,Fiyat) VALUES
(1,'Kredi Kartı','Tamamlandı','TRY',550), 
(4,'Kredi Kartı','Tamamlandı','TRY',1500), 
(5,'Kredi Kartı','Tamamlandı','TRY',250); 


INSERT INTO Fatura (Odeme_ID,Tarih,Tutar) VALUES
(1,CURRENT_DATE,550),(2,CURRENT_DATE,1500),(3,CURRENT_DATE,250);


INSERT INTO Bilet (Rezervasyon_ID,Olusturulma_Tarihi,QR_Kod,Bilet_No) VALUES
(1,CURRENT_DATE,'QR1','PNR001'),
(4,CURRENT_DATE,'QR2','PNR002'),
(5,CURRENT_DATE,'QR3','PNR003');


INSERT INTO Ek_Hizmet (Ad,Fiyat,Aciklama) VALUES
('Sigorta',75,'Seyahat sigortası'),
('Ekstra Bagaj',100,'20kg'),
('Evcil Hayvan',150,'Kabin');


INSERT INTO Rezervasyon_Ek_Hizmet VALUES (1,1),(1,2),(5,3);


INSERT INTO Bildirim (Kullanici_ID,Mesaj,Gosterim_Durumu,Tur) VALUES
(1,'Bilet oluşturuldu','Görülmedi','Bilgi'),
(4,'Sefer saati değişti','Görülmedi','Uyarı');


INSERT INTO Indirim (Kod,Indirim_Degeri,Durum,Kullanim_Hakki,Indirim_Araligi) VALUES
('OGRENCI25',25,'Aktif','Sınırsız','2025'),
('YAZ10',10,'Aktif','Tek','2025');


INSERT INTO Bilet_Indirim VALUES (1,1);


INSERT INTO Iptal_Politikasi (Politika,Fiyat,Durum,Firma_ID) VALUES 
('24 saat %50 kesinti',50,'Aktif',1),
('12 saat %30 kesinti',30,'Aktif',4),
('1 saat %10 kesinti',10,'Aktif',7);


INSERT INTO Kampanya (Ad,Indirim_Orani,Baslangic,Bitis,Firma_ID) VALUES
('Kış Kampanyası',20,CURRENT_DATE,'2026-03-01',1),
('Bahar Kampanyası',15,CURRENT_DATE,'2026-05-01',4);


INSERT INTO Favori (Kullanici_ID,Rota_ID,Firma_ID,Eklenme_Tarihi) VALUES
(1,1,1,CURRENT_DATE),
(2,2,2,CURRENT_DATE);


INSERT INTO Rapor (Firma_ID,Rapor_Tipi,Rapor_Veri,Tarih) VALUES
(1,'Aylık Satış','120.000 TL',CURRENT_DATE),
(4,'Memnuniyet','4.8/5',CURRENT_DATE);


INSERT INTO Silinen_Sefer_Log (Rota_Plan_ID, Kullanici, Silinme_Tarihi) VALUES
(12, 'admin_user', CURRENT_TIMESTAMP),
(13, 'sistem_yoneticisi', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(14, 'operasyon_uzmani', CURRENT_TIMESTAMP - INTERVAL '1 day');




BEGIN;
WITH secilen_koltuk AS (
    SELECT k.Koltuk_ID
    FROM Rota_Plan rp
    JOIN Koltuk k ON k.Arac_ID = rp.Arac_ID
    WHERE rp.Rota_Plan_ID = 1
      AND NOT EXISTS (
          SELECT 1
          FROM Rezervasyon r
          WHERE r.Rota_Plan_ID = rp.Rota_Plan_ID
            AND r.Koltuk_ID = k.Koltuk_ID
            AND r.Durum <> 'İptal'
      )
    ORDER BY k.Koltuk_ID
    LIMIT 1
),
yeni_rez AS (
    INSERT INTO Rezervasyon (Koltuk_ID, Yolcu_ID, Rota_Plan_ID, Fiyat, Durum)
    SELECT Koltuk_ID, 1, 1, 550.00, 'Biletlendi'
    FROM secilen_koltuk
    RETURNING Rezervasyon_ID
),
yeni_odeme AS (
    INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
    SELECT Rezervasyon_ID, 'Kredi Kartı', 'Tamamlandı', 'TRY', 550.00
    FROM yeni_rez
    RETURNING Odeme_ID
)
INSERT INTO Fatura (Odeme_ID, Tarih, Tutar)
SELECT Odeme_ID, CURRENT_DATE, 550.00
FROM yeni_odeme;
COMMIT;




BEGIN;
WITH secilen_koltuk AS (
    SELECT k.Koltuk_ID
    FROM Rota_Plan rp
    JOIN Koltuk k ON k.Arac_ID = rp.Arac_ID
    WHERE rp.Rota_Plan_ID = 1
      AND NOT EXISTS (
          SELECT 1
          FROM Rezervasyon r
          WHERE r.Rota_Plan_ID = rp.Rota_Plan_ID
            AND r.Koltuk_ID = k.Koltuk_ID
            AND r.Durum <> 'İptal'
      )
    ORDER BY k.Koltuk_ID
    LIMIT 1
),
yeni_rez AS (
    INSERT INTO Rezervasyon (Koltuk_ID, Yolcu_ID, Rota_Plan_ID, Fiyat, Durum)
    SELECT Koltuk_ID, 1, 1, 550.00, 'Biletlendi'
    FROM secilen_koltuk
    RETURNING Rezervasyon_ID
)
INSERT INTO Odeme (Rezervasyon_ID, Odeme_Metodu, Odeme_Durumu, Para_Birimi, Fiyat)
SELECT Rezervasyon_ID, 'Kredi Kartı', 'Tamamlandı', 'TRY', 550.00
FROM yeni_rez;

ROLLBACK;

select * from Silinen_Sefer_Log;

SELECT * FROM Rezervasyon WHERE Yolcu_ID=1 AND Rota_Plan_ID=1 ORDER BY Rezervasyon_ID DESC;
