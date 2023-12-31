USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[controlNoList]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[controlNoList](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_controlNoList_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[controlNoList] ADD  CONSTRAINT [MSrepl_tran_version_default_7A81A78B_B260_41E2_A2C1_6B0D9BA3A59B_948562813]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
