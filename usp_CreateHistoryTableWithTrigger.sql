SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************************************
Created By:  Bryan Massey
Comments:  Stored proc performs the following actions:
	1) Queries system tables to retrieve table schema for @TableName parameter
	2) Creates a History table ( @TableName+"_History") to mimic the original table, plus include 
           additional history columns.
	3) If @CreateTrigger = 'Y' then it creates an Update/Delete trigger on the @TableName table, 
	   which is used to populate the History table.
******************************************* MODIFICATIONS **************************************************
MM/DD/YYYY - Modified By - Description of Changes
18/10/2012 - Artem Tomashevsky - Support of 'max' field length, nvarchar/varchar column types, IDENTITY BACKUP workaround and optimized trigger code
Modified By: Vlad Rojcov 08/25/2016 Change history naming, add Schema support, remove "IDENTITY BACKUP" part, Always Create Trigger
-- Test Print Only: exec usp_CreateHistoryTableWithTrigger @TableSchema='monnit' , @TableName='Accounts', @PrintOnly=1
-- Test Create History table and Trigger: exec usp_CreateHistoryTableWithTrigger @TableSchema='product' , @TableName='contract_order'
************************************************************************************************************/
ALTER PROCEDURE [dbo].[usp_CreateHistoryTableWithTrigger]
    @TableSchema sysname='dbo'	
   ,@TableName sysname
   ,@PrintOnly bit=0

AS 
BEGIN
    DECLARE
        @SQLTable VARCHAR(MAX)
    ,   @SQLTrigger VARCHAR(MAX)
    ,   @FieldList VARCHAR(8000)
    ,   @FirstField sysname
	,   @TableName_History sysname
	,   @TableSchemaID int
    ,   @TAB CHAR(1)
    ,   @CRLF CHAR(1)
    ,   @SQL VARCHAR(1000)
    ,   @Date VARCHAR(12)
	,   @PKFieldName sysname
    ,   @FieldName sysname
    ,   @DataType VARCHAR(50) 
    ,   @FieldLength VARCHAR(10)
    ,   @Precision VARCHAR(10)
    ,   @Scale VARCHAR(10)
    ,   @FieldDescr VARCHAR(500)
    ,   @AllowNulls VARCHAR(1)
    ,   @FieldIsIdentity BIT
    ,   @FieldLengthInt INT

    SET @TAB = CHAR(9)
    SET @CRLF = CHAR(13) + CHAR(10)
    SET @Date = CONVERT(VARCHAR(12), GETDATE(), 101)
    SET @FieldList = ''
    SET @SQLTable = ''
	SET @TableName_History=@TableName+'_History'

SELECT top 1 @TableSchemaID=s.schema_id from sys.schemas s where s.name = @TableSchema

SET @TableSchemaID=ISNULL(@TableSchemaID,1) -- set deafult schema to dbo=1

DECLARE CurHistoryTable CURSOR FOR    -- query system tables to get table schema
SELECT
        CONVERT(VARCHAR(100), SC.Name) AS FieldName
    ,   CONVERT(VARCHAR(50), ST.Name) AS DataType
    ,   CONVERT(VARCHAR(10), SC.max_length) AS FieldLength
    ,   CONVERT(VARCHAR(10), SC.precision) AS FieldPrecision
    ,   CONVERT(VARCHAR(10), SC.Scale) AS FieldScale
    ,   CASE SC.Is_Nullable
          WHEN 1 THEN 'Y'
          ELSE 'N'
        END AS AllowNulls
    ,   sc.Is_Identity AS FieldIsIdentity
    ,   sc.max_length AS FieldLengthInt
    FROM
        Sys.Objects SO
        INNER JOIN Sys.Columns SC
            ON SO.object_ID = SC.object_ID
        INNER JOIN Sys.Types ST
            ON SC.user_type_id = ST.user_type_id
    WHERE
        SO.type = 'u'
        AND SO.Name = @TableName
		AND SO.schema_id = @TableSchemaID
		AND  ST.Name not in ('image')
    ORDER BY
        SO.[name]
    ,   SC.Column_Id ASC

    OPEN CurHistoryTable

    FETCH NEXT FROM CurHistoryTable INTO @FieldName, @DataType, @FieldLength, @Precision, @Scale, @AllowNulls, @FieldIsIdentity, @FieldLengthInt

    WHILE @@FETCH_STATUS = 0 
        BEGIN

	-- create list of table columns
            IF LEN(@FieldList) = 0 
                BEGIN
                    SET @FieldList = @FieldName
                    SET @FirstField = @FieldName
                END
            ELSE 
                BEGIN
                    SET @FieldList = @FieldList + ', ' + @FieldName
                END

