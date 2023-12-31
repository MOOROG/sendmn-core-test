USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cashSecurityHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cashSecurityHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csId] [int] NULL,
	[agentId] [int] NULL,
	[depositAcNo] [varchar](200) NULL,
	[cashDeposit] [money] NULL,
	[currency] [int] NULL,
	[depositedDate] [datetime] NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[bankName] [varchar](200) NULL,
 CONSTRAINT [pk_idx_cashSecurityHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cashSecurityHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_967C7400_D1BE_45B6_97DD_D05571F18B5A_2013354337]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
