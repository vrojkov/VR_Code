-- Test SQL Container servvice in AKS


WHILE 1=1 
begin
SELECT TOP 1000 [tbl_test01_ID]
      ,[code]
      ,[description]
  FROM [TEST_DB01].[dbo].[tbl_test01]

end

select @@version
select * from sys.dm_os_sys_info
select * from sys.dm_os_host_info
select * from sys.dm_os_hosts
select * from sys.dm_os_sys_info 
