USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csDetailRec]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csDetailRec](
	[csDetailRecId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csMasterId] [int] NULL,
	[csDetailId] [int] NULL,
	[condition] [int] NULL,
	[collMode] [int] NULL,
	[paymentMode] [int] NULL,
	[checkType] [varchar](10) NULL,
	[parameter] [int] NULL,
	[period] [int] NULL,
	[criteria] [varchar](50) NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[nextAction] [char](1) NULL,
 CONSTRAINT [pk_idx_csDetailRec_csDetailRecId] PRIMARY KEY CLUSTERED 
(
	[csDetailRecId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csDetailRec] ADD  CONSTRAINT [MSrepl_tran_version_default_4C426C02_497A_4315_89B7_676F3AEDF2E7_1088215127]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
