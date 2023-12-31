USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[reprocessScheduleRunLog]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reprocessScheduleRunLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[createdDate] [datetime] NULL,
	[txnCount] [int] NULL,
	[processName] [varchar](50) NULL,
	[targetCountries] [varchar](100) NULL,
	[lastTranId] [bigint] NULL,
	[completedDate] [datetime] NULL
) ON [PRIMARY]
GO
