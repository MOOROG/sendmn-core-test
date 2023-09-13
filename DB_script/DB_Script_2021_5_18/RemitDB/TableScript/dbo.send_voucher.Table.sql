USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[send_voucher]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[send_voucher](
	[CONTROLNO] [varchar](30) NULL,
	[ID] [bigint] NULL,
	[cancelApproveddate] [datetime] NULL,
	[voucher_gen] [bit] NULL,
	[is_cancel] [bit] NULL,
	[paidDate] [datetime] NULL
) ON [PRIMARY]
GO
