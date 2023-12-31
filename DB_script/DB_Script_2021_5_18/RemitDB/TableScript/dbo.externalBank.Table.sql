USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[externalBank]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[externalBank](
	[extBankId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[bankName] [varchar](250) NULL,
	[bankCode] [varchar](50) NULL,
	[country] [varchar](50) NULL,
	[address] [varchar](500) NULL,
	[phone] [varchar](20) NULL,
	[fax] [varchar](20) NULL,
	[email] [varchar](100) NULL,
	[contactPerson] [varchar](100) NULL,
	[swiftCode] [varchar](50) NULL,
	[routingCode] [varchar](50) NULL,
	[externalCode] [varchar](50) NULL,
	[externalBankType] [int] NULL,
	[IsBranchSelectionRequired] [varchar](20) NULL,
	[receivingMode] [int] NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[internalCode] [varchar](50) NULL,
	[mapCodeInt] [varchar](10) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[domInternalCode] [int] NULL,
	[isBlocked] [char](1) NULL,
 CONSTRAINT [PK__external__9037E23249E4BD9F] PRIMARY KEY CLUSTERED 
(
	[extBankId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[externalBank] ADD  CONSTRAINT [MSrepl_tran_version_default_3B6414A9_D348_4AD5_B9CC_58E1A680501F_884562585]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
