USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cancel_voucher]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cancel_voucher](
	[CONTROLNO] [varchar](100) NULL,
	[ID] [bigint] IDENTITY(100000000,1) NOT NULL,
	[cancelApproveddate] [datetime] NULL,
	[voucher_gen] [int] NULL
) ON [PRIMARY]
GO
