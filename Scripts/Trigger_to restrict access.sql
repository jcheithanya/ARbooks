USE [master]
GO

/****** Object:  DdlTrigger [RSA_Host_Login_Trigger]    Script Date: 6/12/2018 7:00:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [RSA_Host_Login_Trigger]
ON ALL SERVER WITH EXECUTE AS 'sa'
FOR LOGON
AS
BEGIN

DECLARE @data XML
SET @data = EVENTDATA()

DECLARE @AppName sysname
       ,@LoginName sysname
       ,@LoginType sysname
       ,@LoginDomain sysname
       ,@HostName sysname
SELECT @HostName = [host_name]
FROM sys.dm_exec_sessions
WHERE session_id = @data.value('(/EVENT_INSTANCE/SPID)[1]', 'int')

SELECT @LoginName = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname')
      --,@LoginDomain = @data.value('(/EVENT_INSTANCE/LoginDomain', 'sysname')
      ,@LoginType = @data.value('(/EVENT_INSTANCE/LoginType)[1]', 'sysname')
     -- ,@HostName = @data.value('(/EVENT_INSTANCE/ClientHost)[1]', 'sysname')

IF @HostName not in (select hostname from hostname)
   BEGIN
        ROLLBACK; --Disconnect the session
        --Log the exception to our Auditing table
        INSERT INTO master.dbo.loginAuditTable(data, program_name)
        VALUES(@data, @HostName)
    END 
END;

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ENABLE TRIGGER [RSA_Host_Login_Trigger] ON ALL SERVER
GO


