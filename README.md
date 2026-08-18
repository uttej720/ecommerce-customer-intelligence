# E-Commerce Customer Intelligence: RFM, Churn, Delivery Performance and Customer-Risk Analysis

A PostgreSQL-based customer analytics project that integrates e-commerce transaction data, delivery performance, RFM segmentation, churn analysis, and customer-risk prioritisation to identify high-value customers, delivery-related retention risks, and actionable business opportunities.

## Project Overview

This project investigates customer behaviour and operational delivery performance in an e-commerce environment using PostgreSQL.

The analysis combines customer, order, product, category, order-item, and shipping data to understand customer value, purchasing behaviour, delivery delays, cancellations, churn risk, and delayed-sales exposure.

The workflow begins with raw e-commerce transaction and shipping data. The data is validated, normalised into relational PostgreSQL tables, and transformed into customer-level analytical views.

The project then applies RFM analysis to measure customer value, churn analysis to identify inactive and at-risk customers, and delivery-performance analysis to identify late-delivery and cancellation exposure.

The main business objective is to identify customer groups where poor delivery performance may place valuable revenue relationships at risk.

## Objectives

- The major objectives of this project are:

- Organise e-commerce transaction and shipping information into a structured PostgreSQL data model.

- Validate customer, order, product, shipping, and sales data before analysis.

- Identify valid purchases using completed and closed orders.

- Build an analytics-ready customer-order dataset.

- Calculate Recency, Frequency, and Monetary value for every customer.

- Segment customers using percentile-based RFM scoring.

- Identify customers who have churned and active customers approaching churn.

- Analyse late deliveries, delivery delays, and shipment cancellations.

- Measure customer-level delayed-sales exposure.

- Identify high-value customers with poor delivery experiences.

- Prioritise customer groups for retention, service recovery, and operational intervention.

## End-to-End Workflow

```text
E-Commerce Transaction and Shipping Data
                    │
                    ▼
          PostgreSQL Data Preparation
                    │
                    ▼
          Relational Table Normalisation
                    │
                    ▼
          Data Quality Validation
                    │
                    ▼
       Customer-Order Analysis Base
                    │
         ┌──────────┴──────────┐
         │                     │
         ▼                     ▼
   RFM Customer Analysis   Delivery Performance Analysis
         │                     │
         ▼                     ▼
 Customer Value Segments   Late Delivery and Cancellation Metrics
         │                     │
         └──────────┬──────────┘
                    ▼
          Churn and Retention Analysis
                    │
                    ▼
       Customer-Risk Prioritisation
                    │
                    ▼
       Business Recommendations
```

## Dataset

The project uses e-commerce transaction, product, customer, order, and shipping data.

The raw dataset contains order-level and order-item-level information, including customer location, product details, order status, sales value, shipping mode, delivery status, actual delivery duration, and scheduled delivery duration.

The raw dataset is not included in this repository because it may contain sensitive fields and large transaction-level records.

The project uses the following core relational tables:

- customers
- orders
- order_items
- products
- categories
- shipping

The analytical workflow is built from these normalised tables.

PostgreSQL Data Preparation

### 1. Relational Data Model

The raw data is organised into six primary PostgreSQL tables.

- Customers

The customers table contains customer-level information such as customer segment and location attributes.

- Orders

The orders table contains order identifiers, customer relationships, order dates, order status, market, and geographic order information.

- Order Items

The order_items table contains product-level transaction details, including quantity, sales, discount, and profit information.

- Products

The products table contains product, department, and product-category attributes.

- Categories

The categories table contains product-category reference information.

- Shipping

The shipping table contains shipping mode, delivery status, late-delivery risk, actual shipping days, and scheduled shipping days.

### 2. Data Validation

The project includes data-quality checks before customer analytics are performed.

The validation process includes:

- Primary-key uniqueness checks

- Foreign-key relationship checks

- Missing-value analysis

- Duplicate-record checks

- Customer and order consistency checks

- Product and category consistency checks

- Invalid numeric-value checks

- Date-range validation

- Shipping-date validation

- Actual-versus-scheduled delivery validation

- Customer and order population reconciliation

These checks ensure that the customer and delivery analysis is based on reliable, consistent data.

### 3. Valid Purchase Identification

- A customer purchase is treated as valid only when the order status is:

COMPLETE
CLOSED

Orders with statuses such as pending, processing, canceled, payment review, suspected fraud, or on hold are excluded from RFM and customer purchase analysis.

