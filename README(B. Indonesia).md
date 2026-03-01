# FMCG Retail Sales & Promotion Analytics: West Java Region

**Live Interactive Dashboard:** [View Dashboard on Looker Studio](https://lookerstudio.google.com/reporting/220ceb04-d613-4e36-ae4a-e76ac66028bb)

## Project Overview

Proyek ini merupakan portofolio end-to-end Data Analytics yang mereplikasi kasus bisnis nyata di industri ritel FMCG (Fast-Moving Consumer Goods). Analisis ini difokuskan pada pemantauan performa komersial wilayah Jawa Barat, pemetaan tren transaksi toko fisik, serta evaluasi mendalam terhadap efektivitas kampanye "Promo Payday" untuk mengukur Commercial Uplift (dampak kenaikan pendapatan) dan profil loyalitas pelanggan.

## Tech Stack & Architecture

1. **Google BigQuery (SQL):** Digunakan untuk ekstraksi data skala besar, pembersihan anomali (Data Cleansing), dan rekayasa fitur (Feature Engineering) sebelum divisualisasikan.
2. **Google Looker Studio:** Digunakan untuk visualisasi data interaktif, merancang UI/UX dashboard dengan metode Single-Page Long Scroll, dan menyusun kalkulasi metrik bisnis tingkat eksekutif.

---

## Phase 1: Data Cleansing & Feature Engineering (SQL)

Dataset mentah diproses secara efisien di cloud menggunakan Google BigQuery. Untuk menjaga integritas sumber data mentah, proses pembersihan dan transformasi dilakukan dengan membuat View terpisah.

Rekayasa fitur dilakukan pada kolom waktu untuk menciptakan "Time_Segment". Segmentasi ini sangat krusial untuk operasional ritel guna mengelompokkan jam sibuk, di mana transaksi malam hari (hingga subuh) dikonsolidasikan untuk mencerminkan realitas shift kerja di lapangan.

**SQL Query Configuration:**

```sql
CREATE OR REPLACE VIEW `ecommerce-portofolio-2026.fmcg.cleaned_retail` AS
SELECT
    Invoice_ID, 
    Invoice_Date,

    -- 1. Standardisasi Typo Kota
    CASE
        WHEN Kota_Kabupaten IN ("Bdg", "Bndung") THEN "Bandung"
        WHEN Kota_Kabupaten IN ("Bks","bekasi","bks") THEN "Bekasi"
        WHEN Kota_Kabupaten = "Depk" THEN "Depok"
        WHEN Kota_Kabupaten = "Cimahi " THEN "Cimahi"
        ELSE Kota_Kabupaten
    END AS Kota_Clean,

    -- 2. Pembersihan Kategori Gender
    CASE
        WHEN Gender IN ("Wnt","Perempuan","Pr") THEN "Wanita"
        WHEN Gender IN ("Laki-laki") THEN "Pria"
        ELSE "Tidak Diketahui"
    END AS Gender_Clean,

    -- 3. Penanganan Outlier Umur Ekstrem
    CASE
        WHEN Umur_Pelanggan < 15 OR Umur_Pelanggan > 80 THEN NULL
        ELSE Umur_Pelanggan
    END AS Umur_Bersih,

    -- 4. Feature Engineering: Segmentasi Lalu Lintas Jam Operasional
    CASE
        WHEN EXTRACT(HOUR FROM Invoice_Date) BETWEEN 6 AND 10 THEN "1. Morning (6-10)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 11 AND 14 THEN "2. Midday (11-14)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 15 AND 18 THEN "3. Afternoon (15-18)"
        ELSE "4. Night (19-5)"
    END AS Time_Segment,

    -- 5. Imputasi Missing Values pada Pembayaran
    COALESCE(Metode_Pembayaran,"Lainnya") AS Pembayaran_Bersih,

    -- Pemetaan metrik komersial dan inventori
    Jenis_Toko, Kategori, Merek, Channel, Kuantitas, Biaya, Total_Biaya, 
    Harga_Penjualan, Pendapatan, Margin, `Margin_%`, Periode_Promo, 
    Stock_On_Hand, Reorder_Level, Lead_Time_Days, Status_Member

FROM `ecommerce-portofolio-2026.fmcg.retail`;

```

---

## Phase 2: Dashboard Architecture

Dashboard dirancang dengan hierarki visual yang sistematis untuk menjawab kebutuhan manajerial:

1. **Executive Commercial KPI:** Mengukur kesehatan finansial melalui metrik utama seperti Total Revenue, Average Margin %, dan Average Basket Size.
2. **Market Dynamics & Trends:** Menganalisis korelasi antara wilayah (Bandung, Bekasi, dsb) dengan Jenis Toko untuk melihat di mana penetrasi pasar paling kuat.
3. **Product & Brand Portfolio:** Menggunakan Scatter Plot untuk memetakan performa Merek berdasarkan Pendapatan dan Margin %, memberikan pandangan strategis mengenai portfolio produk yang paling menguntungkan.
4. **Promotion & Traffic Deep-Dive:**
* **Commercial Impact Evaluator:** Membandingkan performa hari reguler vs periode promo secara head-to-head untuk mengukur efektivitas kampanye dalam menaikkan nilai belanja rata-rata.
* **Physical Footfall Heatmap:** Visualisasi kepadatan transaksi berdasarkan hari dan Time_Segment. Analisis ini menggunakan filter saluran "Offline" untuk memberikan gambaran akurat mengenai kepadatan pengunjung fisik di toko.
* **Acquisition vs. Retention Analyzer:** Menggunakan 100% Stacked Bar Chart untuk melihat apakah promo berhasil menarik pelanggan baru (Non-Member) atau lebih dominan digunakan oleh pelanggan lama.



---

## Key Actionable Insights

1. **Analisis Efektivitas Promo:** Berdasarkan data, persentase pelanggan Non-Member saat hari reguler (70.18%) dan saat promo (70.82%) menunjukkan perbedaan yang sangat tipis (0.64%). Hal ini mengindikasikan bahwa promo Payday saat ini lebih berfungsi sebagai alat retensi bagi pelanggan yang sudah ada atau mereka yang memang berniat belanja, namun belum menjadi pemicu utama akuisisi pelanggan baru dari luar ekosistem.
2. **Manajemen Kapasitas Toko:** Heatmap menunjukkan bahwa jam sibuk terkonsentrasi pada segmen waktu tertentu di akhir pekan. Dengan data ini, manajemen dapat mengoptimalkan jumlah staf kasir dan personel keamanan pada jam-jam tersebut untuk mencegah penurunan kualitas layanan akibat antrean panjang.
3. **Optimasi Portfolio Produk:** Melalui pemetaan Brand Portfolio, perusahaan dapat mengidentifikasi merek mana yang memiliki volume penjualan tinggi namun margin rendah, sehingga dapat dilakukan penyesuaian strategi harga atau negosiasi ulang dengan vendor untuk menjaga profitabilitas.

---

**Author**
Aldi Gunawan
Bandung, Indonesia.
Bachelor of Business in Creativepreneurship, Binus University.
[Connect on LinkedIn](https://www.google.com/search?q=https://www.linkedin.com/in/aldigunawan17/)
