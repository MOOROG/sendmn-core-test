USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countriesStates]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countriesStates](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[countryCode] [char](2) NULL,
	[countryName] [varchar](150) NOT NULL,
	[stateCode] [varchar](50) NULL,
	[stateName] [varchar](150) NULL,
	[HasPmntLocs] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL
) ON [PRIMARY]
GO
