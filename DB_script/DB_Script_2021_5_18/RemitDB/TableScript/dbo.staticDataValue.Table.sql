USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[staticDataValue]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[staticDataValue](
	[valueId] [int] IDENTITY(1,1) NOT NULL,
	[typeID] [int] NULL,
	[detailTitle] [nvarchar](max) NULL,
	[detailDesc] [nvarchar](max) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[isActive] [char](1) NULL,
	[IS_DELETE] [char](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
