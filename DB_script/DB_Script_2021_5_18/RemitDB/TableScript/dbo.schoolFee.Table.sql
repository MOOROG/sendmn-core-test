USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[schoolFee]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[schoolFee](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[schoolId] [int] NULL,
	[levelId] [int] NULL,
	[feeTypeId] [int] NULL,
	[feeType] [varchar](100) NULL,
	[amount] [money] NULL,
	[remarks] [varchar](max) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[isDeleted] [varchar](1) NULL,
	[isActive] [varchar](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_schoolFee] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[schoolFee] ADD  CONSTRAINT [MSrepl_tran_version_default_54A82D2F_4AA1_42E7_9BBB_5B0152D6EC02_11511470]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
