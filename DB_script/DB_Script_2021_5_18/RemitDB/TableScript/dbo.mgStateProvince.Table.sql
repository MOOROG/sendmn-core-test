USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mgStateProvince]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mgStateProvince](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[countryCode] [varchar](3) NULL,
	[stateProvinceCode] [varchar](5) NULL,
	[stateProvinceName] [varchar](150) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]
GO
