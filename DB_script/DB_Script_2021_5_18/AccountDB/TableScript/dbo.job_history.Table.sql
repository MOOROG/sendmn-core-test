USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[job_history]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[job_history](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[job_name] [varchar](500) NULL,
	[job_time] [datetime] NULL,
	[job_user] [varchar](500) NULL,
	[job_value] [varchar](500) NULL,
	[job_remarks] [varchar](500) NULL,
	[update_row] [varchar](500) NULL,
	[old_value] [varchar](500) NULL
) ON [PRIMARY]
GO
