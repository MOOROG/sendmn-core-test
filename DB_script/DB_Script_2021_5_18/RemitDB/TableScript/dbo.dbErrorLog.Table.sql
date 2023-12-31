USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dbErrorLog]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dbErrorLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[spName] [nvarchar](126) NULL,
	[flag] [varchar](20) NULL,
	[errorMsg] [nvarchar](max) NULL,
	[errorLine] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
