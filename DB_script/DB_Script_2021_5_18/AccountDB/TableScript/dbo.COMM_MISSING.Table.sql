USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[COMM_MISSING]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMM_MISSING](
	[CONTROLNO] [varchar](100) NULL,
	[ID] [bigint] NOT NULL,
	[TRANSTATUS] [varchar](40) NULL,
	[PAYSTATUS] [varchar](20) NULL,
	[PROMOTIONCODE] [varchar](50) NULL,
	[REFERRAL_TYPE_CODE] [char](2) NULL,
	[CREATEDDATE] [date] NULL,
	[CANCELAPPROVEDDATE] [date] NULL,
	[VOUCHER_GEN] [bit] NULL
) ON [PRIMARY]
GO
