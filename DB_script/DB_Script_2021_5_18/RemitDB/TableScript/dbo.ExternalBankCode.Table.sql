USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ExternalBankCode]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExternalBankCode](
	[extBankCodeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[bankId] [int] NULL,
	[externalCode] [varchar](50) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[extBranchId] [int] NULL,
	[EXTERNALBANKNAME] [varchar](500) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__External__9CF35CAB7B7C1933] PRIMARY KEY CLUSTERED 
(
	[extBankCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExternalBankCode] ADD  CONSTRAINT [MSrepl_tran_version_default_00F0E8AC_E42C_4DAF_ACAE_E8A10BB16D0C_820562357]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
