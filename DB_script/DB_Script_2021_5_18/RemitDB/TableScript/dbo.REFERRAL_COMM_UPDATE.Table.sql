USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_COMM_UPDATE]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_COMM_UPDATE](
	[COMMISSION_AMT] [money] NOT NULL,
	[T_AMT] [money] NULL,
	[FX] [money] NOT NULL,
	[IS_NEW_CUSTOMER] [int] NOT NULL,
	[REFERRAL_CODE] [varchar](50) NULL,
	[PAYOUT_PARTNER] [int] NULL,
	[CUSTOMER_ID] [int] NULL,
	[TRAN_ID] [bigint] NOT NULL,
	[S_AGENT] [int] NULL,
	[TRAN_DATE] [datetime] NULL,
	[COLL_MODE] [varchar](50) NULL,
	[CONTROLNO] [varchar](100) NULL,
	[IS_CANCEL] [int] NOT NULL,
	[CANCEL_APPROVED_DATE] [datetime] NULL,
	[IS_GEN] [bit] NULL,
	[NO_ACC_VOUCHER] [bit] NULL
) ON [PRIMARY]
GO
