USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[staticdatadetail]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[staticdatadetail](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[type_id] [int] NULL,
	[ref_code] [varchar](100) NULL,
	[ref_desc] [nvarchar](1000) NULL,
	[CREATED_BY] [varchar](50) NULL,
	[CREATED_DATE] [datetime] NULL
) ON [PRIMARY]
GO
