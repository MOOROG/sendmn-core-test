USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[blacklistedDc]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blacklistedDc](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[dcId] [varchar](100) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
