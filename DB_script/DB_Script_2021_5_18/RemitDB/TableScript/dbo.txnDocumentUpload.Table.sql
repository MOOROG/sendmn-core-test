USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[txnDocumentUpload]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[txnDocumentUpload](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tdId] [bigint] NULL,
	[fileName] [varchar](100) NULL,
	[fileDescription] [varchar](100) NULL,
	[fileType] [varchar](100) NULL,
	[isDeleted] [char](10) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