- The valid-purchase dataset is created through the following analytical objects:

customer_order_base
valid_customer_orders

The customer_order_base table provides an analytics-ready order-item-level view of customer purchases, products, sales, and shipping information.

Customer Value and RFM Analysis

### 4. RFM Metrics

The project uses RFM analysis to measure customer value.

- Recency

Recency measures the number of days since a customer's most recent valid purchase.

Recency = Analysis Date − Latest Valid Purchase Date

- Frequency

Frequency measures the number of distinct valid orders placed by a customer.

Frequency = Number of Distinct Valid Orders

- Monetary Value

Monetary value measures the total sales generated by a customer through valid purchases.

Monetary = Total Sales from Valid Purchases

The customer-level RFM metrics are stored in:

customer_rfm_base

### 5. RFM Customer Segmentation

Percentile-based scoring is used to assign Recency, Frequency, and Monetary scores from 1 to 5.

The combined RFM score is used to classify customers into meaningful business segments.

Key customer segments include:

- Champions

- Loyal Customers

- Potential Loyalists

- New Customers

- At Risk

- High-Value Churned

- Hibernating

- Need Attention

These segments help distinguish high-value active customers from inactive, vulnerable, and low-engagement customer groups.

Delivery Performance Analysis

### 6. Delivery Delay Calculation

Delivery performance is measured by comparing actual shipping duration with scheduled shipping duration.

Delivery Delay = Actual Shipping Days − Scheduled Shipping Days

The delivery analysis evaluates:

- Actual shipping days

- Scheduled shipping days

- Delivery delay

- Delivery status

- Late-delivery indicator

- Shipment-cancellation indicator

- Customer-level late-delivery rate

- Customer-level cancellation rate

- Average delivery delay

- Maximum delivery delay

The delivery-performance workflow uses:

- order_shipping_base
- customer_supply_chain_base

### 7. Customer-Level Delivery Metrics

Customer-level supply-chain metrics are calculated by aggregating order shipping information for each customer.

The analysis calculates:

- Total Orders
- Late Orders
- Late-Delivery Rate
- Average Delivery Delay
- Maximum Delivery Delay
- Canceled Orders
- Cancellation Rate
- Average Actual Shipping Days
- Average Scheduled Shipping Days

These metrics provide a direct view of the delivery experience associated with each customer relationship.

Churn and Retention Analysis

### 8. Churn Definition

Customers are classified based on recency.

Active Customer:  Recency is 365 days or fewer
Churned Customer: Recency is greater than 365 days

The churn analysis is combined with RFM and delivery-performance information in:

customer_churn_analysis

This integrated customer-level view includes:

- RFM metrics

- RFM scores

- RFM segment

- Churn status

- Total orders

- Late orders

- Late-delivery rate

- Average delivery delay

- Maximum delivery delay

- Canceled orders

- Cancellation rate

- Actual and scheduled shipping duration

### 9. Retention Priority Analysis

The project identifies active customers who are approaching churn and evaluates their customer value and delivery exposure.

The retention-priority analysis focuses on customers with:

- High monetary value
- High delivery-delay exposure
- High cancellation exposure
- Recency close to the churn threshold

This allows the business to identify customers who are still active but may require proactive retention action.

Customer Segmentation and Risk Analysis

### 10. Customer Value and Delay Segmentation

Customers are segmented according to their sales value and delivery-delay rate.

The segmentation creates four customer groups:

- High Value / High Delay
- High Value / Low Delay
- Low Value / High Delay
- Low Value / Low Delay

This framework helps identify customers who are commercially valuable but operationally vulnerable.

## Key Finding

The High Value / High Delay segment represents:

- 21.75% of customers
- Approximately $4.99M in delayed-sales exposure

This segment is a major priority because it combines high customer value with consistently poor delivery performance.

### 11. Customer-Risk Prioritisation

Customer risk is evaluated using multiple customer-level indicators:

- Delivery-delay rate

- Severe-delay exposure

- Delayed-sales exposure

- Order volume

#### Customers are grouped into:

- Critical Customer Risk
- High Customer Risk
- Moderate Customer Risk
- Lower Customer Risk

## Key Finding

Only 6.69% of customers are classified as Critical or High Customer Risk, but these groups account for approximately:

$1.70M in delayed-sales exposure

This indicates that a relatively small group of customers deserves focused service-recovery and retention efforts.

