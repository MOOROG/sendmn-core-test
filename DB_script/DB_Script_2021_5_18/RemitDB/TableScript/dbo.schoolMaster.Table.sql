USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[schoolMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schoolMaster](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](200) NULL,
	[address] [varchar](max) NULL,
	[contactNo] [varchar](200) NULL,
	[faxNo] [varchar](100) NULL,
	[contactPerson] [varchar](200) NULL,
	[country] [varchar](100) NULL,
	[zone] [varchar](100) NULL,
	[district] [varchar](100) NULL,
	[bankId] [int] NULL,
	[bankBranchId] [int] NULL,
	[accountNo] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[isDeleted] [varchar](1) NULL,
	[isActive] [varchar](1) NULL,
	[agentId] [bigint] NULL,
	[isMaintainYrSem] [varchar](1) NULL,
	[accountName] [varchar](500) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_schoolMaster] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[schoolMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_28BB9550_213E_49C9_8554_5C6EF41A16C7_107511812]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
