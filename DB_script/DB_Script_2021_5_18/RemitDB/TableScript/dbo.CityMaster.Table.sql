USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CityMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityMaster](
	[cityId] [int] IDENTITY(1,1) NOT NULL,
	[countryId] [int] NULL,
	[cityName] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CityMaster] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
