USE GoogleDrive;
GO

-- Modified fn_TokenizeText function
CREATE OR ALTER FUNCTION dbo.fn_TokenizeText
(
    @InputText NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    WITH SplitTerms AS (
        SELECT 
            LOWER(TRIM(value)) AS Term,
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Position
        FROM STRING_SPLIT(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(@InputText, '.', ' '), 
                        ',', ' '
                    ), 
                    '-', ' '
                ), 
                ':', ' '
            ), 
            ' '
        )
        WHERE TRIM(value) <> ''
    )
    SELECT 
        Term,
        COUNT(*) AS TermFrequency,
        STRING_AGG(CAST(Position AS NVARCHAR), ',') AS TermPositions,
        (SELECT COUNT(*) FROM SplitTerms) AS DocumentLength
    FROM SplitTerms
    GROUP BY Term
    HAVING Term <> ''
);
GO

-- Simplified fn_CalculateBM25 function (placeholder, calculations moved to trigger)
CREATE OR ALTER FUNCTION dbo.fn_CalculateBM25
(
    @Term NVARCHAR(50),
    @FileContentId INT
)
RETURNS FLOAT
AS
BEGIN
    RETURN 0; -- Placeholder, actual calculation now in trigger
END;
GO

-- Modified FileContentIndexing trigger
CREATE OR ALTER TRIGGER trg_FileContentIndexing
ON FileContent
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update DocumentLength in FileContent
    UPDATE fc
    SET DocumentLength = (
        SELECT t.DocumentLength
        FROM inserted i
        CROSS APPLY dbo.fn_TokenizeText(i.ContentChunk) t
        WHERE i.ContentId = fc.ContentId
        GROUP BY t.DocumentLength
    )
    FROM FileContent fc
    WHERE fc.ContentId IN (SELECT ContentId FROM inserted);

    -- Delete existing SearchIndex and Term rows for affected FileContent
    DELETE FROM SearchIndex
    WHERE FileContentId IN (SELECT ContentId FROM inserted);

    DELETE FROM Term
    WHERE FileContentId IN (SELECT ContentId FROM inserted);

    -- Insert into Term table
    INSERT INTO Term (Term, FileContentId)
    SELECT DISTINCT t.Term, i.ContentId
    FROM inserted i
    CROSS APPLY dbo.fn_TokenizeText(i.ContentChunk) t
    WHERE i.ContentChunk IS NOT NULL;

    -- Insert into SearchIndex table with calculated IDF and BM25Score
    ; -- Semicolon to terminate previous statement
    WITH AllDocs AS (
        SELECT ContentId, DocumentLength
        FROM FileContent
        WHERE DocumentLength IS NOT NULL
    ),
    TermDocs AS (
        SELECT t.Term, COUNT(DISTINCT si.FileContentId) + COUNT(DISTINCT i.ContentId) AS DocFreq
        FROM inserted i
        CROSS APPLY dbo.fn_TokenizeText(i.ContentChunk) t
        LEFT JOIN SearchIndex si ON si.Term = t.Term
        GROUP BY t.Term
    ),
    Totals AS (
        SELECT COUNT(*) AS TotalDocs
        FROM AllDocs
    )
    INSERT INTO SearchIndex (FileContentId, Term, TermFrequency, TermPositions, Bm25Score, IDF)
    SELECT 
        i.ContentId,
        token.Term,
        token.TermFrequency,
        token.TermPositions,
        CASE 
            WHEN (token.TermFrequency + 1.2 * (1 - 0.75 + 0.75 * (ISNULL(i.DocumentLength, 1) / NULLIF((SELECT AVG(CAST(DocumentLength AS FLOAT)) FROM AllDocs), 0)))) = 0 
            THEN 0 
            ELSE (token.TermFrequency * (1.2 + 1) * td.DocFreq) / 
                 (token.TermFrequency + 1.2 * (1 - 0.75 + 0.75 * (ISNULL(i.DocumentLength, 1) / NULLIF((SELECT AVG(CAST(DocumentLength AS FLOAT)) FROM AllDocs), 0)))) 
        END AS Bm25Score,
        CASE 
            WHEN td.DocFreq = 0 OR totals.TotalDocs = 0 OR totals.TotalDocs <= td.DocFreq THEN 0
            ELSE LOG((totals.TotalDocs - td.DocFreq + 0.5) / (td.DocFreq + 0.5))
        END AS IDF
    FROM inserted i
    CROSS APPLY dbo.fn_TokenizeText(i.ContentChunk) token
    CROSS JOIN Totals totals
    JOIN TermDocs td ON td.Term = token.Term
    WHERE i.ContentChunk IS NOT NULL;
END;
GO