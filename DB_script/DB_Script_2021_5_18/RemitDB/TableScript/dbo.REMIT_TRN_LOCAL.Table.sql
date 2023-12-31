USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REMIT_TRN_LOCAL]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REMIT_TRN_LOCAL](
	[TRAN_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[TRN_REF_NO] [varchar](20) NOT NULL,
	[S_AGENT] [varchar](50) NULL,
	[SENDER_NAME] [varchar](100) NULL,
	[RECEIVER_NAME] [varchar](100) NULL,
	[S_AMT] [money] NULL,
	[P_AMT] [money] NULL,
	[ROUND_AMT] [money] NULL,
	[TOTAL_SC] [money] NULL,
	[OTHER_SC] [money] NULL,
	[S_SC] [money] NULL,
	[R_SC] [money] NULL,
	[EXT_SC] [money] NULL,
	[R_BANK] [varchar](100) NULL,
	[R_BANK_NAME] [varchar](100) NULL,
	[R_BRANCH] [varchar](100) NULL,
	[R_AGENT] [varchar](50) NULL,
	[TRN_TYPE] [varchar](20) NULL,
	[TRN_STATUS] [varchar](15) NULL,
	[PAY_STATUS] [varchar](15) NULL,
	[TRN_DATE] [datetime] NULL,
	[P_DATE] [datetime] NULL,
	[CONFIRM_DATE] [datetime] NULL,
	[CANCEL_DATE] [datetime] NULL,
	[F_SENDTRN] [varchar](2) NULL,
	[F_STODAY_PTODAY] [varchar](2) NULL,
	[F_STODAY_NOTPTODAY] [varchar](2) NULL,
	[F_PTODAY_SYESTERDAY] [varchar](2) NULL,
	[F_STODAY_CTODAY] [varchar](2) NULL,
	[F_CODAY_SYESTERDAY] [varchar](2) NULL,
	[bank_id] [int] NULL,
	[SEmpID] [varchar](50) NULL,
	[paidBy] [varchar](50) NULL,
	[tranno] [bigint] NULL,
	[CANCEL_USER] [varchar](100) NULL,
	[TranIdNew] [bigint] NULL,
	[tranType] [char](2) NULL,
	[accountNo] [varchar](50) NULL,
 CONSTRAINT [PK_REMIT_TRN_LOCAL] PRIMARY KEY NONCLUSTERED 
(
	[TRN_REF_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
