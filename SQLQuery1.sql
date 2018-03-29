create login vrojkov with password ='EnterMyComplexPwd'
GO

-- Add new sysadmin user and disable sa in one transaction
EXEC sp_addsrvrolemember 'vrojkov', 'sysadmin';  
ALTER Login sa  DISABLE
GO  

