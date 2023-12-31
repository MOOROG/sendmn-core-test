USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RBAHighRiskCountryHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RBAHighRiskCountryHistory](
	[rowId] [int] NULL,
	[countryId] [int] NULL,
	[countryName] [varchar](50) NULL,
	[isBlocked] [bit] NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL
) ON [PRIMARY]
GO
