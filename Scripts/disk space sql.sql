CREATE TABLE ##diskspace(
      [Drive] nvarchar(100),
      [date] [datetime],
      [Time] [datetime],
      [Drive Name] nvarchar(100),
      [Drive Size GB] nvarchar(100),
      [Drive Free SpaceGB] nvarchar(100)
)

--Inserting data

insert into ##diskspace SELECT DISTINCT
  vs.volume_mount_point AS [Drive],GETDATE()as date,CONVERT(VARCHAR(8),GETDATE(),108) AS Time,
  vs.logical_volume_name AS [Drive Name],
  vs.total_bytes/1024/1024/1024 AS [Drive Size GB],
  vs.available_bytes/1024/1024/1024 AS [Drive Free SpaceGB] FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
GO

--Calculating percentage and ending mail is failing

if exists(select * from ##diskspace where ( [Drive Free SpaceGB]*100/[Drive Size GB])<15 and [Drive]!='C:\' )
	
BEGIN
EXEC msdb.dbo.sp_send_dbmail
  @recipients=N'dlITSQLDBA@xcelenergy.com',
	@subject = 'Low Disk space Alert ',
	 @importance ='High', 
    @Query = 'select convert(varchar(20),@@Servername)  as servername,[Drive],convert(varchar(20),[Drive Size GB]) as DriveSizeGB,convert(varchar(80),[Drive Free SpaceGB]) as [DriveFree SpaceGB],[Drive Free SpaceGB]*100/[Drive Size GB] as percentage_Free  from ##diskspace where ( [Drive Free SpaceGB]*100/[Drive Size GB])<26';
END


drop table ##diskspace