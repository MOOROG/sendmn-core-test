USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryIdType]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryIdType](
	[countryIdtypeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[IdTypeId] [int] NULL,
	[spFlag] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[expiryType] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_countryIdType_countryIdtypeId] PRIMARY KEY CLUSTERED 
(
	[countryIdtypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryIdType] ADD  CONSTRAINT [MSrepl_tran_version_default_2148B7E1_9C78_43CC_88B7_08B8637A833B_2098262680]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
