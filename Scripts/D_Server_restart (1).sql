declare @SubMsg varchar(200)
declare @BodyMsg varchar(200)

set @SubMsg='SQL Server Services Restarted on '+@@servername

if (SERVERPROPERTY('IsClustered')=0) 
begin
set @BodyMsg='This SQL Server is setup in STANDALONE mode, please check any dependancy services.' +char(13)+char(13)+char(13)
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'dlitsqldba@xcelenergy.com',
    @subject = @SubMsg,
    @body = @BodyMsg,
    @query='SELECT Left(cast(SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') as varchar(30)),30) as PhysicalNode';
end
else 
begin
set @BodyMsg='This SQL Server is setup in CLUSTER mode, please check Failover Cluster Manager and balance if needed as per DBA documentation. Please check any dependancy services.' +char(13)+char(13)+char(13)
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'dlitsqldba@xcelenergy.com',
    @subject = @SubMsg,
    @body = @BodyMsg,
    @query='SELECT NodeName as PhysicalNodes FROM sys.dm_os_cluster_nodes';
end


