# E-Commerce Data Analysis – Data Preparation

## Objective

Prepare a structured and reliable dataset for analyzing an e-commerce platform, focusing on orders, customers, products, and payments.

---

## Dataset

The project uses the **Olist E-Commerce dataset** (Kaggle).

The dataset contains transactional data including:

- orders  
- order items  
- products  
- customers  
- payments  

---

## Data Structure Overview

The dataset follows a relational structure with multiple one-to-many relationships:

- one order → multiple order items  
- one order → multiple payments  
- one customer (real-world) → multiple orders  

Key modeling detail:

- `customer_id` represents an order-level customer record  
- `customer_unique_id` represents the actual customer across multiple orders  

---

## Data Preparation Approach

The data preparation process was structured into four main steps:

### 1. Raw Data Ingestion

- Source CSV files were imported into a `raw` schema  
- All columns were stored as `TEXT` to ensure lossless ingestion  
- No transformations were applied at this stage  

---

### 2. Data Understanding

The dataset was explored to understand:

- table relationships  
- primary and foreign keys  
- data granularity  
- potential data quality issues  

Key observations:

- multiple timestamp fields represent different stages of the order lifecycle  
- order items are stored at item-level (multiple rows per order)  
- payments can be split across multiple payment methods per order  
- product data contains missing values, especially in category and descriptive fields  

---

### 3. Data Cleaning and Transformation

Cleaned tables were created in an `analytics` schema.

Transformations included:

- casting timestamps to appropriate `TIMESTAMP` types  
- converting numeric fields (e.g. price, payment_value) to `NUMERIC`  
- converting integer-like fields (e.g. quantities, dimensions) to `INT`  
- correcting column naming inconsistencies (e.g. `lenght` → `length`)  

No business logic or data imputation (e.g. replacing NULL values) was applied at this stage to preserve original data integrity.

---

### 4. Data Validation

To ensure data consistency:

- row counts between raw and cleaned tables were compared  
- referential integrity was validated using orphan checks  

Validated relationships include:

- orders → customers  
- order_items → orders  
- order_items → products  
- order_payments → orders  

Primary keys and foreign key constraints were added after validation to enforce consistency and improve query performance.

---

## Design Decisions

- Raw data remains unchanged to preserve traceability  
- Cleaning focuses on structure and data types, not interpretation  
- Business logic (e.g. handling missing categories) is deferred to the analysis phase  
- Referential integrity is explicitly validated before applying constraints  

---

## Current Status

The dataset is now:

- structurally consistent  
- type-safe  
- relationally validated  

and ready for analytical queries.

---

## Next Steps

- define analysis objectives  
- perform SQL-based analysis  
- build visualizations in Excel  
- derive business insights  