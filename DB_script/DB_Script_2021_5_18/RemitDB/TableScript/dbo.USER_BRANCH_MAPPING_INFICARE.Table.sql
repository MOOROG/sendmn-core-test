USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[USER_BRANCH_MAPPING_INFICARE]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USER_BRANCH_MAPPING_INFICARE](
	[user_login_id] [varchar](50) NULL,
	[agent_branch_code] [varchar](50) NOT NULL,
	[BRANCH] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
