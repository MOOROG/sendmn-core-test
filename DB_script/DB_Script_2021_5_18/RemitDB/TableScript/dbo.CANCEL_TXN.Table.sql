USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CANCEL_TXN]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CANCEL_TXN](
	[ID] [bigint] IDENTITY(100000000,1) NOT NULL,
	[CONTROLNO] [varchar](100) NULL,
	[CAMT] [money] NULL
) ON [PRIMARY]
GO
