E-Commerce Customer Intelligence

PostgreSQL Analysis of Customer Value, Churn, Delivery Performance and Risk

An end-to-end SQL analytics project that converts e-commerce order and shipping data into actionable customer-retention and operational-risk insights.

Overview

This project analyses e-commerce customer behaviour and delivery performance using PostgreSQL. It combines transaction, product, customer, order, and shipping data to identify valuable customers, assess churn risk, evaluate delivery failures, and prioritise customer groups for intervention.

The project focuses on the practical business question:

How can an e-commerce business protect customer value by identifying churn risk and delivery-related service failures early?

Business objectives

Segment customers using Recency, Frequency and Monetary value (RFM).

Identify customers who have churned and active customers approaching churn.

Measure the effect of late deliveries and shipment cancellations at customer level.

Quantify delayed-sales exposure across customer groups.

Prioritise high-risk customers for retention and service-recovery actions.

Tools used

Tool

Purpose

PostgreSQL

Data modelling, SQL analysis, joins, views, CTEs, aggregations, validation, and percentile calculations

pgAdmin

Query development, testing, and result validation

GitHub Desktop

Version control and repository publishing

Analytics workflow

flowchart TB
    A["Local e-commerce source data"] --> B["Normalised PostgreSQL tables"]
    B --> C["Data-quality validation"]
    C --> D["Customer-order analysis base"]
    D --> E["RFM customer segmentation"]
    D --> F["Delivery-delay and cancellation metrics"]
    E --> G["Churn and retention analysis"]
    F --> G
    G --> H["Customer-risk prioritisation and business recommendations"]

Data model

The analysis uses six normalised PostgreSQL tables:

Table

Description

customers

Customer segment and geographic attributes

orders

Order-level transaction and location information

order_items

Product, quantity, sales, discount, and profit details

products

Product, price, department, and category attributes

categories

Product-category reference data

shipping

Delivery status, shipping mode, and actual versus scheduled delivery duration

These tables support the creation of analytics-ready customer and order views, including:

customer_order_base

valid_customer_orders

customer_rfm_base

order_shipping_base

customer_supply_chain_base

customer_churn_analysis

Methodology

Valid-purchase rule

Only orders with the following status values are treated as valid purchases:

COMPLETE
CLOSED

Delivery-performance measures

Delivery Delay = Actual Shipping Days − Scheduled Shipping Days

The project also identifies:

Late deliveries using the source delivery-status field.

Canceled shipments using the source delivery-status field.

Late-delivery rate at customer level.

Cancellation rate at customer level.

Average and maximum delivery delay at customer level.

RFM analysis

Customer value is measured through:

Metric

Definition

Recency

Days since the customer's latest valid purchase

Frequency

Number of distinct valid orders

Monetary

Total sales from valid purchases

Percentile-based RFM scores are used to identify segments such as:

Champions

Loyal Customers

Potential Loyalists

New Customers

At Risk

High-Value Churned

Hibernating

Need Attention

Churn definition

Status

Rule

Active

Recency is 365 days or fewer

Churned

Recency is greater than 365 days

Key findings

The High Value / High Delay segment represents 21.75% of customers and is associated with approximately $4.99M in delayed-sales exposure.

Only 6.69% of customers are classified as Critical or High Customer Risk, but they account for approximately $1.70M in delayed-sales exposure.

High-risk customers show very high delivery-delay rates, indicating a strong need for proactive service recovery.

Active, high-value customers nearing the churn threshold represent an important retention opportunity.

Business recommendations

Prioritise high-value customers experiencing repeated delivery delays for proactive support and service recovery.

Use churn indicators to target valuable active customers before they become inactive.

Investigate geographical areas or fulfilment processes with high delayed-sales exposure.

Allocate customer-support and operational resources according to customer-risk category.

Evaluate delivery reliability alongside sales value when making retention decisions.

Repository structure

ecommerce-customer-intelligence/
├── README.md
├── .gitignore
├── data/
│   ├── derived/
│   └── sample/
├── docs/
│   ├── methodology.md
│   └── data_privacy.md
├── sql/
│   ├── 02_data_validation_and_preparation.sql
│   ├── 03_customer_order_base.sql
│   ├── 04_valid_customer_orders.sql
│   └── 05_rfm_churn_supply_chain_analysis.sql
└── visuals/

Running the project

Load the original source data into a local PostgreSQL database.

Run the SQL files in their numbered order.

Review data-validation outputs before moving to customer-value and churn analysis.

Use the final customer-level views to analyse RFM segments, churn, delivery performance, and retention priorities.

The raw source dataset is intentionally not included in this repository.

Data privacy

This repository contains SQL scripts, methodology, and safe aggregate-level findings only.

It does not contain:

Raw transaction data

Customer names, emails, addresses, phone numbers, or passwords

Database credentials or environment files

PostgreSQL backup files

Unreviewed customer-level exports

For details, see docs/data_privacy.md.

Future improvements

Add final geographic-analysis SQL and visualisations.

Add customer-risk-ranking SQL and summary outputs.

Build an interactive dashboard for ongoing customer-risk monitoring.

Add anonymised aggregate result files to data/derived.

Author

Mandadapu Uttej Srinivasa Rao | Aspiring Data Analyst | PostgreSQL | Customer Analytics | Supply-Chain Analytics