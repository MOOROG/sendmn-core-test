USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[roleMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[roleMaster](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ROLE_ID] [int] NULL,
	[MENU_LIST] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_roleMaster_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[roleMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_55396822_0949_48F4_BA2A_DC20426D27B3_683149479]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
