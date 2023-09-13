USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bgTemp]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bgTemp](
	[agentId] [float] NULL,
	[amt] [float] NULL,
	[issueDate] [datetime] NULL,
	[expiryDate] [datetime] NULL,
	[bankName] [nvarchar](255) NULL
) ON [PRIMARY]
GO
