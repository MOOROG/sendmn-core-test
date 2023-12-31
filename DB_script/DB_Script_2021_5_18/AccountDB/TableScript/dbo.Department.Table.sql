USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[Department]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Department](
	[RowId] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [varchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
