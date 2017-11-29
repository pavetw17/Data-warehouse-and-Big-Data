# Data-warehouse-and-Big-Data
Building and Analysing a DW for NatureFresh Stores in NZ

## Getting Started
To design, implement and analyse a Data Warehouse (DW) for NatureFresh, one of the biggest
supermarket chains in NZ.

### Prerequisites
This code will run smothly on Oracle Database.

## Deployment
1. Read 50 tuples from TRANSACTIONS table as input data into a cursor. The cursor is a user
defined data type in PLSQL which works as a list and is used to store multiple records in
memory for processing.
2. Read the cursor tuple by tuple and for each tuple retrieve the relevant tuple from
MASTERDATA table using PRODUCT_ID as an index and add the required attributes
(mentioned in Figure 2) into the transaction tuple (in memory).
3. The transaction tuple with new attributes is to be loaded into DW. Before loading the tuple
into DW you will check whether the dimension tables already contain this information. If
yes, then only update the fact table otherwise update the required dimension tables and
the fact table.
4. Repeat steps 1 to 3 until you load all the data from TRANSACTIONS table to DW

## DW analysis (OLAP queries)
Once the entire transactions data has been loaded into DW, apply the following analysis to
your DW using OLAP queries.

Q1 Which product produced highest sales in the whole year?

Q2 Determine the top 3 supplier names in Aug 2016 in terms of total sales.

Q3 Determine the top 3 store names in Aug 2016 in terms of total sales.

Q4 How many sales transactions were there for the product that generated maximum sales
revenue in 2016? Also present the product quantity sold.

Q5 Present the quarterly sales analysis for all products using drill down query concepts,
resulting in a report that looks like:
PRODUCT_NAME          Q1_2016   Q2_2016    Q3_2016    Q4_2016

‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐‐

Q6 Create a materialised view with name “STOREANALYSIS_MV” that presents the
product‐wise sales analysis for each store.
STORE_ID       PROD_ID      STORE_TOTAL

‐‐‐‐‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐‐‐‐ ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐

Q7. Think about what other information can be retrieved from this materialised view from Q6
using ROLLUP or CUBE concepts and provide some useful information of your choice for
management
