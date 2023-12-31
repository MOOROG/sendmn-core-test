USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[REMIT_TRN_MASTER]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REMIT_TRN_MASTER](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TRN_REF_NO] [varchar](25) NOT NULL,
	[S_AGENT] [varchar](50) NULL,
	[S_BRANCH] [varchar](50) NULL,
	[P_AGENT] [varchar](50) NULL,
	[P_BRANCH] [varchar](50) NULL,
	[S_CURR] [varchar](10) NULL,
	[S_AMT] [money] NULL,
	[TRN_TYPE] [varchar](50) NULL,
	[TRN_STATUS] [varchar](15) NULL,
	[PAY_STATUS] [varchar](15) NULL,
	[SC_TOTAL] [money] NULL,
	[SC_HO] [money] NULL,
	[SC_S_AGENT] [money] NULL,
	[SC_P_AGENT] [money] NULL,
	[USD_AMT] [money] NULL,
	[P_CURR] [varchar](10) NULL,
	[NPR_USD_RATE] [float] NULL,
	[EX_USD] [float] NULL,
	[EX_FLC] [float] NULL,
	[P_AMT] [money] NULL,
	[TRN_DATE] [datetime] NULL,
	[PAID_DATE] [datetime] NULL,
	[CANCEL_DATE] [datetime] NULL,
	[F_INIT] [varchar](20) NULL,
	[F_PAID] [varchar](20) NULL,
	[F_CANCEL] [varchar](20) NULL,
	[F_EX_FUNDING] [varchar](20) NULL,
	[F_EX_PAID] [varchar](20) NULL,
	[F_COM] [varchar](20) NULL,
	[F_EX_COM] [varchar](20) NULL,
	[SENDER_NAME] [varchar](200) NULL,
	[RECEIVER_NAME] [varchar](200) NULL,
	[agent_settlement_rate] [float] NULL,
	[agent_ex_gain] [float] NULL,
	[ho_dollar_rate] [float] NULL,
	[bonus_amt] [float] NULL,
	[agent_receiverSCommission] [float] NULL,
	[SETTLEMENT_RATE] [float] NULL,
	[SenderPhoneno] [varchar](50) NULL,
	[CustomerId] [varchar](50) NULL,
	[approve_by] [varchar](100) NULL,
	[paidBy] [varchar](100) NULL,
	[S_COUNTRY] [varchar](300) NULL,
	[tranno] [bigint] NULL,
	[TranIdNew] [bigint] NULL,
	[sCurrCostRate] [float] NULL,
	[P_AMT_ACT] [money] NULL
) ON [PRIMARY]
GO
