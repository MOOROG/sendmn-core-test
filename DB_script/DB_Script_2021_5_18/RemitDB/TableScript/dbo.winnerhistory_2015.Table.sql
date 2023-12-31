USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[winnerhistory_2015]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[winnerhistory_2015](
	[ID] [int] NOT NULL,
	[srFlag] [char](1) NULL,
	[ldDate] [datetime] NULL,
	[drawType] [char](1) NULL,
	[luckyDrawFor] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[controlNo] [varchar](50) NULL,
	[drawnDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL
) ON [PRIMARY]
GO
