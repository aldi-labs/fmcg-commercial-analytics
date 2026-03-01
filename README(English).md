# FMCG Retail Sales & Promotion Analytics: West Java Region

**Live Interactive Dashboard:** [View Dashboard on Looker Studio](https://lookerstudio.google.com/reporting/220ceb04-d613-4e36-ae4a-e76ac66028bb)

## Project Overview

This project is an end-to-end Data Analytics portfolio that replicates a real-world business case in the FMCG (Fast-Moving Consumer Goods) retail industry. The analysis focuses on monitoring commercial performance in the West Java region, mapping physical store transaction trends, and conducting an in-depth evaluation of the "Payday Promo" campaign to measure Commercial Uplift and customer retention profiles.

## Tech Stack & Architecture

1. **Google BigQuery (SQL):** Utilized for large-scale data extraction, anomaly handling (Data Cleansing), and Feature Engineering prior to visualization.
2. **Google Looker Studio:** Utilized for interactive data visualization, designing the dashboard UI/UX using a Single-Page Long Scroll method, and structuring executive-level business metric calculations.

---

## Phase 1: Data Cleansing & Feature Engineering (SQL)

The raw dataset was processed efficiently in the cloud using Google BigQuery. To preserve the integrity of the raw data source, the cleansing and transformation processes were executed by creating a dedicated View.

Feature engineering was applied to the time column to create a "Time_Segment". This segmentation is crucial for retail operations to group peak hours, where late-night transactions (extending to dawn) are consolidated to accurately reflect on-the-ground operational shifts.

**SQL Query Configuration:**

```sql
CREATE OR REPLACE VIEW `ecommerce-portofolio-2026.fmcg.cleaned_retail` AS
SELECT
    Invoice_ID, 
    Invoice_Date,

    # 1. City Typo Standardization
    CASE
        WHEN Kota_Kabupaten IN ("Bdg", "Bndung") THEN "Bandung"
        WHEN Kota_Kabupaten IN ("Bks","bekasi","bks") THEN "Bekasi"
        WHEN Kota_Kabupaten = "Depk" THEN "Depok"
        WHEN Kota_Kabupaten = "Cimahi " THEN "Cimahi"
        ELSE Kota_Kabupaten
    END AS Kota_Clean,

    # 2. Gender Category Cleansing
    CASE
        WHEN Gender IN ("Wnt","Perempuan","Pr") THEN "Wanita"
        WHEN Gender IN ("Laki-laki") THEN "Pria"
        ELSE "Tidak Diketahui"
    END AS Gender_Clean,

    # 3. Extreme Age Outlier Handling
    CASE
        WHEN Umur_Pelanggan < 15 OR Umur_Pelanggan > 80 THEN NULL
        ELSE Umur_Pelanggan
    END AS Umur_Bersih,

    # 4. Feature Engineering: Operational Hour Traffic Segmentation
    CASE
        WHEN EXTRACT(HOUR FROM Invoice_Date) BETWEEN 6 AND 10 THEN "1. Morning (6-10)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 11 AND 14 THEN "2. Midday (11-14)"
        WHEN EXTRACT (HOUR FROM Invoice_Date) BETWEEN 15 AND 18 THEN "3. Afternoon (15-18)"
        ELSE "4. Night (19-5)"
    END AS Time_Segment,

    # 5. Payment Method Missing Value Imputation
    COALESCE(Metode_Pembayaran,"Lainnya") AS Pembayaran_Bersih,

    # Commercial and inventory metrics mapping
    Jenis_Toko, Kategori, Merek, Channel, Kuantitas, Biaya, Total_Biaya, 
    Harga_Penjualan, Pendapatan, Margin, `Margin_%`, Periode_Promo, 
    Stock_On_Hand, Reorder_Level, Lead_Time_Days, Status_Member

FROM `ecommerce-portofolio-2026.fmcg.retail`;

```

---

## Phase 2: Dashboard Architecture

The dashboard is designed with a systematic visual hierarchy to address managerial needs:

1. **Executive Commercial KPI:** Measures financial health through primary metrics such as Total Revenue, Average Margin %, and Average Basket Size.
2. **Market Dynamics & Trends:** Analyzes the correlation between regions (Bandung, Bekasi, etc.) and Store Types to identify areas with the strongest market penetration.
3. **Product & Brand Portfolio:** Utilizes a Scatter Plot to map Brand performance based on Revenue and Margin %, providing a strategic overview of the most and least profitable product portfolios.
4. **Promotion & Traffic Deep-Dive:**
* **Commercial Impact Evaluator:** Compares the performance of regular days vs. promo periods head-to-head to measure the campaign's effectiveness in increasing the average transaction value.
* **Physical Footfall Heatmap:** Visualizes transaction density based on the day of the week and Time_Segment. This analysis applies an "Offline" channel filter to provide a highly accurate representation of physical visitor traffic.
* **Acquisition vs. Retention Analyzer:** Utilizes a 100% Stacked Bar Chart to determine whether the promo successfully attracted new customers (Non-Member) or was predominantly utilized by existing loyal customers.



---

## Key Actionable Insights

1. **Promo Effectiveness Analysis:** Based on the data, the percentage of Non-Member customers during regular days (70.18%) and promo days (70.82%) shows a negligible difference (0.64%). This indicates that the Payday promo currently functions primarily as a retention tool for existing customers or those who already intended to shop, rather than serving as a major catalyst for acquiring new customers outside the ecosystem. Broader top-of-funnel marketing channels are recommended.
2. **Store Capacity Management:** The heatmap reveals that peak hours are highly concentrated in specific time segments during the weekends. Leveraging this data, management can dynamically optimize the scheduling of active cashiers and security personnel during these hours to prevent a decline in customer satisfaction due to queue bottlenecks.
3. **Product Portfolio Optimization:** Through the Brand Portfolio mapping, the company can seamlessly identify brands that generate high sales volume but yield low margins (Loss Leaders). This allows for targeted price strategy adjustments or vendor renegotiations to safeguard overall profitability.

---

**Author**
Aldi Gunawan
Bandung, Indonesia
Bachelor of Business in Creativepreneurship, Binus University
[Connect on LinkedIn](https://www.linkedin.com/in/aldigunawan17/)