## Results

The project generates customer-value, churn, delivery-performance, and customer-risk insights.

The main result categories include:

### Customer Value Results

- RFM customer scores
- RFM customer segments
- High-value customer groups
- Repeat versus one-time customer analysis
- Customer monetary-value distribution
- Customer purchase-frequency distribution
- Customer recency distribution

### Churn Results

- Active customer population
- Churned customer population
- Churn rate by RFM segment
- High-value churned customers
- Active customers approaching churn
- Retention-priority customer groups

### Delivery Performance Results

- Late-delivery rate
- Cancellation rate
- Average delivery delay
- Maximum delivery delay
- Delivery-delay exposure groups
- Customer-level supply-chain metrics

### Customer-Risk Results

- Customer value versus delay segmentation
- High Value / High Delay priority pool
- Top high-risk customers
- Customer-risk categories
- Delayed-sales exposure by customer-risk category

## Key Technical Contribution

The main technical contribution of this project is the integration of customer analytics and supply-chain performance into one PostgreSQL workflow.

The project transforms operational transaction data into a structured customer-intelligence process:

```text
Raw Transaction and Shipping Data
                ↓
Relational Data Modelling
                ↓
Data Quality Validation
                ↓
Customer-Order Analysis Base
                ↓
RFM Segmentation
                ↓
Delivery and Cancellation Metrics
                ↓
Churn Classification
                ↓
Retention Priority Analysis
                ↓
Customer-Risk Prioritisation
                ↓
Business Recommendations
```
This demonstrates the practical use of SQL for both customer analytics and operational decision support.

### Technologies and Skills Demonstrated

- PostgreSQL

- SQL

- Relational database design

- Data normalisation

- Data quality validation

- Primary-key and foreign-key validation

- SQL joins

- Common Table Expressions

- Views

- Aggregations

- Conditional logic using CASE

- Window functions

- Percentile calculations

- RFM segmentation

- Customer segmentation

- Churn analysis

- Retention analysis

- Delivery-performance analysis

- Supply-chain analytics

- Customer-risk analysis

- Business insight generation

- GitHub Desktop

- Data privacy and responsible data handling

## Repository Structure
```text
ecommerce-customer-intelligence/
│
├── README.md
├── .gitignore
│
├── data/
│   ├── derived/
│   │   └── README.md
│   └── sample/
│       └── README.md
│
├── docs/
│   ├── methodology.md
│   └── data_privacy.md
│
├── sql/
│   ├── 02_data_validation_and_preparation.sql
│   ├── 03_customer_order_base.sql
│   ├── 04_valid_customer_orders.sql
│   └── 05_rfm_churn_supply_chain_analysis.sql
│
└── visuals/
    └── README.md
```

## Data Privacy

This repository includes SQL scripts, project documentation, methodology, and safe aggregate-level findings.

The following are intentionally excluded:

- Raw transaction data

- Customer names

- Customer emails

- Customer addresses

- Customer passwords

- Database credentials

- PostgreSQL backups and dumps

- Unreviewed customer-level exports

- Sensitive or personally identifiable information

- For more information, see docs/data_privacy.md.

- Future Improvements

- Add final geographic-analysis SQL and visualisations.

- Add customer-risk-ranking SQL as a separate reproducible module.

- Add safe aggregated result files to data/derived.

- Add presentation-ready delivery and churn visualisations.

- Build an interactive dashboard for customer-value and delivery-risk monitoring.

- Compare customer-risk groups across geography, product categories, and shipping modes.

- Automate the complete pipeline for scheduled customer-risk reporting.

## Skills Demonstrated

PostgreSQL • SQL • Data Validation • Relational Database Design • Customer Analytics • RFM Segmentation • Churn Analysis • Retention Analysis • Delivery Performance • Supply-Chain Analytics • Customer Segmentation • Customer-Risk Prioritisation • Business Analytics • GitHub Desktop

# Future Improvements

The following enhancements are planned for the next phase of the project:

- Add final geographic-analysis SQL and visualisations.
- Add the customer-risk-ranking SQL as a separate reproducible module.
- Export safe aggregated result files to `data/derived`.
- Add presentation-ready charts for RFM segments, churn, delivery performance, and customer risk.
- Build an interactive dashboard for customer-value and delivery-risk monitoring.
- Compare customer risk across geography, product categories, and shipping modes.
- Automate the analysis pipeline for periodic customer-risk reporting.