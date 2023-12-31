USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[COMM_RECLAC]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMM_RECLAC](
	[CONTROLNO] [varchar](100) NULL,
	[SAGENTCOMM] [money] NULL,
	[ID] [bigint] NOT NULL,
	[SERVICECHARGE] [money] NULL,
	[PSUPERAGENT] [int] NULL,
	[SAGENT] [int] NULL,
	[CAMT] [money] NULL,
	[TAMT] [money] NULL,
	[PAMT] [money] NULL,
	[AGENTFXGAIN] [money] NULL,
	[UPLOADLOGID] [bigint] NULL,
	[CREATEDDATE] [datetime] NULL,
	[IS_NEW_CUST] [char](1) NOT NULL,
	[COMM_PCNT] [money] NULL,
	[FX_PCNT] [money] NULL,
	[NEW_CUST] [money] NULL,
	[COMM_AMT] [money] NULL,
	[FX_AMT] [money] NULL,
	[NEW_CUST_AMT] [money] NULL,
	[TOTAL_COMM] [money] NULL
) ON [PRIMARY]
GO
