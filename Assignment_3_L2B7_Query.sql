-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database
-- DATABASE: PostgreSQL
-- DESCRIPTION: Complete DDL, sample data, and all 7 required queries
-- =========================================================================

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE users (
    user_id        INTEGER       NOT NULL,
    full_name      VARCHAR(100)  NOT NULL,
    email          VARCHAR(100)  NOT NULL,
    role           VARCHAR(20)   NOT NULL,
    phone_number   VARCHAR(20),

    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('Ticket Manager', 'Football Fan'))
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE matches (
    match_id              INTEGER        NOT NULL,
    fixture               VARCHAR(200)   NOT NULL,
    tournament_category   VARCHAR(100)   NOT NULL,
    base_ticket_price     DECIMAL(10, 2) NOT NULL,
    match_status          VARCHAR(20)    NOT NULL,

    CONSTRAINT pk_matches PRIMARY KEY (match_id),
    CONSTRAINT chk_matches_base_ticket_price CHECK (base_ticket_price >= 0),
    CONSTRAINT chk_matches_match_status CHECK (
        match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed')
    )
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE bookings (
    booking_id      INTEGER        NOT NULL,
    user_id         INTEGER        NOT NULL,
    match_id        INTEGER        NOT NULL,
    seat_number     VARCHAR(10),
    payment_status  VARCHAR(20),
    total_cost      DECIMAL(10, 2) NOT NULL,

    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),
    CONSTRAINT fk_bookings_user_id FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    CONSTRAINT fk_bookings_match_id FOREIGN KEY (match_id)
        REFERENCES matches (match_id),
    CONSTRAINT chk_bookings_total_cost CHECK (total_cost >= 0),
    CONSTRAINT chk_bookings_payment_status CHECK (
        payment_status IS NULL
        OR payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
    )
);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);

-- =========================================================================
-- PART 2: SQL QUERIES
-- =========================================================================

-- -------------------------------------------------------------------------
-- Query 1: Champions League matches with status 'Available'
-- -------------------------------------------------------------------------
SELECT match_id, fixture, base_ticket_price
FROM matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';

-- -------------------------------------------------------------------------
-- Query 2: Users whose names start with 'Tanvir' or contain 'Haque'
-- Concepts: LIKE, ILIKE (case-insensitive)
-- -------------------------------------------------------------------------
SELECT user_id, full_name, email
FROM users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';

-- -------------------------------------------------------------------------
-- Query 3: Bookings with NULL payment status, replaced with 'Action Required'
-- Concepts: IS NULL, COALESCE
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM bookings
WHERE payment_status IS NULL;

-- -------------------------------------------------------------------------
-- Query 4: Booking details with user name and match fixture
-- Concepts: INNER JOIN
-- -------------------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN matches m ON b.match_id = m.match_id;

-- -------------------------------------------------------------------------
-- Query 5: All users and their booking IDs (include users with no bookings)
-- Concepts: LEFT JOIN
-- -------------------------------------------------------------------------
SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM users u
LEFT JOIN bookings b ON u.user_id = b.user_id
ORDER BY u.user_id, b.booking_id;

-- -------------------------------------------------------------------------
-- Query 6: Bookings with total cost above the average booking cost
-- Concepts: subquery, aggregation
-- -------------------------------------------------------------------------
SELECT booking_id, match_id, total_cost
FROM bookings
WHERE total_cost > (
    SELECT AVG(total_cost)
    FROM bookings
);

-- -------------------------------------------------------------------------
-- Query 7: Top 2 most expensive matches, skipping the highest-priced match
-- Concepts: ORDER BY, OFFSET, LIMIT (pagination)
-- -------------------------------------------------------------------------
SELECT match_id, fixture, base_ticket_price
FROM matches
ORDER BY base_ticket_price DESC
OFFSET 1
LIMIT 2;
