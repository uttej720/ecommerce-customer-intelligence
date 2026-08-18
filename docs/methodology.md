Methodology

Project objective

This project uses PostgreSQL to analyse e-commerce customer behaviour, purchase value, delivery performance, churn risk, and retention priorities.

The analysis is designed to help answer practical business questions:

Which customers are most valuable?

Which customers are likely to churn?

How do late deliveries and cancellations relate to customer risk?

Which customer groups require the highest-priority intervention?

Data preparation

The source data is organised into six core PostgreSQL tables:

customers

orders

order_items

products

categories

shipping

These tables are joined into an analytics-ready order-level table named customer_order_base.

A transaction is considered a valid purchase only when its order status is:

COMPLETE

CLOSED

Delivery-performance measures

The project evaluates delivery performance using the following measures:

Delivery delay: Actual shipping days minus scheduled shipping days.

Late delivery flag: A value of 1 when the source delivery status is Late delivery.

Cancellation flag: A value of 1 when the source delivery status is Shipping canceled.

Late-delivery rate: Percentage of a customer's orders classified as late.

Cancellation rate: Percentage of a customer's orders classified as canceled.

RFM segmentation

Customer value is measured using RFM analysis:

Recency: Days since the customer's most recent valid purchase.

Frequency: Number of distinct valid orders placed by the customer.

Monetary: Total sales generated from valid purchases.

Percentile-based scoring assigns Recency, Frequency, and Monetary scores from 1 to 5. These scores are combined to create customer segments such as:

Champions

Loyal Customers

Potential Loyalists

New Customers

At Risk

High-Value Churned

Hibernating

Need Attention

Churn definition

A customer is classified as:

Active when recency is 365 days or fewer.

Churned when recency is greater than 365 days.

This rule provides a consistent basis for comparing customer value, delivery experience, cancellations, and churn outcomes.

Customer-risk analysis

The customer-risk framework prioritises customers based on:

Delivery-delay rate

Severe delivery-delay exposure

Delayed-sales exposure

Order volume

The framework identifies Critical, High, Moderate, and Lower customer-risk groups to support targeted retention, customer-service, and operational-improvement actions.

Validation approach

The analysis includes checks for:

Duplicate primary keys

Missing values in key fields

Orphaned foreign-key relationships

Invalid or inconsistent order and shipping records

Customer and order population reconciliation

Delay-calculation validation

RFM and churn population reconciliation

These checks improve the reliability of the results before business insights are produced.