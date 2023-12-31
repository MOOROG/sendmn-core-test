USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[internationalTranLive]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[internationalTranLive](
	[ROWID] [float] NULL,
	[TRN_REF_NO] [nvarchar](255) NULL,
	[S_AGENT] [float] NULL,
	[S_BRANCH] [float] NULL,
	[P_AGENT] [float] NULL,
	[P_BRANCH] [float] NULL,
	[S_CURR] [nvarchar](255) NULL,
	[S_AMT] [float] NULL,
	[TRN_TYPE] [nvarchar](255) NULL,
	[TRN_STATUS] [nvarchar](255) NULL,
	[PAY_STATUS] [nvarchar](255) NULL,
	[SC_TOTAL] [float] NULL,
	[SC_HO] [float] NULL,
	[SC_S_AGENT] [float] NULL,
	[SC_P_AGENT] [float] NULL,
	[USD_AMT] [float] NULL,
	[P_CURR] [nvarchar](255) NULL,
	[NPR_USD_RATE] [nvarchar](255) NULL,
	[EX_USD] [float] NULL,
	[EX_FLC] [float] NULL,
	[P_AMT] [float] NULL,
	[TRN_DATE] [datetime] NULL,
	[PAID_DATE] [datetime] NULL,
	[CANCEL_DATE] [nvarchar](255) NULL,
	[F_INIT] [nvarchar](255) NULL,
	[F_PAID] [nvarchar](255) NULL,
	[F_CANCEL] [nvarchar](255) NULL,
	[F_EX_FUNDING] [nvarchar](255) NULL,
	[F_EX_PAID] [nvarchar](255) NULL,
	[F_COM] [nvarchar](255) NULL,
	[F_EX_COM] [nvarchar](255) NULL,
	[SENDER_NAME] [nvarchar](255) NULL,
	[RECEIVER_NAME] [nvarchar](255) NULL,
	[agent_settlement_rate] [float] NULL,
	[agent_ex_gain] [nvarchar](255) NULL,
	[ho_dollar_rate] [nvarchar](255) NULL,
	[bonus_amt] [nvarchar](255) NULL,
	[agent_receiverSCommission] [nvarchar](255) NULL,
	[SETTLEMENT_RATE] [nvarchar](255) NULL,
	[SenderPhoneno] [nvarchar](255) NULL,
	[CustomerId] [float] NULL
) ON [PRIMARY]
GO
