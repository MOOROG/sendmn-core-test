USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[passwordHistory]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[passwordHistory](
	[userName] [varchar](50) NULL,
	[pwd] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[userType] [char](1) NULL
) ON [PRIMARY]
GO
