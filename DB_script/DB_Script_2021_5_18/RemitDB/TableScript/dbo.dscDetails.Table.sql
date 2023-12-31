USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dscDetails]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dscDetails](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dscMasterId] [int] NOT NULL,
	[fromAmt] [money] NOT NULL,
	[toAmt] [money] NOT NULL,
	[pcnt] [float] NOT NULL,
	[minAmt] [money] NOT NULL,
	[maxAmt] [money] NOT NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_dscDetails_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dscDetails] ADD  CONSTRAINT [MSrepl_tran_version_default_30E8A3D1_8811_4123_8626_D6E40DDA07B7_1737109279]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
