USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[API_CITY_LIST_TEMP]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API_CITY_LIST_TEMP](
	[SN] [bigint] NULL,
	[CITY_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[STATE_ID] [varchar](20) NULL,
	[CITY_NAME] [varchar](100) NOT NULL,
	[CITY_CODE] [varchar](20) NULL,
	[CITY_COUNTRY] [varchar](45) NOT NULL,
	[PAYMENT_TYPE_ID] [int] NULL,
	[IS_ACTIVE] [bit] NOT NULL
) ON [PRIMARY]
GO
