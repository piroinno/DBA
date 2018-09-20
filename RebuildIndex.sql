
CREATE PROC RebuildIndexes AS
BEGIN
	SET NOCOUNT ON
	
	IF OBJECT_ID('tempdb..#tables') IS NOT NULL DROP TABLE #tables
	CREATE TABLE #tables
	WITH(DISTRIBUTION = ROUND_ROBIN, HEAP)
	AS
	SELECT s.name AS table_schema, t.name AS table_name FROM [sys].[tables] t
	INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
	WHERE t.[is_external] =  0;

	DECLARE @tableName VARCHAR(MAX)
	DECLARE @schemaName VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)

	WHILE EXISTS (SELECT 1 FROM #tables)
	BEGIN
		SET @tableName = (SELECT TOP(1) table_name FROM #tables ORDER BY table_schema ASC, table_name ASC)
		SET @schemaName = (SELECT TOP(1) table_schema FROM #tables ORDER BY table_schema ASC, table_name ASC)
		SET @sql = 'ALTER INDEX ALL ON [' + @schemaName + '].['+ @tableName + '] REBUILD'
		EXEC(@sql)
		DELETE #tables WHERE table_name = @tableName and table_schema = @schemaName
	END
	IF OBJECT_ID('tempdb..#tables') IS NOT NULL DROP TABLE #tables
END