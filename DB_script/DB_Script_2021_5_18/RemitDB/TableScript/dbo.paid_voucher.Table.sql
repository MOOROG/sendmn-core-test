USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[paid_voucher]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[paid_voucher](
	[CONTROLNO] [varchar](100) NULL,
	[ID] [bigint] IDENTITY(100000000,1) NOT NULL,
	[cancelApproveddate] [datetime] NULL,
	[voucher_gen] [int] NOT NULL
) ON [PRIMARY]
GO
