USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[smsQueueAcDepositTxn]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[smsQueueAcDepositTxn](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tranId] [int] NULL
) ON [PRIMARY]
GO
