USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TEMP_UNPAID]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_UNPAID](
	[SEND_DT] [varchar](10) NOT NULL,
	[AMT] [varchar](7) NOT NULL,
	[NARRATION] [nvarchar](58) NOT NULL,
	[PAID_DT] [varchar](10) NOT NULL,
	[TRANNO] [varchar](22) NOT NULL,
	[PAIDDATE] [date] NULL
) ON [PRIMARY]
GO
