USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[staticdatatype]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[staticdatatype](
	[typeID] [int] NOT NULL,
	[typeTitle] [nvarchar](200) NULL,
	[typeDesc] [nvarchar](500) NULL,
	[isInternal] [int] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL
) ON [PRIMARY]
GO
