USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[voucher_missing]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[voucher_missing](
	[controlno] [varchar](100) NULL,
	[id] [bigint] NOT NULL,
	[has_comm] [int] NULL
) ON [PRIMARY]
GO
