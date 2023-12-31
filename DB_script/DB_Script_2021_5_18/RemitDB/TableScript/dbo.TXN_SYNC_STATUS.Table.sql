USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TXN_SYNC_STATUS]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TXN_SYNC_STATUS](
	[CONTROLNO] [varchar](30) NULL,
	[CONTROLNO_ENC] [varchar](30) NULL,
	[CANCELAPPROVEDDATE] [datetime] NULL,
	[PAIDDATE] [datetime] NULL,
	[PAIDBY] [varchar](50) NULL,
	[TranStatus] [varchar](30) NULL,
	[PayStatus] [varchar](30) NULL,
	[VOUCHER_GEN] [bit] NULL,
	[OLD_CANCEL_DATE] [datetime] NULL,
	[OLD_PAID_DATE] [datetime] NULL,
	[old_status] [varchar](30) NULL,
	[old_paystatus] [varchar](30) NULL,
	[createddaate] [datetime] NULL,
	[NO_VOUCHER] [bit] NULL,
	[STATUS_CHANGE_ON_UPDATE] [bit] NULL,
	[OLD_TRAN_STATUS] [varchar](20) NULL,
	[OLD_PAY_STATUS] [varchar](30) NULL,
	[sync_date] [datetime] NULL
) ON [PRIMARY]
GO