-- if we are at the start add the std History columns in front
            IF LEN(@SQLTable) = 0 
                BEGIN
                    SET @SQLTable = 'CREATE TABLE ['+@TableSchema+'].[' + @TableName_History+'] (' + @CRLF
                    SET @SQLTable = @SQLTable + @TAB + '[' + @TableName_History+'_ID] [INT] IDENTITY(1,1) NOT NULL,' + @CRLF
                    SET @SQLTable = @SQLTable + @TAB + '[DateOfAction]' + @TAB + 'DATETIME  NOT NULL  DEFAULT (getutcdate()),' + @CRLF
                    SET @SQLTable = @SQLTable + @TAB + '[SysUser]' + @TAB + '[nvarchar](30) NOT NULL DEFAULT (suser_sname()),' + @CRLF
                    SET @SQLTable = @SQLTable + @TAB + '[Operation]' + @TAB + 'CHAR (1)        NOT NULL,' + @CRLF
                END

            SET @SQLTable = @SQLTable + @TAB + '[' + @FieldName + '] ' + '[' + @DataType + ']'
	
            IF UPPER(@DataType) IN ( 'CHAR', 'VARCHAR', 'NCHAR', 'NVARCHAR', 'BINARY' ) 
                BEGIN
                    IF @FieldLengthInt = -1 
                        SET @FieldLength = 'MAX'
		
                    SET @SQLTable = @SQLTable + '(' + @FieldLength + ')'
                END
            ELSE 
                IF UPPER(@DataType) IN ( 'DECIMAL', 'NUMERIC' ) 
                    BEGIN
                        SET @SQLTable = @SQLTable + '(' + @Precision + ', ' + @Scale + ')'
                    END


	
            SET @SQLTable = @SQLTable + ' NULL'
	
            SET @SQLTable = @SQLTable + ',' + @CRLF


            IF @FieldIsIdentity = 1 
                SET @PKFieldName = @FieldName

            FETCH NEXT FROM CurHistoryTable INTO @FieldName, @DataType, @FieldLength, @Precision, @Scale, @AllowNulls, @FieldIsIdentity, @FieldLengthInt
        END

    CLOSE CurHistoryTable
    DEALLOCATE CurHistoryTable

-- finish history table script  and code for Primary key
    SET @SQLTable = @SQLTable + ' )' + @CRLF + @CRLF
    SET @SQLTable = @SQLTable + 'ALTER TABLE ['+@TableSchema+'].[' + @TableName_History+']' + @CRLF
    SET @SQLTable = @SQLTable + @TAB + 'ADD CONSTRAINT [PK_' + @TableName_History+'] PRIMARY KEY CLUSTERED ([' + @TableName_History+'_ID] ASC)' + @CRLF
    SET @SQLTable = @SQLTable + @TAB
        + 'WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF) ON [PRIMARY]' + @CRLF
        + @CRLF

    PRINT @SQLTable
	PRINT 'GO'
	PRINT @CRLF


-- execute sql script to create history table
	IF @PrintOnly<>1  BEGIN  EXEC(@SQLTable) END

    IF @@ERROR <> 0 
        BEGIN
            PRINT '******************** ERROR CREATING HISTORY TABLE FOR TABLE: ' + @TableName + ' **************************************'
            RETURN -1
        END

	-- create history trigger
			SET @SQLTrigger = ''
            SET @SQLTrigger = '/************************************************************************************************************' + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'Created By: ' + SUSER_SNAME() + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'Created On: ' + @Date + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'Comments: Auto generated trigger' + @CRLF
            SET @SQLTrigger = @SQLTrigger + '***********************************************************************************************/' + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'CREATE TRIGGER [tud_' + @TableName + '_Move2History] ON '+@TableSchema+'.' + @TableName + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'FOR DELETE, UPDATE' + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'AS' + @CRLF 
            SET @SQLTrigger = @SQLTrigger + 'BEGIN' + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + '-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.' + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + 'SET NOCOUNT ON;' + @CRLF + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + 'DECLARE @Operation char(1)' + @CRLF + @CRLF
			SET @SQLTrigger = @SQLTrigger + @CRLF + @CRLF
			SET @SQLTrigger = @SQLTrigger + @TAB + 'if (Select count(1) from inserted)>0 SET @Operation=''U''	else  SET @Operation=''D'';' + @CRLF + @CRLF
			
			SET @SQLTrigger = @SQLTrigger + @CRLF + @CRLF
			SET @SQLTrigger = @SQLTrigger + @TAB + '-- Deleted or Modified rows:' + @CRLF
	        SET @SQLTrigger = @SQLTrigger + @TAB + 'INSERT ['+@TableSchema+'].[' + @TableName_History+']' + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + '	(Operation, ' + @FieldList + ')'+ @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + 'SELECT	[Operation] = @Operation,' + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + '     D.*' + @CRLF
            SET @SQLTrigger = @SQLTrigger + @TAB + 'FROM   deleted AS D' + @CRLF
			SET @SQLTrigger = @SQLTrigger + @CRLF + @CRLF
            SET @SQLTrigger = @SQLTrigger + 'END'   + @CRLF 
			-- SET @SQLTrigger = @SQLTrigger + @CRLF + @CRLF +'GO' + @CRLF 



	
            
    PRINT @SQLTrigger
	
	-- execute sql script to create update/delete trigger
	IF @PrintOnly<>1  BEGIN  EXEC(@SQLTrigger) END

            IF @@ERROR <> 0 
                BEGIN
                    PRINT '******************** ERROR CREATING HISTORY TRIGGER FOR TABLE: ' + @TableName + ' **************************************'
                    RETURN -1
                END

 END
