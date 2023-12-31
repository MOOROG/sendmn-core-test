USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[bankGuaranteeHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bankGuaranteeHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[bgId] [int] NULL,
	[agentId] [int] NULL,
	[guaranteeNo] [varchar](20) NULL,
	[amount] [money] NULL,
	[currency] [int] NULL,
	[bankName] [varchar](50) NULL,
	[issuedDate] [datetime] NULL,
	[expiryDate] [datetime] NULL,
	[followUpDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_bankGuaranteeHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[bankGuaranteeHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_8F254F75_7A84_43DD_B5F7_1D34BBC3694A_2139258776]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
