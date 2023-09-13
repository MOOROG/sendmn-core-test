USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[NEED_TO_BE_UPDATED]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NEED_TO_BE_UPDATED](
	[CONTROLNO] [varchar](100) NULL,
	[ID] [bigint] NOT NULL,
	[PAMT] [money] NULL,
	[CAMT] [money] NULL,
	[TAMT] [money] NULL,
	[PCURRCOSTRATE] [float] NULL,
	[AGENTFXGAIN] [money] NULL,
	[PCOUNTRY] [varchar](100) NULL,
	[UPLOADLOGID] [bigint] NULL,
	[xm_exRate] [float] NULL,
	[PAGENTCOMM] [money] NULL,
	[newFx] [money] NULL,
	[newComm] [money] NULL
) ON [PRIMARY]
GO
