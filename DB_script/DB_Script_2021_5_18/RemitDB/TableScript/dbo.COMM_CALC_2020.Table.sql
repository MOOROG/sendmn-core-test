USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[COMM_CALC_2020]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMM_CALC_2020](
	[CONTROLNO] [varchar](100) NULL,
	[PCOUNTRY] [varchar](100) NULL,
	[ID] [bigint] NOT NULL,
	[TAMT] [money] NULL,
	[SERVICECHARGE] [money] NULL,
	[AGENTFXGAIN] [money] NULL,
	[PROMOTIONCODE] [varchar](50) NULL,
	[REFERRAL_NAME] [varchar](150) NOT NULL,
	[REFERRAL_TYPE_CODE] [char](2) NULL,
	[REFERRAL_ID] [int] NOT NULL,
	[PSUPERAGENT] [int] NULL,
	[PAGENTCOMM] [money] NULL,
	[FIRST_TRAN] [char](1) NOT NULL,
	[CREATEDDATE] [datetime] NULL,
	[TRANSTATUS] [varchar](40) NULL,
	[CANCELAPPROVEDDATE] [datetime] NULL,
	[COMM_PCNT] [money] NULL,
	[FX_PCNT] [money] NULL,
	[NEW_CUST] [money] NULL,
	[FLAT_RATE] [money] NULL,
	[COMM_AMT] [money] NULL,
	[FX_AMT] [money] NULL,
	[NEW_CUST_AMT] [money] NULL,
	[FLAT_AMT] [money] NULL,
	[DEDUCT_TAX] [bit] NULL,
	[DEDUCT_COMM] [bit] NULL,
	[IS_UPDATED] [bit] NULL,
	[TOTAL_AMT] [money] NULL,
	[ACC_NUM] [varchar](30) NULL
) ON [PRIMARY]
GO
