USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentBankAccount]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentBankAccount](
	[abaId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[bankName] [varchar](100) NULL,
	[bankBranch] [varchar](100) NULL,
	[accountNo] [varchar](30) NULL,
	[swiftCode] [varchar](30) NULL,
	[routingNo] [varchar](30) NULL,
	[bankNameB] [varchar](100) NULL,
	[bankBranchB] [varchar](100) NULL,
	[accountNoB] [varchar](30) NULL,
	[swiftCodeB] [varchar](30) NULL,
	[routingNoB] [varchar](30) NULL,
	[isDefault] [varchar](10) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentBankAccount_abaId] PRIMARY KEY CLUSTERED 
(
	[abaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentBankAccount] ADD  CONSTRAINT [MSrepl_tran_version_default_B4AF8204_8A5D_4F89_B44F_720B784884AE_1959886249]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
