CREATE OR REPLACE VIEW `ecommerce-portofolio-2026.fmcg.cleaned_retail` AS
SELECT
    Invoice_ID, 
    Invoice_Date,

    -- 1. City Typo Standardization
    CASE
        WHEN Kota_Kabupaten IN ("Bdg", "Bndung") THEN "Bandung"
        WHEN Kota_Kabupaten IN ("Bks","bekasi","bks") THEN "Bekasi"
        WHEN Kota_Kabupaten = "Depk" THEN "Depok"
        WHEN Kota_Kabupaten = "Cimahi " THEN "Cimahi"
        ELSE Kota_Kabupaten
    END AS Kota_Clean,

    -- 2. Gender Category Cleansing
    CASE
        WHEN Gender IN ("Wnt","Perempuan","Pr") THEN "Wanita"
        WHEN Gender IN ("Laki-laki") THEN "Pria"
        ELSE "Tidak Diketahui"
    END AS Gender_Clean,

    -- 3. Extreme Age Outlier Handling
    CASE
        WHEN Umur_Pelanggan < 15 OR Umur_Pelanggan > 80 THEN NULL
        ELSE Umur_Pelanggan
    END AS Umur_Bersih,

    -- 4. Feature Engineering: Operational Hour Traffic Segmentation
    CASE
        WHEN EXTRACT(HOUR FROM Invoice_Date) BETWEEN 6 AND 10 THEN "1. Morning (6-10)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 11 AND 14 THEN "2. Midday (11-14)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 15 AND 18 THEN "3. Afternoon (15-18)"
        ELSE "4. Night (19-5)"
    END AS Time_Segment,

    -- 5. Payment Method Missing Value Imputation
    COALESCE(Metode_Pembayaran,"Lainnya") AS Pembayaran_Bersih,

    -- Commercial and inventory metrics mapping
    Jenis_Toko, Kategori, Merek, Channel, Kuantitas, Biaya, Total_Biaya, 
    Harga_Penjualan, Pendapatan, Margin, `Margin_%`, Periode_Promo, 
    Stock_On_Hand, Reorder_Level, Lead_Time_Days, Status_Member

FROM `ecommerce-portofolio-2026.fmcg.retail`;
