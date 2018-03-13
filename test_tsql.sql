DECLARE @sn NVARCHAR(128);
EXEC master.dbo.xp_regread
    'HKEY_LOCAL_MACHINE',
    'SYSTEM\CurrentControlSet\services\SQLSERVERAGENT',
    'ObjectName', 
    @sn OUTPUT;
SELECT @sn;


use AdventureWorks2014
GO
SELECT * from AdventureWorks2014.dbo.DatabaseLog