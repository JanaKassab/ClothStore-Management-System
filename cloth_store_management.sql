-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Feb 24, 2025 at 09:49 PM
-- Server version: 8.3.0
-- PHP Version: 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cloth_store_management`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `Delete_Customer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_Customer` (IN `C_ID_val` INT)   BEGIN
    DECLARE done INT DEFAULT 0;
    
    -- Declare variables
    DECLARE C_ID INT;
    DECLARE First_Name VARCHAR(50);
    DECLARE Last_Name VARCHAR(50);
    DECLARE Qualification VARCHAR(20);
    DECLARE ADDRESS VARCHAR(50);
    DECLARE Locality VARCHAR(20);
    DECLARE CITY VARCHAR(20);
    DECLARE Email VARCHAR(50);
    DECLARE Phone_NO VARCHAR(10);
    DECLARE DOP DATE;
    DECLARE E_ID INT;
    DECLARE Item_ID INT;
    DECLARE Price FLOAT;
    DECLARE Quantity INT;
    DECLARE O_Amount FLOAT;

    -- Declare Cursor
    DECLARE cur CURSOR FOR 
        SELECT C.C_ID, C.C_FIRST_NAME, C.C_LAST_NAME, C.Qualification,
               C.C_ADDRESS, C.Locality, C.City, C.Email, C.C_Phone_NO, C.DOP, C.E_ID,
               O.Item_ID, O.Price, O.Quantity, O.O_Amount
        FROM Customers AS C
        JOIN Orders AS O ON C.C_ID = O.C_ID
        WHERE C.C_ID = C_ID_val;

    -- Handle case when no rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open Cursor
    OPEN cur;

    -- Start Loop
    read_loop: LOOP
        -- Fetch data
        FETCH cur INTO C_ID, First_Name, Last_Name, Qualification, Address,
                       Locality, City, Email, Phone_NO, DOP, E_ID,
                       Item_ID, Price, Quantity, O_Amount;

        -- Check if there are no more rows
        IF done = 1 THEN 
            LEAVE read_loop;
        END IF;

      

        -- Insert into Backup Table
        INSERT INTO Customer_Backuplog (C_ID, First_Name, Last_Name, Qualification, Address,
                                        Locality, City, Email, Phone_NO, DOP, E_ID,
                                        Item_ID, PRICE, Quantity, O_Amount)
        VALUES (C_ID, First_Name, Last_Name, Qualification, Address,
                Locality, City, Email, Phone_NO, DOP, E_ID,
                Item_ID, Price, Quantity, O_Amount);
        
    END LOOP;

    -- Close Cursor
    CLOSE cur;

    -- Verify if records exist before deleting
    IF (SELECT COUNT(*) FROM Customer_Backuplog WHERE C_ID = C_ID_val) > 0 THEN
        DELETE FROM Orders WHERE C_ID = C_ID_val;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `Display_Age`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Display_Age` (IN `UID` INT, OUT `Age` INT)   BEGIN  
    DECLARE Date_OF_Birth date; 
    SELECT * FROM Employee WHERE E_ID = UID;
    SELECT E.E_DOB INTO Date_OF_Birth
    FROM Employee AS E
    WHERE E.E_ID = UID;
    SET Age = FLOOR(DATEDIFF(CURRENT_DATE, Date_OF_Birth)/365);
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `CustomerLevel`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `CustomerLevel` (`C_ID` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 DETERMINISTIC BEGIN
    DECLARE customerLevel VARCHAR(20);
    DECLARE credit float;
    SELECT sum(O.O_Amount) INTO credit
    FROM ORDERS AS O
    WHERE O.C_ID = C_ID
    GROUP BY O.C_ID;
    

    IF credit > 25000 THEN
		SET customerLevel = 'PLATINUM';
    ELSEIF (credit >= 21000 AND 
			credit <= 25000) THEN
        SET customerLevel = 'GOLD';
    ELSEIF credit < 20000 THEN
        SET customerLevel = 'SILVER';
    ELSE
        SET customerLevel = 'BRONZE';
    END IF;
	-- Return the customer level
	RETURN (customerLevel);
END$$

DROP FUNCTION IF EXISTS `Discount`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `Discount` (`C_ID` INT) RETURNS FLOAT DETERMINISTIC BEGIN
    DECLARE credit float;
    DECLARE discount float;
    DECLARE final_amount float;
    SELECT Amount INTO credit
    FROM Bill AS B
    WHERE B.C_ID = C_ID;
    

    IF credit > 25000 THEN
		SET final_amount = credit - (credit * 0.2);
        SET discount = credit * 0.2;
    ELSEIF (credit > 10000 AND credit <= 25000) THEN
        SET final_amount = credit - (credit * 0.1);
        SET discount = credit * 0.1;
    ELSEIF (credit > 5000 AND credit <= 10000) THEN
        SET final_amount = credit - (credit * 0.08);
        SET discount = credit * 0.08;
    ELSE
        SET final_amount = credit - (credit * 0.05);
        SET discount = credit * 0.05;
    END IF;
	RETURN (discount);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bill`
--

DROP TABLE IF EXISTS `bill`;
CREATE TABLE IF NOT EXISTS `bill` (
  `B_ID` int NOT NULL,
  `C_ID` int DEFAULT NULL,
  `BANK` varchar(20) DEFAULT NULL,
  `DATE_OF_BILL` date DEFAULT NULL,
  `TRANSACTION_ID` varchar(20) DEFAULT NULL,
  `AMOUNT` float NOT NULL,
  PRIMARY KEY (`B_ID`),
  UNIQUE KEY `BILL_PK` (`B_ID`),
  KEY `BILL_FK` (`C_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `bill`
--

INSERT INTO `bill` (`B_ID`, `C_ID`, `BANK`, `DATE_OF_BILL`, `TRANSACTION_ID`, `AMOUNT`) VALUES
(9001, 2001, '', '2022-12-09', '', 25997),
(9002, 2002, 'Chase', '2022-10-16', '98765432102', 8348),
(9003, 2003, 'Wells Fargo', '2022-10-25', '34676876876', 20800),
(9004, 2004, 'Bank of America', '2022-08-22', '46548767588', 9500),
(9005, 2005, 'HSBC', '2022-10-09', '89876543876', 4250),
(9006, 2006, 'Citibank', '2022-10-07', '42637267463', 22592),
(9007, 2007, 'Barclays', '2022-08-21', '12348765454', 30797),
(9008, 2008, 'Chase', '2022-07-19', '43644783600', 28200),
(9009, 2009, 'Wells Fargo', '2022-08-31', '52343477809', 6500),
(9010, 2010, 'Barclays', '2022-08-02', '32356654896', 7350),
(9011, 2011, 'HSBC', '2022-10-07', '32456487876', 15588),
(9012, 2012, 'Citibank', '2022-10-17', '34678871313', 14995),
(9013, 2013, 'Bank of America', '2022-09-18', '54467945789', 10250),
(9014, 2014, 'Barclays', '2022-08-29', '32869248768', 11200),
(9015, 2015, 'HSBC', '2022-10-30', '34557897968', 20500),
(9016, 2016, 'Chase', '2022-08-07', '45467884334', 29300),
(9017, 2017, 'Citibank', '2022-09-23', '34879565998', 32250),
(9018, 2018, 'HSBC', '2022-10-27', '12350767426', 14396),
(9019, 2019, 'Bank of America', '2022-11-23', '65748392102', 19600),
(9020, 2020, 'Barclays', '2022-08-14', '34365587090', 24900),
(9021, 2021, 'Chase', '2022-11-23', '89076543245', 18197),
(9022, 2022, 'NA', '2022-11-23', 'Paid Through Cash', 10597),
(9023, 2023, '', '2025-02-24', '', 999),
(9000, 2000, 'blom', '2025-02-24', '123', 1800);

-- --------------------------------------------------------

--
-- Stand-in structure for view `bills`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `bills`;
CREATE TABLE IF NOT EXISTS `bills` (
`Brand` varchar(20)
,`C_FIRST_NAME` varchar(50)
,`C_ID` int
,`C_LAST_NAME` varchar(50)
,`DOP` date
,`I_NAME` varchar(30)
,`Item_ID` int
,`Quantity` int
,`Size` varchar(10)
,`TOTAL` double
);

-- --------------------------------------------------------

--
-- Table structure for table `contains`
--

DROP TABLE IF EXISTS `contains`;
CREATE TABLE IF NOT EXISTS `contains` (
  `ITEM_ID` int NOT NULL,
  `STORE_ID` int NOT NULL,
  `QUANTITY` int DEFAULT NULL,
  PRIMARY KEY (`ITEM_ID`,`STORE_ID`),
  UNIQUE KEY `CONTAINS_PK` (`ITEM_ID`,`STORE_ID`),
  KEY `FK_CONTAINS_CONTAINS2_STORE` (`STORE_ID`),
  KEY `CONTAINS_FK` (`ITEM_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `contains`
--

INSERT INTO `contains` (`ITEM_ID`, `STORE_ID`, `QUANTITY`) VALUES
(4002, 6001, 32),
(4011, 6001, 32),
(4041, 6001, 30),
(4050, 6001, 29),
(4081, 6001, 29),
(4082, 6001, 34),
(4090, 6001, 26),
(4100, 6001, 37),
(4101, 6001, 32),
(4111, 6001, 33),
(4130, 6001, 22),
(4161, 6001, 25),
(4162, 6001, 26),
(4170, 6001, 27),
(4181, 6001, 36),
(4201, 6001, 24),
(4300, 6001, 30),
(4010, 6002, 46),
(4030, 6002, 43),
(4042, 6002, 43),
(4061, 6002, 44),
(4083, 6002, 41),
(4090, 6002, 46),
(4092, 6002, 44),
(4100, 6002, 36),
(4110, 6002, 39),
(4120, 6002, 47),
(4122, 6002, 41),
(4140, 6002, 46),
(4163, 6002, 40),
(4180, 6002, 38),
(4200, 6002, 48),
(4201, 6002, 38),
(4002, 6003, 25),
(4010, 6003, 27),
(4060, 6003, 21),
(4061, 6003, 38),
(4070, 6003, 25),
(4071, 6003, 35),
(4080, 6003, 40),
(4091, 6003, 28),
(4092, 6003, 35),
(4100, 6003, 32),
(4102, 6003, 31),
(4121, 6003, 36),
(4122, 6003, 40),
(4130, 6003, 28),
(4000, 6004, 27),
(4092, 6004, 22),
(4112, 6004, 34),
(4131, 6004, 31),
(4150, 6004, 33),
(4151, 6004, 23),
(4160, 6004, 34),
(4163, 6004, 28),
(4171, 6004, 31),
(4190, 6004, 35),
(4400, 6004, 40),
(4999, 6001, 3);

--
-- Triggers `contains`
--
DROP TRIGGER IF EXISTS `Item_Add`;
DELIMITER $$
CREATE TRIGGER `Item_Add` BEFORE INSERT ON `contains` FOR EACH ROW BEGIN
    DECLARE error_msg VARCHAR(255);
    SET error_msg = ('The new quantity cannot be greater than 50');
    IF new.Quantity > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = error_msg;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
CREATE TABLE IF NOT EXISTS `customers` (
  `C_ID` int NOT NULL,
  `E_ID` int NOT NULL,
  `C_FIRST_NAME` varchar(50) DEFAULT NULL,
  `C_LAST_NAME` varchar(50) NOT NULL,
  `QUALIFICATION` varchar(20) DEFAULT NULL,
  `C_ADDRESS` varchar(50) DEFAULT NULL,
  `LOCALITY` varchar(20) DEFAULT NULL,
  `CITY` varchar(20) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `C_PHONE_NO` varchar(10) DEFAULT NULL,
  `DOP` date DEFAULT NULL,
  PRIMARY KEY (`C_ID`),
  UNIQUE KEY `CUSTOMERS_PK` (`C_ID`),
  KEY `FK_CUSTOMER_SERVES_EMPLOYEE` (`E_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`C_ID`, `E_ID`, `C_FIRST_NAME`, `C_LAST_NAME`, `QUALIFICATION`, `C_ADDRESS`, `LOCALITY`, `CITY`, `EMAIL`, `C_PHONE_NO`, `DOP`) VALUES
(2002, 1013, 'Michael', 'Smith', 'Teacher', '456 Oak Avenue', 'Uptown', 'Chicago', 'michael.smith@gmail.com', '9876543210', '2022-10-16'),
(2003, 1001, 'Sarah', 'Williams', 'Engineer', '789 Pine Road', 'Midtown', 'Los Angeles', 'sarah.williams@gmail.com', '8654432318', '2022-10-25'),
(2004, 1003, 'David', 'Brown', 'Software Engineer', '321 Elm Street', 'Suburb', 'San Francisco', 'david.brown@gmail.com', '8763313499', '2022-08-22'),
(2005, 1005, 'Jessica', 'Davis', 'Teacher', '654 Birch Lane', 'Downtown', 'Seattle', 'jessica.davis@gmail.com', '2454676898', '2022-10-09'),
(2006, 1006, 'Daniel', 'Miller', 'Doctor', '987 Cedar Blvd', 'Uptown', 'Boston', 'daniel.miller@gmail.com', '7364837638', '2022-10-07'),
(2007, 1007, 'Laura', 'Wilson', 'Software Engineer', '135 Walnut Street', 'Midtown', 'Austin', 'laura.wilson@gmail.com', '5365384899', '2022-08-21'),
(2008, 1013, 'James', 'Moore', 'Engineer', '246 Cherry Lane', 'Suburb', 'Dallas', 'james.moore@gmail.com', '7259966769', '2022-07-19'),
(2009, 1004, 'Emma', 'Taylor', 'Student', '369 Spruce Avenue', 'Downtown', 'Miami', 'emma.taylor@gmail.com', '8396364290', '2022-08-31'),
(2010, 1013, 'Olivia', 'Anderson', 'Teacher', '482 Ash Road', 'Uptown', 'Phoenix', 'olivia.anderson@gmail.com', '7678347343', '2022-08-02'),
(2011, 1013, 'Noah', 'Thomas', 'Student', '591 Pine Street', 'Midtown', 'Denver', 'noah.thomas@gmail.com', '2646747346', '2022-10-07'),
(2012, 1009, 'Ava', 'Jackson', 'Doctor', '753 Oak Lane', 'Suburb', 'Houston', 'ava.jackson@gmail.com', '8464987736', '2022-10-17'),
(2013, 1011, 'Liam', 'White', 'Student', '864 Maple Blvd', 'Downtown', 'Atlanta', 'liam.white@gmail.com', '4567893210', '2022-09-18'),
(2014, 1012, 'Sophia', 'Harris', 'Doctor', '975 Cedar Road', 'Uptown', 'Philadelphia', 'sophia.harris@gmail.com', '8664313546', '2022-08-29'),
(2015, 1005, 'Mason', 'Martin', 'Engineer', '159 Birch Street', 'Midtown', 'San Diego', 'mason.martin@gmail.com', '8765432345', '2022-10-30'),
(2016, 1013, 'Isabella', 'Thompson', 'Student', '357 Elm Lane', 'Suburb', 'Portland', 'isabella.thompson@gmail.com', '6432469890', '2022-08-07'),
(2017, 1004, 'Ethan', 'Garcia', 'Activist', '468 Walnut Avenue', 'Downtown', 'Las Vegas', 'ethan.garcia@gmail.com', '8632145805', '2022-09-23'),
(2018, 1001, 'Mia', 'Martinez', 'Teacher', '579 Cherry Road', 'Uptown', 'Orlando', 'mia.martinez@gmail.com', '7332668789', '2022-10-27'),
(2019, 1003, 'Alexander', 'Robinson', 'Driver', '681 Spruce Lane', 'Midtown', 'San Antonio', 'alexander.robinson@gmail.com', '1298765235', '2022-09-26'),
(2020, 1006, 'Charlotte', 'Clark', 'Driver', '792 Ash Street', 'Suburb', 'Nashville', 'charlotte.clark@gmail.com', '9876542345', '2022-08-14'),
(2021, 1004, 'Benjamin', 'Rodriguez', 'Musician', '893 Pine Blvd', 'Downtown', 'New Orleans', 'benjamin.rodriguez@gmail.com', '8907564321', '2022-11-23');

--
-- Triggers `customers`
--
DROP TRIGGER IF EXISTS `Before_Delete_CustomerInfo`;
DELIMITER $$
CREATE TRIGGER `Before_Delete_CustomerInfo` BEFORE DELETE ON `customers` FOR EACH ROW BEGIN
CALL Delete_Customer(OLD.C_ID);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer_backuplog`
--

DROP TABLE IF EXISTS `customer_backuplog`;
CREATE TABLE IF NOT EXISTS `customer_backuplog` (
  `C_ID` int NOT NULL,
  `First_Name` varchar(50) DEFAULT NULL,
  `Last_Name` varchar(50) NOT NULL,
  `Qualification` varchar(20) DEFAULT NULL,
  `ADDRESS` varchar(50) DEFAULT NULL,
  `Locality` varchar(20) DEFAULT NULL,
  `CITY` varchar(20) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Phone_NO` varchar(10) DEFAULT NULL,
  `DOP` date DEFAULT NULL,
  `E_ID` int DEFAULT NULL,
  `Store_ID` int DEFAULT NULL,
  `Item_ID` int DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `O_Amount` float DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `customer_backuplog`
--

INSERT INTO `customer_backuplog` (`C_ID`, `First_Name`, `Last_Name`, `Qualification`, `ADDRESS`, `Locality`, `CITY`, `Email`, `Phone_NO`, `DOP`, `E_ID`, `Store_ID`, `Item_ID`, `Quantity`, `O_Amount`) VALUES
(2023, 'Jana', 'Kassab', '', 'beirut', '', '', '', '', '2025-02-24', 1001, 4002, 999, 1, 999),
(2023, 'Jana', 'Kassab', '', 'beirut', '', '', '', '', '2025-02-24', 1001, 4002, 999, 1, 999),
(2001, 'Emily', 'Johnson', 'student', '123 Maple Street', 'Downtown', 'New York', 'emily.johnson@gmail.com', '1234567890', '2022-09-12', 1001, 4002, 999, 3, 2997),
(2001, 'Emily', 'Johnson', 'student', '123 Maple Street', 'Downtown', 'New York', 'emily.johnson@gmail.com', '1234567890', '2022-09-12', 1001, 4002, 999, 3, 2997);

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
CREATE TABLE IF NOT EXISTS `employee` (
  `E_ID` int NOT NULL,
  `MGR_ID` int DEFAULT NULL,
  `E_FIRST_NAME` varchar(50) DEFAULT NULL,
  `E_LAST_NAME` varchar(50) NOT NULL,
  `E_GENDER` varchar(1) NOT NULL,
  `E_DOB` date NOT NULL,
  `SALARY` float NOT NULL,
  `E_ADDRESS` varchar(50) DEFAULT NULL,
  `E_PHONE_NO` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`E_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`E_ID`, `MGR_ID`, `E_FIRST_NAME`, `E_LAST_NAME`, `E_GENDER`, `E_DOB`, `SALARY`, `E_ADDRESS`, `E_PHONE_NO`) VALUES
(1004, 1007, 'Mary', 'Williams', 'F', '1984-10-17', 67891, '321 Pine St', '3391172715'),
(1005, 1002, 'Michael', 'Brown', 'M', '1987-09-27', 79103, '654 Maple St', '5605646750'),
(1006, 1007, 'Linda', 'Jones', 'F', '1986-10-08', 59795, '987 Cedar St', '2015362539'),
(1007, 0, 'William', 'Taylor', 'M', '1971-02-19', 115297, '135 Walnut St', '9525847821'),
(1008, 1007, 'Elizabeth', 'Anderson', 'F', '1989-02-28', 55859, '246 Cherry St', '5884750721'),
(1009, 1013, 'David', 'Thomas', 'M', '1992-03-14', 63712, '369 Spruce St', '5002946135'),
(1010, 1002, 'Jennifer', 'Jackson', 'F', '1974-11-23', 109979, '482 Ash St', '8954874497'),
(1011, 1013, 'Richard', 'White', 'M', '1988-12-04', 75312, '591 Pine St', '7654873190'),
(1012, 1010, 'Joseph', 'Harris', 'M', '1993-12-07', 60593, '753 Oak St', '1480171904'),
(1013, 0, 'Thomas', 'Martin', 'M', '1975-05-23', 118701, '864 Maple St', '3791768076'),
(1014, 1013, 'Susan', 'Thompson', 'F', '2000-03-31', 200000, '975 Cedar St', '9876543210'),
(1015, 1010, 'Daniel', 'Garcia', 'M', '1990-06-12', 80000, '159 Birch St', '7689045321');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
CREATE TABLE IF NOT EXISTS `items` (
  `ITEM_ID` int NOT NULL,
  `PRICE` float DEFAULT NULL,
  `I_NAME` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`ITEM_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`ITEM_ID`, `PRICE`, `I_NAME`) VALUES
(4000, 900, 'Shirt'),
(4001, 1499, 'Shirt'),
(4002, 999, 'Shirt'),
(4010, 2999, 'Pant'),
(4011, 4000, 'Pant'),
(4030, 15000, 'Coat'),
(4041, 7999, 'Gown'),
(4042, 4999, 'Gown'),
(4050, 499, 'Cap/Hat'),
(4060, 999, 'Sweater'),
(4061, 1799, 'Sweater'),
(4070, 900, 'Jacket'),
(4071, 600, 'Jacket'),
(4080, 400, 'Legging'),
(4081, 349, 'Legging'),
(4082, 499, 'Legging'),
(4083, 550, 'Legging'),
(4090, 700, 'Jeggings'),
(4091, 599, 'Jeggings'),
(4092, 445, 'Jeggings'),
(4100, 250, 'Tops'),
(4101, 399, 'Tops'),
(4102, 549, 'Tops'),
(4160, 799, 'Tshirt'),
(4161, 699, 'Tshirt'),
(4162, 1000, 'Tshirt'),
(4163, 900, 'Tshirt'),
(4170, 500, 'Shorts'),
(4171, 599, 'Shorts'),
(4180, 699, 'Skirt'),
(4181, 700, 'Skirt'),
(4190, 650, 'Pyjama'),
(4400, 1999, 'Cigar Pant');

-- --------------------------------------------------------

--
-- Table structure for table `item_category`
--

DROP TABLE IF EXISTS `item_category`;
CREATE TABLE IF NOT EXISTS `item_category` (
  `ITEM_NAME` varchar(30) NOT NULL,
  `CATEGORYITEM_ID` int NOT NULL,
  `I_GENDER` varchar(1) NOT NULL,
  `BRAND` varchar(20) DEFAULT NULL,
  `COLOUR` varchar(20) DEFAULT NULL,
  `SIZE` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`CATEGORYITEM_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `item_category`
--

INSERT INTO `item_category` (`ITEM_NAME`, `CATEGORYITEM_ID`, `I_GENDER`, `BRAND`, `COLOUR`, `SIZE`) VALUES
('Shirt', 4000, 'M', 'Calvin Klein', 'Red', '38'),
('Shirt', 4001, 'M', 'Tommy Hilfiger', 'Blue', '40'),
('Shirt', 4002, 'M', 'Hugo Boss', 'Green', '42'),
('Pant', 4010, 'M', 'Levi’s', 'Black', '38'),
('Pant', 4011, 'M', 'Ralph Lauren', 'Brown', '40'),
('Coat', 4030, 'F', 'Burberry', 'Grey', 'XXL'),
('Gown', 4041, 'F', 'Gucci', 'Pink', 'XXL'),
('Gown', 4042, 'M', 'Armani', 'Green', 'XL'),
('Cap/Hat', 4050, 'M', 'Nike', 'Cyan', ''),
('Sweater', 4060, 'F', 'Uniqlo', 'Navyblue', 'XL'),
('Sweater', 4061, 'M', 'Uniqlo', 'Light_Brown', 'L'),
('Jacket', 4070, 'M', 'The North Face', 'Red', 'L'),
('Jacket', 4071, 'M', 'Columbia', 'Brown', 'XXL'),
('Legging', 4080, 'F', 'Lululemon', 'Maroon', 'XL'),
('Legging', 4081, 'F', 'Under Armour', 'White', 'M'),
('Legging', 4082, 'F', 'Adidas', 'Black', 'XXL'),
('Legging', 4083, 'F', 'Puma', 'Dark_Blue', 'XXXL'),
('Jeggings', 4090, 'F', 'Zara', 'Purple', 'XXL'),
('Jeggings', 4091, 'F', 'H&M', 'Grey', 'XL'),
('Jeggings', 4092, 'F', 'Forever 21', 'Yellow', 'L'),
('Tops', 4100, 'F', 'Gap', 'Black', 'XL'),
('Tops', 4101, 'F', 'Victoria’s Secret', 'Red', 'XL'),
('Tops', 4102, 'F', 'Victoria’s Secret', 'Blue', 'XXL'),
('Tshirt', 4160, 'M', 'Champion', 'Red', '42'),
('Tshirt', 4161, 'M', 'Champion', 'Black', '44'),
('Tshirt', 4162, 'M', 'Nike', 'Brown', '40'),
('Tshirt', 4163, 'M', 'Ralph Lauren', 'Grey', '38'),
('Shorts', 4170, 'M', 'Ralph Lauren', 'Green', '36'),
('Shorts', 4171, 'M', 'Levi’s', 'Blue', '38'),
('Skirt', 4180, 'F', 'Zara', 'Light_Green', '42'),
('Skirt', 4181, 'F', 'H&M', 'Pink', '38'),
('Pyjama', 4190, 'M', 'Calvin Klein', 'Grey', '40'),
('Cigar Pant', 4400, 'F', 'Diesel', 'Maroon', 'XL'),
('shorts', 4999, 'F', 'zara', 'black', '36');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `C_ID` int NOT NULL,
  `ITEM_ID` int NOT NULL,
  `QUANTITY` int DEFAULT NULL,
  `O_DATE` date DEFAULT NULL,
  `O_AMOUNT` float DEFAULT NULL,
  `PRICE` float DEFAULT NULL,
  PRIMARY KEY (`C_ID`,`ITEM_ID`),
  KEY `item_fid2` (`ITEM_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`C_ID`, `ITEM_ID`, `QUANTITY`, `O_DATE`, `O_AMOUNT`, `PRICE`) VALUES
(2002, 4010, 2, '2022-10-16', 5998, 2999),
(2003, 4030, 1, '2022-10-25', 15000, 15000),
(2004, 4041, 1, '2022-08-22', 7999, 7999),
(2005, 4050, 5, '2022-10-09', 2495, 499),
(2006, 4060, 2, '2022-10-07', 1998, 999),
(2007, 4070, 3, '2022-08-21', 2700, 900),
(2008, 4080, 4, '2022-07-19', 1600, 400),
(2009, 4090, 2, '2022-08-31', 1400, 700),
(2010, 4100, 10, '2022-08-02', 2500, 250),
(2016, 4160, 4, '2022-08-07', 3196, 799),
(2000, 4000, 2, '2025-02-24', 1800, 900);

-- --------------------------------------------------------

--
-- Table structure for table `shipment`
--

DROP TABLE IF EXISTS `shipment`;
CREATE TABLE IF NOT EXISTS `shipment` (
  `SHIP_PID` int NOT NULL,
  `STORE_ID` int NOT NULL,
  `DATE_OF_SHIPMENT` datetime DEFAULT NULL,
  PRIMARY KEY (`SHIP_PID`),
  KEY `FK_SHIPMENT_RECEIVED__STORE` (`STORE_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `shipment`
--

INSERT INTO `shipment` (`SHIP_PID`, `STORE_ID`, `DATE_OF_SHIPMENT`) VALUES
(8001, 6001, '2022-05-22 00:00:00'),
(8002, 6001, '2022-06-30 00:00:00'),
(8003, 6001, '2022-09-05 00:00:00'),
(8004, 6002, '2022-12-05 00:00:00'),
(8005, 6004, '2022-04-21 00:00:00'),
(8006, 6003, '2022-06-06 00:00:00'),
(8007, 6004, '2022-06-25 00:00:00'),
(8008, 6002, '2022-06-16 00:00:00'),
(8009, 6003, '2022-05-31 00:00:00'),
(8010, 6004, '2022-04-27 00:00:00'),
(8000, 6001, '2025-02-24 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `ships`
--

DROP TABLE IF EXISTS `ships`;
CREATE TABLE IF NOT EXISTS `ships` (
  `SUPP_ID` int NOT NULL,
  `SHIP_ID` int NOT NULL,
  `MODE_OF_TRAVEL` varchar(255) DEFAULT NULL,
  `COST_OF_SHIPPING` float DEFAULT NULL,
  PRIMARY KEY (`SUPP_ID`,`SHIP_ID`),
  KEY `FK_SHIPS_SHIPS2_SHIPMENT` (`SHIP_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ships`
--

INSERT INTO `ships` (`SUPP_ID`, `SHIP_ID`, `MODE_OF_TRAVEL`, `COST_OF_SHIPPING`) VALUES
(7001, 8005, 'Roadways', 5489),
(7001, 8006, 'Airways', 4000),
(7002, 8001, 'Railways', 6597),
(7002, 8009, 'Railways', 870),
(7003, 8004, 'Railways', 5500),
(7003, 8008, 'Railways', 5500),
(7004, 8003, 'Airways', 7000),
(7004, 8007, 'Roadways', 3500),
(7005, 8002, 'Roadways', 6290),
(7005, 8010, 'Waterways', 6290),
(7006, 8006, 'Roadways', 70),
(7007, 8000, 'Roadways', 700);

-- --------------------------------------------------------

--
-- Table structure for table `store`
--

DROP TABLE IF EXISTS `store`;
CREATE TABLE IF NOT EXISTS `store` (
  `STORE_ID` int NOT NULL,
  `MGR_ID` int DEFAULT NULL,
  `ST_NAME` varchar(50) DEFAULT NULL,
  `ST_ADDRESS` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`STORE_ID`),
  KEY `mgr_fid` (`MGR_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`STORE_ID`, `MGR_ID`, `ST_NAME`, `ST_ADDRESS`) VALUES
(6001, 1002, 'Downtown Store', '123 Main Street'),
(6002, 1007, 'Uptown Store', '456 Elm Avenue'),
(6003, 1013, 'Midtown Store', '789 Pine Road'),
(6004, 1010, 'Suburb Store', '321 Oak Lane');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE IF NOT EXISTS `suppliers` (
  `SUPP_ID` int NOT NULL,
  `SU_NAME` varchar(50) DEFAULT NULL,
  `SU_ADDRESS` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`SUPP_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`SUPP_ID`, `SU_NAME`, `SU_ADDRESS`) VALUES
(7001, 'ABC Supplies', '123 Supply Lane'),
(7002, 'XYZ Distributors', '456 Distribution Road'),
(7003, 'Global Imports', '789 Import Street'),
(7004, 'Quality Goods', '321 Quality Avenue'),
(7005, 'Best Products', '654 Product Road');

-- --------------------------------------------------------

--
-- Stand-in structure for view `total_orders`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `total_orders`;
CREATE TABLE IF NOT EXISTS `total_orders` (
`C_ID` int
,`Item_ID` int
,`O_Amount` double
,`Price` float
,`Quantity` int
);

-- --------------------------------------------------------

--
-- Structure for view `bills`
--
DROP TABLE IF EXISTS `bills`;

DROP VIEW IF EXISTS `bills`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `bills`  AS SELECT `c`.`C_ID` AS `C_ID`, `c`.`C_FIRST_NAME` AS `C_FIRST_NAME`, `c`.`C_LAST_NAME` AS `C_LAST_NAME`, `i`.`ITEM_ID` AS `Item_ID`, `i`.`I_NAME` AS `I_NAME`, `ic`.`BRAND` AS `Brand`, `ic`.`SIZE` AS `Size`, `o`.`QUANTITY` AS `Quantity`, sum(`o`.`O_AMOUNT`) AS `TOTAL`, `c`.`DOP` AS `DOP` FROM (((`customers` `c` join `orders` `o` on((`c`.`C_ID` = `o`.`C_ID`))) join `items` `i` on((`i`.`ITEM_ID` = `o`.`ITEM_ID`))) join `item_category` `ic` on((`i`.`ITEM_ID` = `ic`.`CATEGORYITEM_ID`))) GROUP BY `o`.`C_ID`, `i`.`ITEM_ID` ORDER BY `c`.`DOP` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `total_orders`
--
DROP TABLE IF EXISTS `total_orders`;

DROP VIEW IF EXISTS `total_orders`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_orders`  AS SELECT `o`.`ITEM_ID` AS `Item_ID`, `o`.`C_ID` AS `C_ID`, `i`.`PRICE` AS `Price`, `o`.`QUANTITY` AS `Quantity`, (`o`.`QUANTITY` * `i`.`PRICE`) AS `O_Amount` FROM (`orders` `o` join `items` `i` on((`o`.`ITEM_ID` = `i`.`ITEM_ID`))) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
