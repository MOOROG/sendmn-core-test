USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentContactPerson]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentContactPerson](
	[acpId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[name] [varchar](150) NULL,
	[country] [int] NULL,
	[state] [int] NULL,
	[city] [varchar](100) NULL,
	[zip] [varchar](10) NULL,
	[address] [varchar](1200) NULL,
	[phone] [varchar](100) NULL,
	[mobile1] [varchar](100) NULL,
	[mobile2] [varchar](100) NULL,
	[fax] [varchar](100) NULL,
	[email] [varchar](100) NULL,
	[post] [varchar](100) NULL,
	[contactPersonType] [int] NULL,
	[isPrimary] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentContactPerson_acpId] PRIMARY KEY CLUSTERED 
(
	[acpId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentContactPerson] ADD  CONSTRAINT [MSrepl_tran_version_default_4ED38A3E_B1E8_4E0A_AEA0_9960EAE34911_1656705300]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
