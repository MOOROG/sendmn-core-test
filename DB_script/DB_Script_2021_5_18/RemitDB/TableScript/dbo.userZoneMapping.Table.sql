USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userZoneMapping]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userZoneMapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userName] [varchar](50) NULL,
	[zoneName] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
