USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[emailHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emailHistory](
	[flag] [varchar](50) NULL,
	[controlNo] [varchar](50) NULL,
	[complain] [varchar](max) NULL,
	[createdBy] [varchar](50) NULL,
	[branchId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
