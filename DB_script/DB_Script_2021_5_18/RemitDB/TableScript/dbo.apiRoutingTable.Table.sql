USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[apiRoutingTable]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apiRoutingTable](
	[agentId] [int] NULL,
	[apiCode] [varchar](50) NULL,
	[apiDescription] [varchar](100) NULL,
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_apiRoutingTable_] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[apiRoutingTable] ADD  CONSTRAINT [MSrepl_tran_version_default_715A34A5_F3AD_4424_BFAC_1094CABB96CA_2061614783]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
