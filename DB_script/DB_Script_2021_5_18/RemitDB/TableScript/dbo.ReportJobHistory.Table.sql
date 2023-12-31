USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ReportJobHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportJobHistory](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[job_user] [varchar](50) NULL,
	[job_date] [varchar](50) NULL,
	[job_name] [varchar](100) NULL,
	[job_desc] [varchar](500) NULL,
	[job_status] [varchar](200) NULL,
	[rdate1] [date] NULL,
	[rdate2] [date] NULL,
	[job_ready_date] [datetime] NULL,
	[url] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
