USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dcPayDetailHub]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dcPayDetailHub](
	[dcPayDetailHubId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dcPayMasterHubId] [int] NULL,
	[fromAmt] [money] NULL,
	[toAmt] [money] NULL,
	[pcnt] [float] NULL,
	[minAmt] [money] NULL,
	[maxAmt] [money] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[dcPayDetailHubId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dcPayDetailHub] ADD  CONSTRAINT [MSrepl_tran_version_default_F2183E31_467F_4CA2_A091_4C20E71D9413_543445110]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
