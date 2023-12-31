USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sambaRemitGateData]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sambaRemitGateData](
	[TRN_ROWID] [int] IDENTITY(1,2) NOT FOR REPLICATION NOT NULL,
	[TRN_REF_NO] [varchar](50) NOT NULL,
	[TRN_REF_NO2] [varchar](25) NOT NULL,
	[SENDER_NAME] [varchar](200) NULL,
	[SENDER_COUNTRY] [varchar](200) NULL,
	[SENDER_ADDRESS] [varchar](200) NULL,
	[SENDER_ADDRESS2] [varchar](200) NULL,
	[SENDER_PH] [varchar](200) NULL,
	[SENDER_EMAIL] [varchar](200) NULL,
	[SENDER_CARD_NO] [varchar](200) NULL,
	[RECEIVER_NAME] [varchar](200) NULL,
	[RECEIVER_COUNTRY] [varchar](200) NULL,
	[RECEIVER_ADDRESS] [varchar](200) NULL,
	[RECEIVER_ADDRESS2] [varchar](200) NULL,
	[RECEIVER_PH] [varchar](200) NULL,
	[RECEIVER_EMAIL] [varchar](200) NULL,
	[RECEIVER_CARD_NO] [varchar](200) NULL,
	[S_AGENT] [varchar](20) NULL,
	[S_BRANCH] [varchar](20) NULL,
	[S_CURR] [varchar](3) NULL,
	[S_AMT] [money] NULL,
	[P_AGENT] [varchar](20) NULL,
	[P_BRANCH] [varchar](20) NULL,
	[P_CURR] [varchar](3) NULL,
	[P_AMT] [money] NULL,
	[SC_TOTAL] [money] NULL,
	[SC_HO] [money] NULL,
	[SC_S_AGENT] [money] NULL,
	[SC_P_AGENT] [money] NULL,
	[SC_OTHER] [float] NULL,
	[COLLECTED_AMT] [money] NULL,
	[USD_AMT] [money] NULL,
	[EX_LC] [numeric](18, 5) NULL,
	[EX_USD] [numeric](18, 5) NULL,
	[EX_FLC] [numeric](18, 5) NULL,
	[TRN_TYPE] [varchar](30) NULL,
	[TRN_STATUS] [varchar](15) NULL,
	[PAY_STATUS] [varchar](15) NULL,
	[TRN_DATE] [datetime] NULL,
	[PAID_DATE] [datetime] NULL,
	[CANCEL_DATE] [datetime] NULL,
	[SETTLEMENT_RATE] [numeric](18, 5) NULL,
	[TRN_MODE] [varchar](20) NULL,
	[TH_TRANNO] [int] NULL,
	[GAIN_LOSS] [numeric](18, 5) NULL,
	[RAN] [varchar](20) NULL,
	[DOWNLODED_TS] [datetime] NULL,
	[APPROVED_TS] [datetime] NULL,
	[APPROVED_BY] [varchar](50) NULL,
	[APPROVED_DC] [varchar](200) NULL,
	[CONFIRM_PROCESS_ID] [varchar](200) NULL,
	[TXN_STATUS] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[TRN_ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
