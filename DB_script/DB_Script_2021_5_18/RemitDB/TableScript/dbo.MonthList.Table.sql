USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[MonthList]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MonthList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](20) NULL,
	[Month_Number] [int] NULL
) ON [PRIMARY]
GO
