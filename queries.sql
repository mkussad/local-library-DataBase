-- Query 1: Retrieve all books with their authors and genres
SELECT "Books"."Title" AS "BookTitle", "Authors"."AuthorName" AS "Author", "Genres"."GenreName" AS "Genre"
FROM "Books"
INNER JOIN "Authors" ON "Books"."AuthorID" = "Authors"."AuthorID"
INNER JOIN "Genres" ON "Books"."GenreID" = "Genres"."GenreID";

-- Query 2: Find books that are currently available
SELECT "Title"
FROM "Books"
WHERE "Availability" = 1;

-- Query 3: List members who have overdue books along with the fine amount
SELECT "Members"."MemberName", "Fines"."FineAmount"
FROM "Members"
INNER JOIN "Loans" ON "Members"."MemberID" = "Loans"."MemberID"
INNER JOIN "Fines" ON "Loans"."LoanID" = "Fines"."LoanID"
WHERE "Loans"."ReturnDate" IS NULL AND julianday('now') > julianday("Loans"."DueDate");

-- Query 4: Count the number of books in each genre
SELECT "Genres"."GenreName", COUNT(*) AS "NumberOfBooks"
FROM "Books"
INNER JOIN "Genres" ON "Books"."GenreID" = "Genres"."GenreID"
GROUP BY "Genres"."GenreName";

-- Query 5: Find the top 5 members who have borrowed the most books
SELECT "Members"."MemberName", COUNT("Loans"."LoanID") AS "BooksBorrowed"
FROM "Members"
LEFT JOIN "Loans" ON "Members"."MemberID" = "Loans"."MemberID"
GROUP BY "Members"."MemberName"
ORDER BY "BooksBorrowed" DESC
LIMIT 5;

-- Query 6: List books borrowed by a specific member
SELECT "Books"."Title" AS "BookTitle", "Loans"."LoanDate", "Loans"."DueDate"
FROM "Loans"
INNER JOIN "Books" ON "Loans"."BookID" = "Books"."BookID"
WHERE "Loans"."MemberID" = 1; -- Replace 1 with the MemberID of the member you want to query

-- Query 7: Calculate total fines collected
SELECT SUM("FineAmount") AS "TotalFinesCollected"
FROM "Fines"
WHERE "Paid" = 1; -- Assuming 1 indicates fines that have been paid
