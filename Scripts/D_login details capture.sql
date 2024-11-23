delete opendatasource('sqlncli','data source=sqlcpgo12.corp.xcelenergy.com\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tDbSize where servername=@@servername
go
delete opendatasource('sqlncli','data source=sqlcpgo12.corp.xcelenergy.com\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tblLogingServerRole where servername=@@servername
go
delete opendatasource('sqlncli','data source=sqlcpgo12.corp.xcelenergy.com\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tbllogindetails where server=@@servername
go
delete opendatasource('sqlncli','data source=sqlcpgo12.corp.xcelenergy.com\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tbluserdetails where sserver=@@servername
go
insert opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tbllogindetails
select @@servername 'server',p.name,p.type,p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin,
case is_expiration_checked when 1 then 'on' when 0 then 'off' else null end as 'is_expiration_checked', 
case is_policy_checked when 1 then 'on' when 0 then 'off' else null end as 'is_policy_checked', 
loginproperty(p.name,'islocked') as 'locked', loginproperty(p.name,'isexpired') as 'expired',
case sysadmin when 1 then 'yes' when 0 then 'no' else null end as 'sysadmin' 
from sys.server_principals p
left outer join sys.sql_logins s on (p.name = s.name) 
left outer join sys.syslogins l on (l.name = p.name) 
where p.type in ('s','g','u') 
and p.name not like '%$%' and p.name not like '%nt auth%'
go

set xact_abort on

insert opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tblLogingServerRole (rolename,memname,memsid) exec sp_helpsrvrolemember 
go
update opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tblLogingServerRole set servername=@@servername where servername is null
go
insert into opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tdbsize (Name,db_size,owner,dbid,created,status,compatibility_level) exec sp_helpdb
go
update opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tdbsize set servername=@@servername where servername is null
go

go
insert opendatasource('sqlncli','data source=sqlcpgo12\miyagi;user id=sa;password=Hand5hake').techinfo.dbo.tbluserdetails 
exec sp_msforeachdb 'use [?] select @@servername as ''servername'',db_name() as ''dbname'',(select name from [?]..sysusers where uid=[?]..sysmembers.memberuid) ''username'',
(select name from [?]..sysusers where uid=[?]..sysmembers.groupuid) ''permission'' 
from [?]..sysmembers'

set xact_abort off
go