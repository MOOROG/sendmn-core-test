USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CANCEL_TXN_09]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CANCEL_TXN_09](
	[DT] [varchar](10) NOT NULL,
	[TRANNO] [varchar](6) NOT NULL,
	[CONTROLNO] [varchar](13) NOT NULL,
	[voucher_gen] [int] NULL,
	[CONTNO_END] [varchar](30) NULL
) ON [PRIMARY]
GO
