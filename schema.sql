-- Creating the Books table with an index on GenreID
CREATE TABLE "Books" (
    "BookID" INTEGER PRIMARY KEY,
    "Title" TEXT NOT NULL,
    "GenreID" INTEGER,
    "AuthorID" INTEGER,
    "ISBN" TEXT UNIQUE,
    "Availability" INTEGER DEFAULT 1, -- 1 means available, 0 means checked out
    FOREIGN KEY ("AuthorID") REFERENCES "Authors" ("AuthorID"),
    FOREIGN KEY ("GenreID") REFERENCES "Genres" ("GenreID")
);

-- Creating the Genres table
CREATE TABLE "Genres" (
    "GenreID" INTEGER PRIMARY KEY,
    "GenreName" TEXT NOT NULL UNIQUE
);

-- Creating the Authors table
CREATE TABLE "Authors" (
    "AuthorID" INTEGER PRIMARY KEY,
    "AuthorName" TEXT NOT NULL
);

-- Creating the Members table with an index on Email
CREATE TABLE "Members" (
    "MemberID" INTEGER PRIMARY KEY,
    "MemberName" TEXT NOT NULL,
    "Email" TEXT UNIQUE,
    "Phone" TEXT,
    "JoinDate" DATE DEFAULT (datetime('now'))
);

-- Creating the Admins table with an index on Email
CREATE TABLE "Admins" (
    "AdminID" INTEGER PRIMARY KEY,
    "AdminName" TEXT NOT NULL,
    "Email" TEXT UNIQUE,
    "Phone" TEXT,
    "Position" TEXT
);

-- Creating the Loans table with indexes on BookID and MemberID
CREATE TABLE "Loans" (
    "LoanID" INTEGER PRIMARY KEY,
    "BookID" INTEGER,
    "MemberID" INTEGER,
    "LoanDate" DATE DEFAULT (datetime('now')),
    "DueDate" DATE DEFAULT (datetime('now', '+21 days')),
    "ReturnDate" DATE,
    FOREIGN KEY ("BookID") REFERENCES "Books" ("BookID"),
    FOREIGN KEY ("MemberID") REFERENCES "Members" ("MemberID")
);

-- Creating a Fines table to track overdue fines
CREATE TABLE "Fines" (
    "FineID" INTEGER PRIMARY KEY,
    "LoanID" INTEGER,
    "FineAmount" REAL,
    "Paid" INTEGER DEFAULT 0,
    FOREIGN KEY ("LoanID") REFERENCES "Loans" ("LoanID")
);

-- Creating a trigger to automatically update book availability when a loan is created
CREATE TRIGGER "update_availability_on_loan"
AFTER INSERT ON "Loans"
FOR EACH ROW
BEGIN
    UPDATE "Books"
    SET "Availability" = 0
    WHERE "BookID" = NEW."BookID";
END;

-- Creating a trigger to automatically update book availability when a loan is closed
CREATE TRIGGER "update_availability_on_return"
AFTER UPDATE OF "ReturnDate" ON "Loans"
FOR EACH ROW
WHEN NEW."ReturnDate" IS NOT NULL
BEGIN
    UPDATE "Books"
    SET "Availability" = 1
    WHERE "BookID" = NEW."BookID";
END;

-- Creating a trigger to calculate fines for overdue books
CREATE TRIGGER "calculate_fine_on_overdue"
AFTER UPDATE OF "ReturnDate" ON "Loans"
FOR EACH ROW
WHEN (julianday(NEW."ReturnDate") - julianday(NEW."LoanDate")) > 21 -- Assuming 21 days loan period
BEGIN
    INSERT INTO "Fines" ("LoanID", "FineAmount")
    VALUES (NEW."LoanID", (julianday(NEW."ReturnDate") - julianday(NEW."LoanDate") - 21) * 1.0); -- Assuming fine of 1.0 per day overdue
END;

-- Create indexes to speed common searches
CREATE INDEX "idx_books_genre" ON "Books" ("GenreID");
CREATE INDEX "idx_members_email" ON "Members" ("Email");
CREATE INDEX "idx_admins_email" ON "Admins" ("Email");
CREATE INDEX "idx_loans_book" ON "Loans" ("BookID");
CREATE INDEX "idx_loans_member" ON "Loans" ("MemberID");
