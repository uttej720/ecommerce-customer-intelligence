Data Privacy and Repository Policy

Purpose

This repository is a portfolio project created to demonstrate PostgreSQL, customer analytics, RFM segmentation, churn analysis, delivery-performance analysis, and customer-risk prioritisation.

It is designed to share the analytical approach without publishing private or sensitive source data.

Included in this repository

The repository may include:

SQL scripts written for the project

Documentation and methodology

Aggregated and reviewed summary results

Safe visualisations and charts

An anonymised sample dataset, if created and reviewed

Non-identifying result tables such as segment-level or region-level summaries

Excluded from this repository

The repository must never include:

Raw transaction datasets

Customer names, emails, phone numbers, or street addresses

Password fields or authentication information

Customer-level records that could identify an individual

Database credentials or connection strings

.env files

PostgreSQL backup or dump files

Unreviewed CSV exports

Screenshots containing raw records or personal information

Raw-data handling

Raw data remains local and is not published to GitHub.

The project’s .gitignore file is configured to prevent raw data, backups, credentials, and unreviewed CSV files from being committed accidentally.

Derived-data handling

Only reviewed, aggregated, non-identifying outputs may be added to the data/derived folder.

Before adding any result file, confirm that it contains no personal information, confidential fields, database credentials, or row-level records that should remain private.

Responsible use

All findings in this project are presented as analytical observations based on the available data. They should be used to support business investigation and decision-making, not as proof of causation.