USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dynamicPopup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dynamicPopup](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[scope] [varchar](100) NULL,
	[fileName] [varchar](100) NULL,
	[fileDescription] [varchar](100) NULL,
	[fileType] [varchar](100) NULL,
	[isDeleted] [varchar](5) NULL,
	[isEnable] [varchar](5) NULL,
	[imageLink] [varchar](max) NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
