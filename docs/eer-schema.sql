-- Restaurant and Event Management System Database Schema
-- MS SQL Server

-- Users table (customers, staff, admins)
CREATE TABLE [User] (
                        user_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('CUSTOMER', 'CHEF', 'WAITER', 'MANAGER', 'ADMIN')),
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    phone NVARCHAR(20),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
    );

-- Food items table
CREATE TABLE Food (
                      food_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                      name NVARCHAR(100) NOT NULL,
                      price DECIMAL(10,2) NOT NULL CHECK (price > 0),
                      category NVARCHAR(50) NOT NULL,
                      availability BIT DEFAULT 1,
                      description NVARCHAR(500),
                      created_at DATETIME2 DEFAULT GETDATE(),
                      updated_at DATETIME2 DEFAULT GETDATE()
);

-- Orders table
CREATE TABLE [Order] (
                         order_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATETIME2 DEFAULT GETDATE(),
    status NVARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'DELIVERED', 'CANCELLED')),
    payment_status NVARCHAR(20) DEFAULT 'UNPAID' CHECK (payment_status IN ('UNPAID', 'PAID', 'REFUNDED')),
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES [User](user_id) ON DELETE CASCADE
    );

-- Order items table
CREATE TABLE Order_Item (
                            order_item_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                            order_id BIGINT NOT NULL,
                            food_id BIGINT NOT NULL,
                            quantity INT NOT NULL CHECK (quantity > 0),
                            price DECIMAL(10,2) NOT NULL CHECK (price > 0),
                            created_at DATETIME2 DEFAULT GETDATE(),
                            FOREIGN KEY (order_id) REFERENCES [Order](order_id) ON DELETE CASCADE,
                            FOREIGN KEY (food_id) REFERENCES Food(food_id) ON DELETE CASCADE
);

-- Events table
CREATE TABLE Event (
                       event_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                       customer_id BIGINT NOT NULL,
                       date DATE NOT NULL,
                       time TIME NOT NULL,
                       description NVARCHAR(1000),
                       status NVARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
                       assigned_staff BIGINT,
                       created_at DATETIME2 DEFAULT GETDATE(),
                       updated_at DATETIME2 DEFAULT GETDATE(),
                       FOREIGN KEY (customer_id) REFERENCES [User](user_id) ON DELETE CASCADE,
                       FOREIGN KEY (assigned_staff) REFERENCES [User](user_id) ON DELETE SET NULL
);

-- Promotions table
CREATE TABLE Promotion (
                           promotion_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                           title NVARCHAR(200) NOT NULL,
                           description NVARCHAR(1000),
                           discount_percentage DECIMAL(5,2) CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
                           start_date DATETIME2 NOT NULL,
                           end_date DATETIME2 NOT NULL,
                           status NVARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'EXPIRED')),
                           created_at DATETIME2 DEFAULT GETDATE(),
                           updated_at DATETIME2 DEFAULT GETDATE(),
                           CHECK (end_date > start_date)
);

-- Promotion-Food relationship table (many-to-many)
CREATE TABLE Promotion_Food (
                                promotion_id BIGINT NOT NULL,
                                food_id BIGINT NOT NULL,
                                PRIMARY KEY (promotion_id, food_id),
                                FOREIGN KEY (promotion_id) REFERENCES Promotion(promotion_id) ON DELETE CASCADE,
                                FOREIGN KEY (food_id) REFERENCES Food(food_id) ON DELETE CASCADE
);

-- Ingredients table
CREATE TABLE Ingredient (
                            ingredient_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                            name NVARCHAR(100) NOT NULL UNIQUE,
                            quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
                            availability BIT DEFAULT 1,
                            unit NVARCHAR(20), -- kg, liters, pieces, etc.
                            minimum_stock DECIMAL(10,2) DEFAULT 0,
                            created_at DATETIME2 DEFAULT GETDATE(),
                            updated_at DATETIME2 DEFAULT GETDATE()
);

-- Suppliers table
CREATE TABLE Supplier (
                          supplier_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                          name NVARCHAR(100) NOT NULL,
                          contact_info NVARCHAR(500) NOT NULL, -- Can store phone, email, address as JSON or separate fields
                          email NVARCHAR(100),
                          phone NVARCHAR(20),
                          address NVARCHAR(255),
                          created_at DATETIME2 DEFAULT GETDATE(),
                          updated_at DATETIME2 DEFAULT GETDATE()
);

-- Supplier requests table
CREATE TABLE Supplier_Request (
                                  request_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                  supplier_id BIGINT NOT NULL,
                                  ingredient_id BIGINT NOT NULL,
                                  quantity_requested DECIMAL(10,2) NOT NULL CHECK (quantity_requested > 0),
                                  status NVARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'DELIVERED', 'REJECTED')),
                                  request_date DATETIME2 DEFAULT GETDATE(),
                                  delivery_date DATETIME2,
                                  notes NVARCHAR(500),
                                  created_at DATETIME2 DEFAULT GETDATE(),
                                  updated_at DATETIME2 DEFAULT GETDATE(),
                                  FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE CASCADE,
                                  FOREIGN KEY (ingredient_id) REFERENCES Ingredient(ingredient_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX IX_Order_customer_id ON [Order](customer_id);
CREATE INDEX IX_Order_order_date ON [Order](order_date);
CREATE INDEX IX_Order_Item_order_id ON Order_Item(order_id);
CREATE INDEX IX_Order_Item_food_id ON Order_Item(food_id);
CREATE INDEX IX_Event_customer_id ON Event(customer_id);
CREATE INDEX IX_Event_date ON Event(date);
CREATE INDEX IX_Event_assigned_staff ON Event(assigned_staff);
CREATE INDEX IX_Promotion_start_date_end_date ON Promotion(start_date, end_date);
CREATE INDEX IX_Supplier_Request_supplier_id ON Supplier_Request(supplier_id);
CREATE INDEX IX_Supplier_Request_ingredient_id ON Supplier_Request(ingredient_id);

-- Insert sample data for testing
INSERT INTO [User] (username, password, role, name, email, phone) VALUES
    ('admin', '$2a$10$encoded_password_here', 'ADMIN', 'System Admin', 'admin@restaurant.com', '1234567890'),
    ('chef1', '$2a$10$encoded_password_here', 'CHEF', 'John Chef', 'chef@restaurant.com', '1234567891'),
    ('customer1', '$2a$10$encoded_password_here', 'CUSTOMER', 'Jane Doe', 'jane@email.com', '1234567892');

INSERT INTO Food (name, price, category, availability, description) VALUES
                                                                        ('Margherita Pizza', 12.99, 'PIZZA', 1, 'Classic pizza with tomato sauce and mozzarella'),
                                                                        ('Caesar Salad', 8.99, 'SALAD', 1, 'Fresh romaine lettuce with Caesar dressing'),
                                                                        ('Grilled Chicken', 15.99, 'MAIN', 1, 'Perfectly grilled chicken breast');

INSERT INTO Ingredient (name, quantity, unit, minimum_stock) VALUES
                                                                 ('Tomatoes', 50.0, 'kg', 10.0),
                                                                 ('Mozzarella Cheese', 20.0, 'kg', 5.0),
                                                                 ('Chicken Breast', 30.0, 'kg', 8.0);

INSERT INTO Supplier (name, contact_info, email, phone, address) VALUES
                                                                     ('Fresh Foods Ltd', 'Main supplier for vegetables', 'orders@freshfoods.com', '555-0123', '123 Supply St, City'),
                                                                     ('Dairy Express', 'Cheese and dairy products', 'sales@dairyexpress.com', '555-0124', '456 Dairy Ave, City');