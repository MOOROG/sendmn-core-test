USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[domesticTranLive]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[domesticTranLive](
	[TRAN_ID] [float] NULL,
	[TRN_REF_NO] [nvarchar](255) NULL,
	[S_AGENT] [float] NULL,
	[SENDER_NAME] [nvarchar](255) NULL,
	[RECEIVER_NAME] [nvarchar](255) NULL,
	[S_AMT] [float] NULL,
	[P_AMT] [float] NULL,
	[ROUND_AMT] [float] NULL,
	[TOTAL_SC] [float] NULL,
	[OTHER_SC] [float] NULL,
	[S_SC] [float] NULL,
	[R_SC] [float] NULL,
	[EXT_SC] [float] NULL,
	[R_BANK] [float] NULL,
	[R_BANK_NAME] [nvarchar](255) NULL,
	[R_BRANCH] [nvarchar](255) NULL,
	[R_AGENT] [float] NULL,
	[TRN_TYPE] [nvarchar](255) NULL,
	[TRN_STATUS] [nvarchar](255) NULL,
	[PAY_STATUS] [nvarchar](255) NULL,
	[TRN_DATE] [nvarchar](255) NULL,
	[P_DATE] [datetime] NULL,
	[CONFIRM_DATE] [datetime] NULL,
	[CANCEL_DATE] [nvarchar](255) NULL,
	[F_SENDTRN] [nvarchar](255) NULL,
	[F_STODAY_PTODAY] [nvarchar](255) NULL,
	[F_STODAY_NOTPTODAY] [nvarchar](255) NULL,
	[F_PTODAY_SYESTERDAY] [nvarchar](255) NULL,
	[F_STODAY_CTODAY] [nvarchar](255) NULL,
	[F_CODAY_SYESTERDAY] [nvarchar](255) NULL,
	[bank_id] [float] NULL
) ON [PRIMARY]
GO
