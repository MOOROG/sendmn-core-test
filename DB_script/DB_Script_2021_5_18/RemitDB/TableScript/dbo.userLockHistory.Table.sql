USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userLockHistory]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userLockHistory](
	[ulhId] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NULL,
	[lockReason] [varchar](500) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY]
GO
