USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranTemp20130615]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranTemp20130615](
	[TRN_REF_NO] [varchar](25) NOT NULL,
	[icn] [varchar](100) NULL,
	[paidBy] [varchar](100) NULL,
	[PAID_DATE] [datetime] NULL
) ON [PRIMARY]
GO
