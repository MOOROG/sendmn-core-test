USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[WRONG_CUSTOMER_MAPPING]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WRONG_CUSTOMER_MAPPING](
	[CONTROLNO] [varchar](20) NULL,
	[TRANID] [bigint] NOT NULL,
	[ID] [bigint] NOT NULL,
	[SENDERNAME] [varchar](500) NULL,
	[EXTCUSTOMERID] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[CUSTOMERID] [int] NULL,
	[createddate] [datetime] NULL,
	[POSTALCODE] [varchar](500) NULL,
	[FULLNAME] [varchar](200) NULL,
	[firstname] [varchar](100) NULL
) ON [PRIMARY]
GO
