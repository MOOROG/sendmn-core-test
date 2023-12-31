USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[externalBankBranch]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[externalBankBranch](
	[extBranchId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[extBankId] [int] NOT NULL,
	[branchName] [varchar](250) NOT NULL,
	[branchCode] [varchar](100) NULL,
	[country] [varchar](100) NULL,
	[state] [varchar](100) NULL,
	[district] [varchar](100) NULL,
	[city] [varchar](100) NULL,
	[address] [varchar](1500) NULL,
	[phone] [varchar](1500) NULL,
	[swiftCode] [varchar](50) NULL,
	[routingCode] [varchar](50) NULL,
	[externalCode] [varchar](100) NULL,
	[externalBankType] [int] NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[mapCodeInt] [varchar](10) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[isHeadOffice] [char](1) NULL,
	[pLocation] [int] NULL,
	[isBlocked] [char](1) NULL,
 CONSTRAINT [PK__external__7C5DD3F3257252FF] PRIMARY KEY CLUSTERED 
(
	[extBranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[externalBankBranch] ADD  CONSTRAINT [MSrepl_tran_version_default_DF1A5E40_697E_478E_97B2_ACE430A623E7_852562471]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
