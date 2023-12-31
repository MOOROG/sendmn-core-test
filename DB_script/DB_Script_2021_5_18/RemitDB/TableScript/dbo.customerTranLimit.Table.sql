USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerTranLimit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerTranLimit](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](200) NULL,
	[idType] [varchar](50) NULL,
	[idNumber] [varchar](50) NULL,
	[agentId] [int] NULL,
	[cAmt] [money] NULL,
	[noOfTxn] [int] NULL,
	[txnDate] [datetime] NULL,
	[updatedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_customerTranLimit_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerTranLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_2B48D19D_031B_4456_B29C_5ABE48DD3BBC_1949614384]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
