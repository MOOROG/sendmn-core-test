USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[exRateBranchWise]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[exRateBranchWise](
	[exRateBranchWiseId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[exRateTreasuryId] [int] NULL,
	[cBranch] [int] NULL,
	[premium] [float] NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_dexRateBranchWise] PRIMARY KEY CLUSTERED 
(
	[exRateBranchWiseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[exRateBranchWise] ADD  CONSTRAINT [MSrepl_tran_version_default_3FF36766_21FF_4A65_ACF4_DC70346846A6_737086062]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
