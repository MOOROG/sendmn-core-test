USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryReceivingMode]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryReceivingMode](
	[crmId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[receivingMode] [int] NULL,
	[applicableFor] [char](1) NULL,
	[agentSelection] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[applicableForSA] [char](1) NULL,
 CONSTRAINT [pk_idx_countryReceivingMode_crmId] PRIMARY KEY CLUSTERED 
(
	[crmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryReceivingMode] ADD  CONSTRAINT [MSrepl_tran_version_default_B93F0EE5_B4AD_491C_A470_3B9B3EBE061A_996562984]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
