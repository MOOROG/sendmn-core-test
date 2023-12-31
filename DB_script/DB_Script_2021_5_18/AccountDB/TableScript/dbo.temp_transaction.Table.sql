USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[temp_transaction]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_transaction](
	[tran_id] [int] IDENTITY(1,1) NOT NULL,
	[sessionId] [varchar](50) NULL,
	[acct_num] [varchar](100) NULL,
	[fcyamt] [float] NULL,
	[apprate] [float] NULL,
	[lcyamt] [float] NULL,
	[tran_date] [datetime] NULL,
	[tran_type] [varchar](5) NULL,
	[currency] [varchar](5) NULL,
	[createdBy] [varchar](50) NULL
) ON [PRIMARY]
GO
