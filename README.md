<div align="center">

E-Commerce Customer Intelligence

RFM Segmentation · Churn Analysis · Delivery Performance · Customer Risk



</div>

A PostgreSQL analytics project that transforms e-commerce transaction and delivery data into practical insights for customer retention, service recovery, and operational-risk prioritisation.

Project Overview

E-commerce performance depends on more than sales alone. High-value customers can be lost when delivery delays, cancellations, and poor fulfilment experiences are not identified early.

This project analyses customer purchase behaviour, delivery performance, churn risk, and delayed-sales exposure using PostgreSQL. It provides a structured way to identify valuable customers, measure operational service risk, and support targeted retention actions.

Business question: How can an e-commerce business protect customer value by identifying churn risk and delivery-related service failures before revenue is lost?

Business Objectives

Segment customers using Recency, Frequency, and Monetary value (RFM).

Identify customers who have churned and active customers approaching churn.

Analyse the relationship between delivery delays, cancellations, and customer churn.

Quantify delayed-sales exposure across customer groups.

Prioritise high-risk customers for retention and service-recovery actions.

Support data-driven customer-service and fulfilment decisions.

Technology Stack

Technology

Usage in this project

PostgreSQL

Data modelling, joins, views, CTEs, aggregation, percentile scoring, and SQL analysis

pgAdmin

Query development, database management, and results validation

GitHub Desktop

Version control and repository publishing

End-to-End Analytics Workflow

flowchart TB
    A["Local e-commerce source data"] --> B["Normalised PostgreSQL tables"]
    B --> C["Data-quality validation"]
    C --> D["Customer-order analysis base"]
    D --> E["RFM segmentation"]
    D --> F["Delivery-delay and cancellation analysis"]
    E --> G["Churn and retention analysis"]
    F --> G
    G --> H["Customer-risk prioritisation"]
    H --> I["Business recommendations"]

Data Model

The source data is normalised into six core PostgreSQL tables:

Table

Description

customers

Customer segment and geographic information

orders

Order-level transaction and location details

order_items

Product, quantity, sales, discount, and profit information

products

Product, price, department, and category attributes

categories

Product-category reference information

shipping

Shipping mode, delivery status, and delivery-duration information

The following analytical tables and views are then created:

customer_order_base
valid_customer_orders
customer_rfm_base
order_shipping_base
customer_supply_chain_base
customer_churn_analysis

Methodology

1. Valid Purchase Identification

Only completed customer purchases are included in the RFM and churn analysis.

Valid purchase = Order status is COMPLETE or CLOSED

2. Delivery Performance Analysis

Delivery Delay = Actual Shipping Days − Scheduled Shipping Days

Customer-level metrics include:

Total orders

Late orders

Late-delivery rate

Average delivery delay

Maximum delivery delay

Canceled orders

Cancellation rate

Actual versus scheduled shipping duration

3. RFM Customer Segmentation

RFM Metric

Definition

Recency

Days since a customer's most recent valid purchase

Frequency

Number of distinct valid orders placed by a customer

Monetary

Total sales generated from valid purchases

Percentile-based scoring assigns Recency, Frequency, and Monetary scores from 1 to 5. Customers are then grouped into meaningful segments such as:

Champions

Loyal Customers

Potential Loyalists

New Customers

At Risk

High-Value Churned

Hibernating

Need Attention

4. Churn Classification

Customer Status

Definition

Active

Customer recency is 365 days or fewer

Churned

Customer recency is greater than 365 days

5. Customer-Risk Prioritisation

Customer risk is evaluated using delivery-delay rate, severe-delay exposure, delayed-sales exposure, and order volume. This approach helps distinguish customers who are operationally vulnerable from those who require routine monitoring.

Key Findings

Insight

Business Impact

21.75% of customers are in the High Value / High Delay segment

This group has approximately $4.99M in delayed-sales exposure

Only 6.69% of customers are Critical or High Risk

They account for approximately $1.70M in delayed-sales exposure

High-risk customers have extremely high delay rates

Proactive service recovery is required to protect customer value

Valuable active customers are approaching churn

Retention campaigns can be targeted before customers become inactive

Business Recommendations

Prioritise high-value customers with recurring delivery delays for proactive customer support and service recovery.

Target active customers nearing the churn threshold with relevant retention offers and follow-up communication.

Investigate fulfilment bottlenecks in customer groups or locations with high delayed-sales exposure.

Use customer-risk categories to focus limited operations and customer-support capacity.

Measure delivery reliability alongside sales value to avoid losing valuable customers because of service failures.

Repository Structure

ecommerce-customer-intelligence/
├── README.md
├── .gitignore
├── data/
│   ├── derived/
│   │   └── README.md
│   └── sample/
│       └── README.md
├── docs/
│   ├── methodology.md
│   └── data_privacy.md
├── sql/
│   ├── 02_data_validation_and_preparation.sql
│   ├── 03_customer_order_base.sql
│   ├── 04_valid_customer_orders.sql
│   └── 05_rfm_churn_supply_chain_analysis.sql
└── visuals/
    └── README.md

How to Run the Project

Load the original source data into a local PostgreSQL database.

Run the SQL scripts in numerical order.

Review the data-validation output before proceeding to RFM and churn analysis.

Use the final customer-level analysis view to evaluate customer value, churn, delivery performance, and retention priorities.

The raw source data is intentionally excluded from this repository.

Data Privacy

This repository contains SQL scripts, methodology, documentation, and safe aggregate-level findings only.

The following are deliberately excluded:

Raw transaction datasets

Customer names, emails, addresses, phone numbers, and passwords

Database credentials and environment files

PostgreSQL backup files

Unreviewed customer-level result exports

See docs/data_privacy.md for the full policy.

Future Enhancements

Add geographic delayed-sales analysis and visualisations.

Add customer-risk-ranking SQL and summary outputs.

Add anonymised aggregate results to data/derived.

Build an interactive dashboard for customer-value and delivery-risk monitoring.

<div align="center">

Your NameAspiring Data Analyst · PostgreSQL · Customer Analytics · Supply-Chain Analytics

</div>