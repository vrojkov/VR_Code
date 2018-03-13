/*-------------------------
-- SQL DOCKER example
-- VR 03/05/2018 

Sql Docker start:

sudo docker run -e 'ACCEPT_EULA=Y' -e ‘MSSQL_SA_PASSWORD=MyH..S..1!' \
   -p 1401:1433 --name sql_VR_1 \
   -d microsoft/mssql-server-linux:2017-latest

sudo docker run -e 'ACCEPT_EULA=Y' -e ‘MSSQL_SA_PASSWORD=MyH..S..1!' -p 1401:1433 --name sql_VR_1 -d microsoft/mssql-server-linux:2017-latest

Get running dockers:
Sudo docker ps -a


--------------------------*/
create DATABASE TEST_DB01
go

use TEST_DB01
GO

create table tbl_test01 (tbl_test01_ID int IDENTITY(1,1), code varchar(50), description varchar(max))
GO

insert into tbl_test01 (code,description) values('C1','Code1 DEscription')
insert into tbl_test01 (code,description) values('C2','Code2 DEscription')
GO

insert into tbl_test01 (code,description) values('C1','Code1-1 DEscription')
insert into tbl_test01 (code,description) values('C2','Code2-1 DEscription')
GO

select * from tbl_test01
GO

xp_fixeddrives
select * from sys.database_files
go

CREATE DATABASE Test_DB02  
ON   
( NAME = test_dat, FILENAME = '/var/opt/mssql/data/test_db02.mdf',  
    SIZE = 5MB, MAXSIZE = 50, FILEGROWTH = 5 )  
LOG ON  
( NAME = test_log, FILENAME = '/var/opt/mssql/data/test_db02_log.ldf',  
    SIZE = 2MB, MAXSIZE = 10MB, FILEGROWTH = 5MB ) ;  

GO
drop database Test_DB02
GO
