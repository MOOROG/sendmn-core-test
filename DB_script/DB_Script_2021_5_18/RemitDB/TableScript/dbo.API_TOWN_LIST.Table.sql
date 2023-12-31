USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[API_TOWN_LIST]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API_TOWN_LIST](
	[TOWN_ID] [int] NOT NULL,
	[STATE_ID] [int] NULL,
	[CITY_ID] [int] NULL,
	[TOWN_NAME] [varchar](100) NOT NULL,
	[TOWN_CODE] [varchar](20) NULL,
	[TOWN_COUNTRY] [varchar](45) NOT NULL,
	[PAYMENT_TYPE_ID] [int] NULL,
	[IS_ACTIVE] [bit] NOT NULL
) ON [PRIMARY]
GO
