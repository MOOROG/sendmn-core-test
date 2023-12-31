USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ApiGBLTXN]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApiGBLTXN](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](20) NULL,
	[refNo] [varchar](50) NULL,
	[tokenId] [varchar](20) NULL,
	[senderName] [varchar](100) NULL,
	[senderAddress] [varchar](200) NULL,
	[senderTelephone] [varchar](20) NULL,
	[senderMobile] [varchar](20) NULL,
	[beneficiaryName] [varchar](100) NULL,
	[beneficiaryAddress] [varchar](200) NULL,
	[beneficiaryTelephone] [varchar](20) NULL,
	[beneficiaryMobile] [varchar](20) NULL,
	[beneficiaryIdType] [varchar](50) NULL,
	[beneficiaryIdNo] [varchar](50) NULL,
	[collAmt] [money] NULL,
	[collCurr] [varchar](3) NULL,
	[exRate] [money] NULL,
	[payoutAmt] [money] NULL,
	[payoutCurr] [varchar](3) NULL,
	[payingComm] [money] NULL,
	[remarks] [varchar](200) NULL,
	[remitType] [varchar](50) NULL,
	[remittanceEntryDate] [datetime] NULL,
	[remittanceAuthorizedDate] [datetime] NULL,
	[fetchUser] [varchar](50) NULL,
	[fetchDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_ApiGBLTXN_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApiGBLTXN] ADD  CONSTRAINT [MSrepl_tran_version_default_4B3B420A_B3FA_4DD1_A4A5_F2B2E5D31AE7_597069363]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
