USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ApCashExpressTXN]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApCashExpressTXN](
	[sno] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](20) NULL,
	[agentId] [varchar](10) NULL,
	[agentRequestId] [varchar](20) NULL,
	[beneAddress] [varchar](500) NULL,
	[beneBankAccountNumber] [varchar](50) NULL,
	[beneBankBranchCode] [varchar](20) NULL,
	[beneBankBranchName] [varchar](500) NULL,
	[beneBankCode] [varchar](20) NULL,
	[beneBankName] [varchar](500) NULL,
	[beneIdNo] [varchar](20) NULL,
	[beneName] [varchar](200) NULL,
	[benePhone] [varchar](100) NULL,
	[custAddress] [varchar](500) NULL,
	[custIdDate] [varchar](100) NULL,
	[custIdNo] [varchar](20) NULL,
	[custIdType] [varchar](20) NULL,
	[custName] [varchar](200) NULL,
	[custNationality] [varchar](100) NULL,
	[custPhone] [varchar](200) NULL,
	[description] [varchar](500) NULL,
	[destinationAmount] [varchar](10) NULL,
	[destinationCurrency] [varchar](5) NULL,
	[gitNo] [varchar](15) NULL,
	[paymentMode] [varchar](20) NULL,
	[purpose] [varchar](100) NULL,
	[responseCode] [varchar](10) NULL,
	[settlementCurrency] [varchar](5) NULL,
	[status] [varchar](50) NULL,
	[fetchUser] [varchar](100) NULL,
	[fetchDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ApCashExpressTXN] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApCashExpressTXN] ADD  CONSTRAINT [MSrepl_tran_version_default_77104B8C_DC65_45D2_8A37_DDB6E056CFE3_1653073125]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
