USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mgLocation]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mgLocation](
	[IMEBranchID] [float] NULL,
	[BranchName] [nvarchar](255) NULL,
	[AgentID] [float] NULL,
	[pos] [float] NULL,
	[POSPassWord] [float] NULL,
	[Legacy] [float] NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL
) ON [PRIMARY]
GO
