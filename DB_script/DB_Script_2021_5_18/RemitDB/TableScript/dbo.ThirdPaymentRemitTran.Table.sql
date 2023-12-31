USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ThirdPaymentRemitTran]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThirdPaymentRemitTran](
	[ROWID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TRN_REF_NO] [varchar](25) NOT NULL,
	[S_AGENT] [varchar](50) NULL,
	[S_BRANCH] [varchar](50) NULL,
	[P_AGENT] [varchar](50) NULL,
	[P_BRANCH] [varchar](50) NULL,
	[S_COUNTRY] [varchar](300) NULL,
	[S_CURR] [varchar](10) NULL,
	[TRN_TYPE] [varchar](50) NULL,
	[TRN_STATUS] [varchar](15) NULL,
	[PAY_STATUS] [varchar](15) NULL,
	[S_AMT] [money] NULL,
	[SC_TOTAL] [money] NULL,
	[SC_HO] [money] NULL,
	[SC_S_AGENT] [money] NULL,
	[SC_P_AGENT] [money] NULL,
	[USD_AMT] [money] NULL,
	[P_AMT] [money] NULL,
	[TRN_DATE] [datetime] NULL,
	[PAID_DATE] [datetime] NULL,
	[CANCEL_DATE] [datetime] NULL,
	[SENDER_NAME] [varchar](200) NULL,
	[SENDER_ADDRESS] [varchar](500) NULL,
	[SENDER_PHONE] [varchar](500) NULL,
	[SENDER_ID_TYPE] [varchar](100) NULL,
	[SENDER_ID_NO] [varchar](50) NULL,
	[RECEIVER_NAME] [varchar](200) NULL,
	[RECEIVER_ADDRESS] [varchar](200) NULL,
	[RECEIVER_PHONE] [varchar](200) NULL,
	[RECEIVER_ID_TYPE] [varchar](100) NULL,
	[RECEIVER_ID_NO] [varchar](50) NULL,
	[ID_ISSUE_PLACE] [varchar](100) NULL,
	[REL_WITH_SEN] [varchar](100) NULL,
	[REC_FATHER_NAME] [varchar](100) NULL,
	[APPROVE_BY] [varchar](100) NULL,
	[PAIDBY] [varchar](100) NULL,
	[CANCELBY] [varchar](100) NULL,
	[TRANNO] [bigint] NULL,
 CONSTRAINT [pk_idx_ThirdPaymentRemitTran_ROWID] PRIMARY KEY CLUSTERED 
(
	[ROWID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
