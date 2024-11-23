if exists(select name from sysobjects where name = 'sp_change_users_login1')
	drop procedure sp_change_users_login1
go

if exists(select name from sysobjects where name = 'sp_change_users_login1')
	drop procedure sp_change_users_login1
go

create procedure sp_change_users_login1
    @Action               varchar(10)       -- REPORT / UPDATE_ONE / AUTO_FIX
   ,@UserNamePattern      sysname  = Null
   ,@LoginName            sysname  = Null
   ,@Password             sysname  = Null
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @exec_stmt nvarchar(4000)

	declare @ret            int,
            @FixMode        char(5),
            @cfixesupdate   int,        -- count of fixes by update
            @cfixesaddlogin int,        -- count of fixes by sp_addlogin
            @dbname         sysname,
            @loginsid       varbinary(85),
            @110name        sysname,
            @ActionIn       varchar(10)

    -- SET INITIAL VALUES --
    select  @dbname         = db_name(),
            @cfixesupdate   = 0,
            @cfixesaddlogin = 0,
            @ActionIn = @Action,
            @Action = UPPER(@Action collate Latin1_General_CI_AS)

    -- INVALIDATE USE OF SPECIAL LOGIN/USER NAMES --
    if suser_sid(@LoginName) = 0x1 -- 'sa'
    begin
        raiserror(15287,-1,-1,@LoginName)
        return (1)
    end
    if database_principal_id(@UserNamePattern) in (0,1,2,3,4) --public, dbo, guest, INFORMATION_SCHEMA, sys
    begin
        raiserror(15287,-1,-1,@UserNamePattern)
        return (1)
    end

    -- HANDLE REPORT --
    if @Action = 'REPORT'
    begin

        -- CHECK PERMISSIONS --
        if not is_member('db_owner') = 1
        begin
		raiserror(15247,-1,-1)
            	return (1)
        end

        -- VALIDATE PARAMS --
        if @UserNamePattern IS NOT Null or @LoginName IS NOT Null
        begin
            raiserror(15600,-1,-1,'sys.sp_change_users_login')
            return (1)
        end

        -- GENERATE REPORT --
	SELECT UserName = u.name,UserSID = u.sid from master..syslogins l right join 
	    sysusers u on l.sid = u.sid 
	    where l.sid is null and issqlrole <> 1 and isapprole <> 1   
	    and (u.name <> 'INFORMATION_SCHEMA' and u.name <> 'guest' and u.name <> 'sys'  and u.name <> 'dbo'
	    and u.name <> 'system_function_schema' and u.name not like '\%')

        return (0)
    end