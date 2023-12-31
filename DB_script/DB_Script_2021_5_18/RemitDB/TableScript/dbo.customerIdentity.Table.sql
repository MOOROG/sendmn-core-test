USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerIdentity]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerIdentity](
	[cIdentityId] [int] NULL,
	[idType] [int] NULL,
	[idNumber] [varchar](50) NULL,
	[customerId] [int] NULL,
	[issueCountry] [int] NULL,
	[placeOfIssue] [varchar](50) NULL,
	[issuedDate] [datetime] NULL,
	[validDate] [datetime] NULL,
	[isPrimary] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[issueDateNep] [varchar](20) NULL,
	[validDateNep] [varchar](20) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_customerIdentity_cIdentityId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customerIdentity] ADD  CONSTRAINT [MSrepl_tran_version_default_7244B16F_D0CD_41CC_9403_C85B183434BE_1246991869]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
