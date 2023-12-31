USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tbl_tempsoadetail]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_tempsoadetail](
	[rowId] [int] NOT NULL,
	[reportType] [varchar](2) NULL,
	[txnId] [varchar](400) NULL,
	[txndate] [date] NULL,
	[Particulars] [varchar](1000) NULL,
	[dr_principal] [money] NULL,
	[dr_comm] [money] NULL,
	[cr_principal] [money] NULL,
	[cr_comm] [money] NULL,
	[CLOSING] [money] NULL,
	[DRCR] [varchar](5) NULL,
	[USER] [varchar](50) NULL,
	[sessionId] [varchar](60) NULL,
	[agentId] [int] NULL,
	[fromdate] [date] NULL,
	[todate] [date] NULL
) ON [PRIMARY]
GO
