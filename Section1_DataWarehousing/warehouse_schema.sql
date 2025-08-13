-- =============================================================================
-- DSA 2040 Practical Exam - Section 1, Task 1
-- Data Warehouse Schema Design
-- Student: Monaheng218
-- Date: August 13, 2025
-- =============================================================================

-- FACT TABLE: SalesFact
-- Contains transactional sales data with measures and foreign keys
CREATE TABLE SalesFact (
    SalesKey INTEGER PRIMARY KEY,         -- Unique transaction identifier
    InvoiceNo TEXT NOT NULL,             -- Original invoice number
    CustomerKey INTEGER NOT NULL,        -- Foreign key to CustomerDim
    ProductKey INTEGER NOT NULL,         -- Foreign key to ProductDim  
    TimeKey INTEGER NOT NULL,            -- Foreign key to TimeDim
    Quantity INTEGER NOT NULL,           -- Measure: Quantity of items sold
    UnitPrice DECIMAL(10,2) NOT NULL,    -- Measure: Unit price
    TotalSales DECIMAL(10,2) NOT NULL,   -- Measure: Total sales amount
    
    -- Foreign key constraints
    FOREIGN KEY (CustomerKey) REFERENCES CustomerDim(CustomerKey),
    FOREIGN KEY (ProductKey) REFERENCES ProductDim(ProductKey),
    FOREIGN KEY (TimeKey) REFERENCES TimeDim(TimeKey)
);

-- DIMENSION TABLE: CustomerDim
-- Contains customer information and demographics
CREATE TABLE CustomerDim (
    CustomerKey INTEGER PRIMARY KEY,     -- Unique customer identifier
    CustomerID INTEGER NOT NULL,        -- Original customer ID
    Country TEXT NOT NULL               -- Customer country/location
);

-- DIMENSION TABLE: ProductDim  
-- Contains product catalog information
CREATE TABLE ProductDim (
    ProductKey INTEGER PRIMARY KEY,      -- Unique product identifier
    StockCode TEXT NOT NULL,            -- Original product stock code
    Description TEXT NOT NULL,          -- Product name/description
    Category TEXT NOT NULL             -- Product category
);

-- DIMENSION TABLE: TimeDim
-- Contains time hierarchy for temporal analysis
CREATE TABLE TimeDim (
    TimeKey INTEGER PRIMARY KEY,        -- Unique time identifier
    Date DATE NOT NULL,                 -- Full date (YYYY-MM-DD)
    Year INTEGER NOT NULL,              -- Year (e.g., 2025)
    Month INTEGER NOT NULL,             -- Month (1-12)
    Day INTEGER NOT NULL,               -- Day (1-31)
    Quarter INTEGER NOT NULL,           -- Quarter (1-4)
    DayOfWeek INTEGER NOT NULL,          -- Day of week (1-7)
    MonthName TEXT NOT NULL,             -- Month name (January, February, etc.)
    DayName TEXT NOT NULL                -- Day name (Monday, Tuesday, etc.)
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =============================================================================

-- Indexes on fact table foreign keys for faster joins
CREATE INDEX idx_salesfact_customerkey ON SalesFact(CustomerKey);
CREATE INDEX idx_salesfact_productkey ON SalesFact(ProductKey);
CREATE INDEX idx_salesfact_timekey ON SalesFact(TimeKey);

-- Indexes on dimension attributes commonly used in WHERE clauses
CREATE INDEX idx_customer_country ON CustomerDim(Country);
CREATE INDEX idx_product_category ON ProductDim(Category);
CREATE INDEX idx_time_year ON TimeDim(Year);
CREATE INDEX idx_time_quarter ON TimeDim(Quarter);
CREATE INDEX idx_time_month ON TimeDim(Month);

-- =============================================================================
-- SAMPLE QUERIES TO TEST SCHEMA
-- =============================================================================

-- Query 1: Total sales by product category per quarter
SELECT 
    p.Category,
    t.Year,
    t.Quarter,
    SUM(s.TotalSales) as TotalSales,
    COUNT(s.SalesKey) as TransactionCount
FROM SalesFact s
JOIN ProductDim p ON s.ProductKey = p.ProductKey
JOIN TimeDim t ON s.TimeKey = t.TimeKey
GROUP BY p.Category, t.Year, t.Quarter
ORDER BY t.Year, t.Quarter, TotalSales DESC;

-- Query 2: Customer demographics analysis
SELECT 
    c.Country,
    COUNT(DISTINCT c.CustomerID) as CustomerCount,
    SUM(s.TotalSales) as TotalRevenue,
    AVG(s.TotalSales) as AvgTransactionValue
FROM CustomerDim c
JOIN SalesFact s ON c.CustomerKey = s.CustomerKey
GROUP BY c.Country
ORDER BY TotalRevenue DESC;

-- Query 3: Inventory trends by product category
SELECT 
    p.Category,
    t.Year,
    t.Month,
    SUM(s.Quantity) as UnitsSold,
    COUNT(DISTINCT s.ProductKey) as UniqueProducts
FROM SalesFact s
JOIN ProductDim p ON s.ProductKey = p.ProductKey
JOIN TimeDim t ON s.TimeKey = t.TimeKey
GROUP BY p.Category, t.Year, t.Month
ORDER BY t.Year, t.Month, UnitsSold DESC;
