# Portfolio Project - Tech4All, Inc. Analysis
Tech4All, Inc. is a global SaaS company offering solutions to customers globally. With a broad product portfolio spanning 12 different offerings, Tech4All enables customers to solve for business use cases and achieve 
operatonal efficiency and process optimization. In this project, I analyze a sample dataset of a dataset containing sales data for Tech4All to identify trends in sales, top performing products and regions, and customers. 
Based on these insights, I provide recommendations on where Tech4All can focus future efforts to optimize revenue growth and grow its business.
I use a combination of SQL queries to analyze the data and Tableau to visualize the trends I discovered.

# About the Data
The dataset contains two tables: one containing information about Tech4All's sales and order across their global regions and the second table containing information about the customers that the orders have been sold to. 
The dataset contains about 10,000 rows.
* SQL queries used for the analysis can be found [here](https://github.com/aylee428/portfolio-projects/blob/main/Tech4All-Analysis/Tech4All_Analysis.sql).
* Tableau workbook for analysis and more detailed insights can be found [here](https://github.com/aylee428/portfolio-projects/blob/main/Tech4All-Analysis/Tech4All.twb) or on my Tableau Public site [here](https://public.tableau.com/views/Tech4AllAnalysis/LifetimePerformance?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link).

# Summary of Insights
### Yearly
* Tech4All's total sales declined in 2021 but **sharply increased in 2022 by 29%**. This increase may be due to companies loosening up their IT spend moving into the post-pandemic phase.
* Total Sales increased by a smaller % in 2023 (**21%**) but reached the highest amount (**$733K**) in the past 4 years. 
### Region
* The EMEA region is our strongest performing region. When comparing the growth of each region over time, EMEA has shown the most volatility in total sales, with sales fluctuating by large percentages.
* While all three regions have typically shown stronger growth towards the second half of each year (Q3 & Q4), EMEA in particular has shown higher spikes in Q4 compared to those of other regions (43% YoY Q4 Growth in 2023 vs. -2% for AMER & 15% for APAC).

### Segment
* While the SMB segment continues to provide the lionshare of total sales, the Strategic market segment is our fastest growing market segment.
  * Notably, the Strategic segment surpassed the SMB segment in Total Sales **for the first time** in Q2 of 2023.
* While underperforming relative to the SMB and Strategic segments, the Enterprise segment reached its **highest total sales ($66K)** in Q4 of 2023.

### Industry:
* Finance continues to be our strongest performing industry in terms of sales.
* Many industries have shown a stronger propensity to buy in Q4 for each year.

# Technical Analysis
<kbd> <img width="1358" alt="image" src="https://github.com/aylee428/portfolio-projects/assets/62224204/03ba4d0b-5f2c-48c9-908a-9894e7e77ca9"> </kbd>
<kbd> <img width="1360" alt="image" src="https://github.com/aylee428/portfolio-projects/assets/62224204/17da3dea-0df3-48e3-91fb-15026b0897b6"> </kbd>
<kbd> <img width="1356" alt="image" src="https://github.com/aylee428/portfolio-projects/assets/62224204/7828353a-d352-42d1-838f-a61b4ef016ba"> </kbd>
<kbd> <img width="1361" alt="image" src="https://github.com/aylee428/portfolio-projects/assets/62224204/ec1d73d1-ca0f-43b5-8732-20fee9023618"> </kbd>

# Recommendations & Next Steps
* Investigate the volatility of the EMEA region - do we need to establish healthier sales pipelines leading into slower quarters (Q1 & Q2)? Consider promotions in Q1 & Q2 to smooth buying patterns throughout the year.
* The Strategic Segment continues to grow rapidly. Consider methods to sustain growth and capture more share of the market.
  * Are there marketing campaigns we can use to increase demand amongst other Strategic prospects? For example, product whitepapers featuring existing customers or customer committee seminars?
* Consider product-based strategies to improve our growth in the Enterprise Segment and in certain industries.
  * Are there product features or integrations with other software partners that we can implement to improve product market fit with the Enterprise segment? With certain industries?
    * We offer FinanceHub, a product that is popular amongst our Finance customers. Are there industry-specific solutions we can offer to Transportation or Communications customers? 

# Considerations for Future Analysis
This analysis looked at sales performance across several dimensions. Further analysis may look into Order Count and AOV across those dimensions or Product mix of our top customers to assess the strength of our product portfolio in the market.



