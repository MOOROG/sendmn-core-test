USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fixedDepositHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fixedDepositHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[fdId] [int] NULL,
	[agentId] [int] NULL,
	[bankName] [varchar](50) NULL,
	[fixedDepositNo] [varchar](20) NULL,
	[amount] [money] NULL,
	[currency] [int] NULL,
	[issuedDate] [datetime] NULL,
	[expiryDate] [datetime] NULL,
	[followUpDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_fixedDepositHistory_id] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixedDepositHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_98840060_EB2A_4206_B366_ACDB447002AB_1965354166]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
