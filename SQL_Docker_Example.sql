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