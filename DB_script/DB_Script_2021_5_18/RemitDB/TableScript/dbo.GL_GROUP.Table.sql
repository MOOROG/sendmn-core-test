USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[GL_GROUP]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GL_GROUP](
	[gl_code] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[gl_name] [varchar](200) NULL,
	[p_id] [varchar](20) NULL,
	[bal_grp] [varchar](20) NULL,
	[tree_sape] [varchar](500) NULL,
 CONSTRAINT [pk_idx_GL_GROUP_gl_code] PRIMARY KEY CLUSTERED 
(
	[gl_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
