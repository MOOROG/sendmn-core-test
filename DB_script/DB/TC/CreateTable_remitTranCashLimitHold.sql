
USE [FastMoneyPro_Remit]
GO

/****** Object:  Table [dbo].[remitTranCashLimitHold]    Script Date: 5/5/2019 2:06:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[remitTranCashLimitHold](
	[rowId] [INT] IDENTITY(1,1) NOT NULL,
	[tranId] [BIGINT] NOT NULL,
	[approvedRemarks] [VARCHAR](150)  NULL,
	[approvedBy] [VARCHAR](80)  NULL,
	[approvedDate] [DATETIME]  NULL,
	[reason] [VARCHAR](500)  NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


